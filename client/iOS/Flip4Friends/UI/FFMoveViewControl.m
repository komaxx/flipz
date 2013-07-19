//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/13/13.
//


#import <QuartzCore/QuartzCore.h>
#import "FFMoveViewControl.h"
#import "FFPattern.h"
#import "FFBoardView.h"

#define TWO_PI (2*M_PI)

@interface FFMoveViewControl ()

@property (strong, nonatomic) FFPattern *activePattern;

/**
* root of the touchable part that reacts directly to user input
*/
@property (weak, nonatomic) UIView* movingPatternRoot;
@property (strong, nonatomic) NSMutableArray *patternViews;

@property (strong, nonatomic) CADisplayLink *displayLink;

@end


@implementation FFMoveViewControl {
    BOOL _rotating;
    BOOL _panning;

    NSInteger _targetDirection;

    /**
    *  Multiplies of PI/2 normalized into the unit circle
    */
    NSInteger _nowRotationDirection;
    CGFloat _nowRotation;

    CGPoint _downTouchPoint;
    CGPoint _downMoveViewCoords;

    CGFloat _downAngle;
}
@synthesize delegate = _delegate;
@synthesize boardView = _boardView;


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.patternViews = [[NSMutableArray alloc] initWithCapacity:10];
    }

    return self;
}

- (void)didLoad {
    UIPanGestureRecognizer *panGestureRecognizer =
            [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panning:)];
    [self addGestureRecognizer:panGestureRecognizer];

    UIRotationGestureRecognizer *rotationGestureRecognizer =
            [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotating:)];
    [self addGestureRecognizer:rotationGestureRecognizer];
}

- (void)didAppear {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(frame:)];
    self.displayLink.frameInterval = 2;
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)didDisappear {
    [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)frame:(CADisplayLink *)displayLink {
    for (UIView *view in self.patternViews) {
        CGFloat cornerRadius = 4 + (CGFloat) fabs(sin(displayLink.timestamp*3)) * 10;
        view.layer.cornerRadius = cornerRadius;
        ((UIView *)[view.subviews objectAtIndex:0]).layer.cornerRadius = 16-cornerRadius;
    }

    if (_panning || _rotating) return;

    // rotation snap
    CGFloat targetRotation = (CGFloat) (_targetDirection *M_PI_2);
    if (targetRotation != _nowRotation){
        CGFloat angleDelta = (CGFloat) (targetRotation - _nowRotation);
        if (ABS(angleDelta) < 0.001) {
            _nowRotation = targetRotation;
        } else {
            _nowRotation += angleDelta/2;       // simple but sufficient.
        }
        self.movingPatternRoot.layer.transform = CATransform3DMakeRotation(_nowRotation, 0, 0, 1);
    }

    // panning snap
    CGPoint snapPoint = [self computeSnapPoint];
    CGPoint snapDelta = CGPointMake(
            self.movingPatternRoot.center.x - snapPoint.x,
            self.movingPatternRoot.center.y - snapPoint.y);

    self.movingPatternRoot.center = CGPointMake(
            snapPoint.x + snapDelta.x/2,
            snapPoint.y + snapDelta.y/2);
}

- (void)rotating:(UIRotationGestureRecognizer *)rec {
    if (rec.state == UIGestureRecognizerStateBegan){
        _downAngle = _nowRotation;
        _rotating = YES;
    } else if (rec.state == UIGestureRecognizerStateChanged){
        NSLog(@"NOW angle: %f", rec.rotation);

        _nowRotation = rec.rotation + _downAngle;
        self.movingPatternRoot.layer.transform = CATransform3DMakeRotation(_nowRotation, 0, 0, 1);
    } else {
        _rotating = NO;

        NSLog(@"Rotation stop velocity: %f", rec.velocity);

        [self recomputeSnapTarget];
        // simple for now: No flicking gesture
        _targetDirection = _nowRotationDirection;
    }
}

- (void)panning:(UIPanGestureRecognizer *)rec {
    if (rec.state == UIGestureRecognizerStateBegan){
        _panning = YES;
        _downTouchPoint = [rec translationInView:self];
        _downMoveViewCoords = self.movingPatternRoot.center;
    } else if (rec.state == UIGestureRecognizerStateChanged){
        CGPoint p = [rec translationInView:self];
        CGPoint center = self.movingPatternRoot.center;
        center.x = _downMoveViewCoords.x + p.x;
        center.y = _downMoveViewCoords.y + p.y;

        self.movingPatternRoot.center = center;
        [self limitMovement];
    } else {
        _panning = NO;

        [self recomputeSnapTarget];
    }
}

- (void)limitMovement {
    CGPoint snapPoint = [self computeSnapPoint];
    CGPoint snapDelta = CGPointMake(
            self.movingPatternRoot.center.x - snapPoint.x,
            self.movingPatternRoot.center.y - snapPoint.y);

    self.movingPatternRoot.center = CGPointMake(
            snapPoint.x + snapDelta.x/5,
            snapPoint.y + snapDelta.y/5);
}

- (CGPoint)computeSnapPoint {
    CGFloat tileSize = [self.boardView computeTileSize];

    BOOL toppled = _targetDirection %2 == 1;
    NSInteger width = toppled ? self.activePattern.SizeY : self.activePattern.SizeX;
    NSInteger height = toppled ? self.activePattern.SizeX : self.activePattern.SizeY;

    // for easier computation: move to a 0|0 based coordinate system
    CGPoint upperLeftPx = CGPointMake(
            self.movingPatternRoot.center.x - (width*tileSize)/2 - _boardView.frame.origin.x,
            self.movingPatternRoot.center.y - (height*tileSize)/2 - _boardView.frame.origin.y);

    NSInteger closestX = (NSInteger) ((upperLeftPx.x+tileSize/2) / tileSize);
    if (closestX < 0) closestX = 0;
    else if (closestX > self.boardView.boardSize-width) closestX = self.boardView.boardSize-width;

    NSInteger closestY = (NSInteger) ((upperLeftPx.y+tileSize/2) / tileSize);
    if (closestY < 0) closestY = 0;
    else if (closestY > self.boardView.boardSize-height) closestY = self.boardView.boardSize-height;

    CGPoint snapPoint = CGPointMake(closestX * tileSize, closestY * tileSize);

    // and back to the real coordinate system based on the BoardView
    snapPoint.x += _boardView.frame.origin.x + (width*tileSize)/2;
    snapPoint.y += _boardView.frame.origin.y + (height*tileSize)/2;

    return snapPoint;
}

- (void)recomputeSnapTarget {
    [self recomputeCurrentOrientation];

}

- (void)recomputeCurrentOrientation {
    // bring rotation in [0 | 2pi] interval
    while (_nowRotation < 0) _nowRotation += TWO_PI;
    while (_nowRotation > TWO_PI) _nowRotation -= TWO_PI;

    // now: orientation
    CGFloat tmp = (CGFloat) (_nowRotation + M_PI_4);
    _nowRotationDirection = (int) (tmp / M_PI_2);
}

- (void)startMoveWithPattern:(FFPattern *)pattern {
    self.activePattern = pattern;

    // clean up the last view
    // remove old views
    for (UIView *view in self.patternViews) {
        [view removeFromSuperview];
    }
    [self.patternViews removeAllObjects];

    NSInteger boardSize = [self.boardView boardSize];
    CGFloat tileSize = [self.boardView computeTileSize];

    // resize the moving root
    if (!self.movingPatternRoot){
        UIView *nuRoot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:nuRoot];
        self.movingPatternRoot = nuRoot;
    }
    self.movingPatternRoot.frame = CGRectMake(0, 0, pattern.SizeX*tileSize, pattern.SizeY*tileSize);

    // add the pattern views
    NSMutableArray *coords = [self sortPatternCoordsOfPattern:pattern];
    for (FFCoord *coord in coords) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(
                coord.x * tileSize + 3, coord.y * tileSize + 3, tileSize - 6, tileSize - 6)];
        v.backgroundColor = [UIColor colorWithRed:1 green:0.4 blue:0 alpha:0.4];

        v.layer.cornerRadius = 18;
        v.layer.borderWidth = 4;
        v.layer.borderColor = [[UIColor colorWithRed:1 green:0.4 blue:0 alpha:0.7] CGColor];

        v.layer.shadowColor = [[UIColor purpleColor] CGColor];
        v.layer.shadowRadius = 4;
        v.layer.shadowOpacity = 0.8;
        v.layer.shadowOffset = CGSizeMake(0, 0);

        UIView *innerView = [[UIView alloc] initWithFrame:CGRectMake(
                v.frame.size.width/4, v.frame.size.height/4, v.frame.size.width/2, v.frame.size.height/2)];
        innerView.backgroundColor = [UIColor colorWithRed:1 green:0.4 blue:0 alpha:0.4];
        innerView.layer.cornerRadius = 18;
        innerView.layer.borderWidth = 3;
        innerView.layer.borderColor = [[UIColor colorWithRed:1 green:0.4 blue:0 alpha:0.7] CGColor];
        [v addSubview:innerView];

        [self.movingPatternRoot addSubview:v];
        [self.patternViews addObject:v];
    }

    // compute start position
    NSInteger baseX = (boardSize - pattern.SizeX) / 2;
    NSInteger baseY = (boardSize - pattern.SizeY) / 2;

    CGRect targetRect = self.movingPatternRoot.frame;
    targetRect.origin.x = self.boardView.frame.origin.x + baseX*tileSize;
    targetRect.origin.y = self.boardView.frame.origin.y + baseY*tileSize;
    self.movingPatternRoot.frame = targetRect;

    self.movingPatternRoot.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        self.movingPatternRoot.alpha = 1;
    }];

    self.hidden = NO;
}

- (NSMutableArray *)sortPatternCoordsOfPattern:(FFPattern *)pattern {
    NSMutableArray *ret = [NSMutableArray arrayWithArray:pattern.Coords];
    [ret sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        ushort y1 = ((FFCoord*)obj1).y;
        ushort y2 = ((FFCoord*)obj2).y;

        if (y1 == y2){
            ushort x1 = ((FFCoord*)obj1).x;
            ushort x2 = ((FFCoord*)obj2).x;
            return x1==x2 ? NSOrderedSame : (x1<x2 ? NSOrderedAscending : NSOrderedDescending);
        }

        return y1==y2 ? NSOrderedSame : (y1<y2 ? NSOrderedAscending : NSOrderedDescending);
    }];
    return ret;
}

@end
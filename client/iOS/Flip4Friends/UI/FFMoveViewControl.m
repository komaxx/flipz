//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/13/13.
//


#import <QuartzCore/QuartzCore.h>
#import "FFMoveViewControl.h"
#import "FFBoardView.h"
#import "FFGameViewController.h"
#import "UIColor+FFColors.h"

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
    BOOL _inRemovalPosition;

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

    UITapGestureRecognizer *doubleTapGestureRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTapGestureRecognizer];
}

- (void)doubleTapped:(id)doubleTapped {
    [self.delegate moveCompletedWithPattern:self.activePattern
                                         at:[self computeSnapCoord]
                            withDirection:_targetDirection];
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
        CGFloat sinus = (CGFloat) sin(displayLink.timestamp*3);
        CGFloat cornerRadius = 4 + ABS(sinus) * 10;
        view.layer.cornerRadius = cornerRadius;
        ((UIView *)[view.subviews objectAtIndex:0]).layer.cornerRadius = 16-cornerRadius;
        ((UIView *)[view.subviews objectAtIndex:0]).layer.transform =
                CATransform3DMakeRotation((CGFloat) (sinus* M_PI_4), 0, 0, 1);
        ((UIView *)[view.subviews objectAtIndex:1]).layer.cornerRadius = cornerRadius;
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
    if (self.activePattern){
        CGPoint snapPoint = [self computeSnapPointPx];
        CGPoint snapDelta = CGPointMake(
                self.movingPatternRoot.center.x - snapPoint.x,
                self.movingPatternRoot.center.y - snapPoint.y);

        self.movingPatternRoot.center = CGPointMake(
                snapPoint.x + snapDelta.x/2,
                snapPoint.y + snapDelta.y/2);
    }
}

- (void)rotating:(UIRotationGestureRecognizer *)rec {
    if (rec.state == UIGestureRecognizerStateBegan){
        _downAngle = _nowRotation;
        _rotating = YES;
    } else if (rec.state == UIGestureRecognizerStateChanged){
        _nowRotation = rec.rotation + _downAngle;
        self.movingPatternRoot.layer.transform = CATransform3DMakeRotation(_nowRotation, 0, 0, 1);
    } else {
        _rotating = NO;

        NSLog(@"Rotation stop velocity: %f", rec.velocity);

        [self recomputeCurrentOrientation];
        // simple for now: No flicking gesture, just snap
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
        if (_inRemovalPosition) {
            [self.delegate cancelMoveWithPattern:self.activePattern];
            _inRemovalPosition = NO;
        }

        _panning = NO;
    }
}

- (void)limitMovement {
    CGPoint snapPoint = [self computeSnapPointPx];
    CGPoint snapDelta = CGPointMake(
            self.movingPatternRoot.center.x - snapPoint.x,
            self.movingPatternRoot.center.y - snapPoint.y);

    self.movingPatternRoot.center = CGPointMake(
            snapPoint.x + snapDelta.x/5,
            snapPoint.y + snapDelta.y/5);

    if (ABS(snapDelta.y) > [self.boardView computeTileSize]) {
        if (!_inRemovalPosition){
            [UIView animateWithDuration:0.2 animations:^{
                for (UIView *view in self.patternViews) {
                    view.backgroundColor = [UIColor movePatternBack_removing];
                    view.layer.borderColor = [[UIColor movePatternBorder_removing] CGColor];
                    ((UIView *)[view.subviews objectAtIndex:0]).backgroundColor = [UIColor movePatternBack_removing];
                    ((UIView *)[view.subviews objectAtIndex:0]).backgroundColor = [UIColor movePatternBack_removing];
                }
            }];
            _inRemovalPosition = YES;
        }

    } else if (_inRemovalPosition) {
        [UIView animateWithDuration:0.2 animations:^{
            for (UIView *view in self.patternViews) {
                view.backgroundColor = [UIColor movePatternBack];
                view.layer.borderColor = [[UIColor movePatternBorder] CGColor];
                ((UIView *)[view.subviews objectAtIndex:0]).backgroundColor = [UIColor movePatternBack];
                ((UIView *)[view.subviews objectAtIndex:1]).backgroundColor = [UIColor movePatternBack];
            }
        }];
        _inRemovalPosition = NO;
    }
}

- (CGPoint)computeSnapPointPx {
    CGFloat tileSize = [self.boardView computeTileSize];
    FFCoord *snapCoord = [self computeSnapCoord];

    CGPoint snapPoint = CGPointMake(snapCoord.x * tileSize, snapCoord.y * tileSize);

    // and back to the real coordinate system based on the BoardView
    BOOL toppled = _targetDirection %2 == 1;
    NSInteger width = toppled ? self.activePattern.SizeY : self.activePattern.SizeX;
    NSInteger height = toppled ? self.activePattern.SizeX : self.activePattern.SizeY;
    snapPoint.x += _boardView.frame.origin.x + (width*tileSize)/2;
    snapPoint.y += _boardView.frame.origin.y + (height*tileSize)/2;

    return snapPoint;
}

- (FFCoord *)computeSnapCoord {
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

    return [[FFCoord alloc] initWithX:(ushort) closestX andY:(ushort) closestY];
}

- (void)recomputeCurrentOrientation {
    // bring rotation in [0 | 2pi] interval
    while (_nowRotation < 0) _nowRotation += TWO_PI;
    while (_nowRotation > TWO_PI) _nowRotation -= TWO_PI;

    // now: orientation
    CGFloat tmp = (CGFloat) (_nowRotation + M_PI_4);
    _nowRotationDirection = (int) (tmp / M_PI_2);
}

- (void)moveFinished {
    self.activePattern = nil;

    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)startMoveWithPattern:(FFPattern *)pattern
                     atCoord:(FFCoord *)atCoord
               andAppearFrom:(UIView *)appearView
                withRotation:(NSInteger)startDirection{

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
    // reset the interaction variables
    _nowRotationDirection = 0;
    _targetDirection = startDirection;

    UIColor *borderColor = [UIColor movePatternBorder];
    UIColor *fillColor = [UIColor movePatternBack]; //[UIColor colorWithRed:0 green:1 blue:1 alpha:0.25];
    CGFloat cornerRadius = 18;
    CGFloat borderWidth = 2.5;

    // add the pattern views
    NSMutableArray *coords = [self sortPatternCoordsOfPattern:pattern];
    for (FFCoord *coord in coords) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(
                coord.x * tileSize + 2, coord.y * tileSize + 2, tileSize - 4, tileSize - 4)];
        v.backgroundColor = fillColor;

        v.layer.cornerRadius = cornerRadius;
        v.layer.borderWidth = borderWidth;
        v.layer.borderColor = [borderColor CGColor];
        v.layer.borderColor = [borderColor CGColor];

        v.layer.shadowColor = [[UIColor purpleColor] CGColor];
        v.layer.shadowRadius = 3;
        v.layer.shadowOpacity = 0.6;
        v.layer.shadowOffset = CGSizeMake(0, 0);

        UIView *innerView1 = [[UIView alloc] initWithFrame:CGRectMake(
                v.frame.size.width/6, v.frame.size.height/6, v.frame.size.width*2/3, v.frame.size.height*2/3)];
        innerView1.backgroundColor = fillColor;
        innerView1.layer.cornerRadius = cornerRadius;
        innerView1.layer.borderWidth = borderWidth;
        innerView1.layer.borderColor = [borderColor CGColor];
        [v addSubview:innerView1];

        UIView *innerView2 = [[UIView alloc] initWithFrame:CGRectMake(
                v.frame.size.width/3, v.frame.size.height/3, v.frame.size.width/3, v.frame.size.height/3)];
        innerView2.backgroundColor = fillColor;
        innerView2.layer.cornerRadius = cornerRadius;
        innerView2.layer.borderWidth = borderWidth;
        innerView2.layer.borderColor = [borderColor CGColor];
        [v addSubview:innerView2];

        [self.movingPatternRoot addSubview:v];
        [self.patternViews addObject:v];
    }

    // compute start position
    CGRect targetRect = self.movingPatternRoot.frame;

    if (atCoord){
        targetRect.origin.x = self.boardView.frame.origin.x + atCoord.x*tileSize;
        targetRect.origin.y = self.boardView.frame.origin.y + atCoord.y*tileSize;
    } else {
        NSInteger baseX = (boardSize - pattern.SizeX) / 2;
        NSInteger baseY = (boardSize - pattern.SizeY) / 2;

        targetRect.origin.x = self.boardView.frame.origin.x + baseX*tileSize;
        targetRect.origin.y = self.boardView.frame.origin.y + baseY*tileSize;
    }

    self.movingPatternRoot.frame = [self convertRect:appearView.bounds fromView:appearView];

    self.movingPatternRoot.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        self.movingPatternRoot.frame = targetRect;
        self.movingPatternRoot.alpha = 1;
    }];

    self.alpha = 1;
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
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/13/13.
//


#import <QuartzCore/QuartzCore.h>
#import "FFMoveViewControl.h"
#import "FFBoardView.h"
#import "FFGameViewController.h"
#import "UIColor+FFColors.h"
#import "FFGame.h"

#define TWO_PI (2*M_PI)

@interface FFMoveViewControl ()

@property (strong, nonatomic) CAShapeLayer *rotRingLayerOuter;
@property (strong, nonatomic) CAShapeLayer *rotRingLayerInner;

@property (strong, nonatomic) FFPattern *activePattern;

/**
* root of the touchable part that reacts directly to user input
*/
@property (weak, nonatomic) UIView* movingPatternRoot;
@property (strong, nonatomic) NSMutableArray *patternViews;

@property (strong, nonatomic) CADisplayLink *displayLink;

@property (nonatomic) BOOL enableRotation;
@property (nonatomic) BOOL enableMirroring;

@end


@implementation FFMoveViewControl {
    BOOL _rotating;
    BOOL _panning;
    BOOL _inRemovalPosition;
    BOOL _player2;

    NSInteger _targetDirection;

    /**
    *  Multiplies of PI/2 normalized into the unit circle
    */
    NSInteger _nowRotationDirection;
    CGFloat _nowRotation;

    CGFloat _rotationRingRadius;

    CGPoint _downMoveViewCoords;
    CGPoint _downTouchPoint;

    CGFloat _downAngle;
    CGFloat _downTouchAngle;
    NSInteger _downDirection;
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
    UIRotationGestureRecognizer *rotationGestureRecognizer =
            [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotating:)];
    rotationGestureRecognizer.delegate = self;
    rotationGestureRecognizer.cancelsTouchesInView = NO;
    [self addGestureRecognizer:rotationGestureRecognizer];

    UITapGestureRecognizer *doubleTapGestureRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    doubleTapGestureRecognizer.delegate = self;
    doubleTapGestureRecognizer.cancelsTouchesInView = NO;
    [self addGestureRecognizer:doubleTapGestureRecognizer];

    UIPanGestureRecognizer *panGestureRecognizer =
            [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panning:)];
    panGestureRecognizer.delegate = self;
    panGestureRecognizer.cancelsTouchesInView = NO;
    [self addGestureRecognizer:panGestureRecognizer];
}

- (void)setRulesFromGame:(FFGame *)game {
    self.enableRotation = game.ruleAllowPatternRotation;
    self.enableMirroring = game.ruleAllowPatternMirroring;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
        shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
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
    if (_panning || _rotating) return;

    for (UIView *view in self.patternViews) {
        CGFloat sinus = (CGFloat) sin(displayLink.timestamp*3);
        CGFloat cornerRadius = 4 + ABS(sinus) * 10;
        view.layer.cornerRadius = cornerRadius;
        ((UIView *)[view.subviews objectAtIndex:0]).layer.cornerRadius = 16-cornerRadius;
        ((UIView *)[view.subviews objectAtIndex:0]).layer.transform =
                CATransform3DMakeRotation((CGFloat) (sinus* M_PI_4), 0, 0, 1);
        ((UIView *)[view.subviews objectAtIndex:1]).layer.cornerRadius = cornerRadius;
    }

//    if (_panning || _rotating) return;

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
    if (!self.enableRotation) return;

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

        _downTouchPoint = [rec locationInView:self];
        _downTouchPoint.x -= self.movingPatternRoot.center.x;
        _downTouchPoint.y -= self.movingPatternRoot.center.y;
        CGFloat touchRadius = sqrtf(_downTouchPoint.x*_downTouchPoint.x + _downTouchPoint.y*_downTouchPoint.y);
        if (self.enableRotation && ABS(touchRadius - _rotationRingRadius - 10) < 25){           // -10: move the touchable area outwards a bit
            _downAngle = _nowRotation;
            _downTouchAngle = atan2f(_downTouchPoint.y, _downTouchPoint.x);
            _downDirection = _targetDirection;
            self.rotRingLayerInner.strokeColor = [[UIColor colorWithWhite:1 alpha:1] CGColor];
            self.rotRingLayerOuter.strokeColor =
                    [_player2 ? [UIColor movePattern2Border] : [UIColor movePatternBorder] CGColor];
            _rotating = YES;
        } else {
            _downMoveViewCoords = self.movingPatternRoot.center;
            _panning = YES;
        }
    } else if (rec.state == UIGestureRecognizerStateChanged){
        if (_panning){
            CGPoint p = [rec translationInView:self];
            CGPoint center = self.movingPatternRoot.center;
            center.x = _downMoveViewCoords.x + p.x;
            center.y = _downMoveViewCoords.y + p.y;

            self.movingPatternRoot.center = center;
            [self limitMovement];
        } else if (_rotating){
            CGPoint p = [rec locationInView:self];
            p.x -= self.movingPatternRoot.center.x;
            p.y -= self.movingPatternRoot.center.y;

            CGFloat nowTouchAngle = atan2f(p.y, p.x);
            _nowRotation = _downAngle + nowTouchAngle-_downTouchAngle;
            self.movingPatternRoot.layer.transform = CATransform3DMakeRotation(_nowRotation, 0, 0, 1);
        }
    } else {
        if (_panning){
            if (_inRemovalPosition) {
                [self.delegate cancelMoveWithPattern:self.activePattern];
                _inRemovalPosition = NO;
            }

            _panning = NO;
        } else if (_rotating){
            _rotating = NO;
            self.rotRingLayerInner.strokeColor = [[UIColor colorWithWhite:1 alpha:0.5] CGColor];
            self.rotRingLayerOuter.strokeColor =
                    [_player2 ? [UIColor movePattern2Back] : [UIColor movePatternBack] CGColor];
            [self recomputeCurrentOrientation];

            if (_nowRotationDirection != _targetDirection){
                _targetDirection = _nowRotationDirection;
            } else {    // flicking?
                CGPoint velocity = [rec velocityInView:self];
                if (ABS(_downTouchPoint.x) > ABS(_downTouchPoint.y) && ABS(velocity.y)>400){
                    if (velocity.y>0 == _downTouchPoint.x>0)
                        _targetDirection = (_targetDirection+1) % 5;
                    else
                        _targetDirection = (_targetDirection+4) % 5;
                } else if (ABS(_downTouchPoint.x) < ABS(_downTouchPoint.y) && ABS(velocity.x)>400){
                    if (velocity.x>0 == _downTouchPoint.y<0)
                        _targetDirection = (_targetDirection+1) % 5;
                    else
                        _targetDirection = (_targetDirection+4) % 5;
                }
            }
        }
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
            UIColor *backColor = _player2 ? [UIColor movePattern2Back] : [UIColor movePatternBack];
            for (UIView *view in self.patternViews) {
                view.backgroundColor = backColor;
                view.layer.borderColor = _player2 ?
                        [[UIColor movePattern2Border] CGColor] :
                        [[UIColor movePatternBorder] CGColor];

                ((UIView *)[view.subviews objectAtIndex:0]).backgroundColor = backColor;
                ((UIView *)[view.subviews objectAtIndex:1]).backgroundColor = backColor;
            }
        }];
        _inRemovalPosition = NO;
    }
}

- (CGPoint)computeSnapPointPx {
    CGFloat tileSize = [self.boardView computeTileSize];
    FFCoord *snapCoord = [self computeSnapCoord];

    CGPoint snapPoint = CGPointMake(snapCoord.x * tileSize, snapCoord.y * tileSize);

    // and back to the real coordinate system based on t    he BoardView
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
                withRotation:(NSInteger)startDirection
                  forPlayer2:(BOOL)player2{

    self.activePattern = pattern;
    _player2 = player2;

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

        CAShapeLayer *ringLayer1 = [[CAShapeLayer alloc] init];
        ringLayer1.lineWidth = 6;
        ringLayer1.lineCap = @"round";
        ringLayer1.strokeColor = [[UIColor movePatternBorder] CGColor];
        ringLayer1.fillColor = [[UIColor clearColor] CGColor];
        [self.movingPatternRoot.layer addSublayer:ringLayer1];
        self.rotRingLayerOuter = ringLayer1;

        CAShapeLayer *ringLayer2 = [[CAShapeLayer alloc] init];
        ringLayer2.lineWidth = 2.5;
        ringLayer2.lineCap = @"round";
        ringLayer2.strokeColor = [[UIColor colorWithWhite:1 alpha:0.5] CGColor];
        ringLayer2.fillColor = [[UIColor clearColor] CGColor];

        [self.movingPatternRoot.layer addSublayer:ringLayer2];
        self.rotRingLayerInner = ringLayer2;
    }
    _nowRotation = 0;
    self.movingPatternRoot.layer.transform = CATransform3DMakeRotation(_nowRotation, 0, 0, 1);
    self.movingPatternRoot.frame = CGRectMake(0, 0, pattern.SizeX*tileSize, pattern.SizeY*tileSize);

    [self resetRingLayer];

    // reset the interaction variables
    _nowRotationDirection = startDirection;
    _targetDirection = startDirection;


    UIColor *borderColor = _player2 ? [UIColor movePattern2Border] : [UIColor movePatternBorder];
    UIColor *fillColor = _player2 ? [UIColor movePattern2Back] : [UIColor movePatternBack];
    CGFloat cornerRadius = 18;
    CGFloat borderWidth = 5;

    // add the pattern views
    NSMutableArray *coords = [self sortPatternCoordsOfPattern:pattern];
    for (FFCoord *coord in coords) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(
                coord.x * tileSize + 2, coord.y * tileSize + 2, tileSize - 4, tileSize - 4)];
        v.backgroundColor = fillColor;
        v.layer.masksToBounds = NO;

        v.layer.cornerRadius = cornerRadius;
        v.layer.borderWidth = borderWidth;
        v.layer.borderColor = [borderColor CGColor];
        v.layer.borderColor = [borderColor CGColor];

        UIView *innerView1 = [[UIView alloc] initWithFrame:CGRectMake(
                v.frame.size.width/6, v.frame.size.height/6, v.frame.size.width*2/3, v.frame.size.height*2/3)];
        innerView1.backgroundColor = fillColor;
        innerView1.layer.cornerRadius = cornerRadius;
        innerView1.layer.borderWidth = borderWidth;
        innerView1.layer.borderColor = [[UIColor colorWithWhite:1 alpha:0.5] CGColor]; //[borderColor CGColor];
        innerView1.layer.masksToBounds = NO;
//        innerView1.hidden = YES;
        [v addSubview:innerView1];

        UIView *innerView2 = [[UIView alloc] initWithFrame:CGRectMake(
                v.frame.size.width/3, v.frame.size.height/3, v.frame.size.width/3, v.frame.size.height/3)];
        innerView2.backgroundColor = fillColor;
        innerView2.layer.cornerRadius = cornerRadius;
        innerView2.layer.borderWidth = borderWidth;
        innerView2.layer.borderColor = [[UIColor colorWithWhite:0 alpha:0.5] CGColor]; //[borderColor CGColor];
        innerView2.layer.masksToBounds = NO;
        innerView2.hidden = YES;
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

    self.movingPatternRoot.alpha = 0.1;
    [UIView animateWithDuration:0.2 animations:^{
        self.movingPatternRoot.frame = targetRect;
        self.movingPatternRoot.alpha = 1;
    }];
    self.rotRingLayerOuter.strokeColor = [fillColor CGColor];

    self.rotRingLayerInner.hidden = !self.enableRotation;
    self.rotRingLayerOuter.hidden = !self.enableRotation;

    self.alpha = 1;
    self.hidden = NO;
}

- (void)resetRingLayer {
    CGMutablePathRef path = CGPathCreateMutable();

    // compute radius
    CGFloat centerX = CGRectGetMidX(self.movingPatternRoot.bounds);
    CGFloat centerY = CGRectGetMidY(self.movingPatternRoot.bounds);
    _rotationRingRadius = sqrtf(centerX * centerX + centerY * centerY) + 6;
    _rotationRingRadius = MAX(50, _rotationRingRadius);

    CGFloat arrowRadius = _rotationRingRadius-5;

    CGFloat anglePadding = (CGFloat) (M_PI / 9.0);
    CGFloat arrowAnglePadding = (CGFloat) (M_PI / 18.0);

    for (int i = 0; i < 4; i++){
        CGFloat startAngle = (CGFloat) (-M_PI/4+ anglePadding + i* M_PI/2);
        CGFloat endAngle = (CGFloat) (startAngle + M_PI/2 - 2*anglePadding);

        CGPathMoveToPoint(path, &CGAffineTransformIdentity,
                centerX + cosf(startAngle+arrowAnglePadding)*arrowRadius,
                centerY + sinf(startAngle+arrowAnglePadding)*arrowRadius);
        CGPathAddLineToPoint(path, &CGAffineTransformIdentity,
                centerX + cosf(startAngle)*_rotationRingRadius, centerY + sinf(startAngle)*_rotationRingRadius);

        CGPathAddArc(path, &CGAffineTransformIdentity, centerX, centerY, _rotationRingRadius, startAngle, endAngle, NO);

        CGPathAddLineToPoint(path, &CGAffineTransformIdentity,
                centerX + cosf(endAngle-arrowAnglePadding)*arrowRadius,
                centerY + sinf(endAngle-arrowAnglePadding)*arrowRadius);
    }

    [self.rotRingLayerInner setPath:path];
    [self.rotRingLayerOuter setPath:path];

    CGPathRelease(path);
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
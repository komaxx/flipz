//
//  FFChallengeHistorySliderView.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 10/4/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFChallengeHistorySliderView.h"

#import "FFGame.h"
#import "FFGamesCore.h"
#import "UIColor+FFColors.h"
#import "FFPattern.h"
#import "FFHistoryStep.h"

#define INTER_STEP_MARGIN 35.0
#define STEP_SYMBOL_SIZE 26.0

#define UNDO_THRESHOLD -100


@interface FFChallengeHistorySliderView ()
@property (strong, nonatomic) NSMutableDictionary *stepViewsById;
@property (strong, nonatomic) NSMutableDictionary *removeCollector;
@property (strong, nonatomic) NSMutableArray *positioningTmpArray;
@end


@implementation FFChallengeHistorySliderView {
    NSInteger _lastNotifiedHistoryPosition;
}
@synthesize activeGameId = _activeGameId;


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _lastNotifiedHistoryPosition = -1;

        self.stepViewsById = [[NSMutableDictionary alloc] initWithCapacity:10];
        self.removeCollector = [[NSMutableDictionary alloc] initWithCapacity:10];
        self.positioningTmpArray = [[NSMutableArray alloc] initWithCapacity:10];
    }

    return self;
}

- (void)setActiveGameId:(NSString *)activeGameId {
    _activeGameId = [activeGameId mutableCopy];
    [self repositionStepViews];
}


- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    NSInteger snapIndex = [self snapIndexForTouch:touch];
    if (snapIndex >= 0){
        _lastNotifiedHistoryPosition = snapIndex;
        [self notifyChange];
        return YES;
    }
    return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:self];
    if (touchPoint.x < 0){
        // TODO: show activation glow
        return YES;
    }

    NSInteger snapIndex = [self snapIndexForTouch:touch];
    if (snapIndex >= 0 && snapIndex != _lastNotifiedHistoryPosition){
        _lastNotifiedHistoryPosition = snapIndex;
        [self notifyChange];
    }
    return YES;
}

- (void)notifyChange {
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:_lastNotifiedHistoryPosition],
                    kFFNotificationHistoryShowStateChanged_stepsBack, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFFNotificationHistoryShowStateChanged object:nil userInfo:userInfo];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    NSInteger undoSteps = _lastNotifiedHistoryPosition;

    // check whether this was an undo!
    CGPoint touchPoint = [touch locationInView:self];
    if (touchPoint.x < UNDO_THRESHOLD){
        NSLog(@"UNDO for history step %i", undoSteps);
        FFGame *game = [[FFGamesCore instance] gameWithId:self.activeGameId];
        [game goBackInHistory:undoSteps];
    }

    _lastNotifiedHistoryPosition = -1;
    [self notifyChange];
}

- (NSInteger)snapIndexForTouch:(UITouch *)touch {
    if (!self.activeGameId) return -1;
    FFGame *game = [[FFGamesCore instance] gameWithId:self.activeGameId];
    NSInteger historySize = game.history.count;
    if (!game || historySize < 1) return -1;

    CGPoint touchPoint = [touch locationInView:self];
    NSInteger index = (NSInteger) (
            (touchPoint.y +
                    self.bounds.size.width/2.0 -
                    INTER_STEP_MARGIN/2.0
            )
                    / INTER_STEP_MARGIN);

    index = MIN(index, historySize-1);

    return index;
}

- (void)didAppear {
    [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(repositionStepViews) name:kFFNotificationGameChanged object:nil];
}

- (void)didDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)repositionStepViews {
    [self.removeCollector removeAllObjects];
    [self.removeCollector addEntriesFromDictionary:self.stepViewsById];

    NSArray *history = [[FFGamesCore instance] gameWithId:self.activeGameId].history;

    CGFloat topY = 0;

    BOOL needsRepositioning = NO;
    BOOL containsClearStep = NO;
    [self.positioningTmpArray removeAllObjects];

    for (FFHistoryStep *step in history) {
        if (topY > self.bounds.size.height) break;  // done. Anything more would not be on the sceen

        if (step.type == kFFHistoryStepClear) containsClearStep = YES;

        if (![self.stepViewsById objectForKey:step.id]){
            needsRepositioning = YES;
            UIView *stepView = [[UIView alloc] initWithFrame:
                    CGRectMake((self.bounds.size.width- STEP_SYMBOL_SIZE)/2, -100, STEP_SYMBOL_SIZE, STEP_SYMBOL_SIZE)];
            [self setShapeOfView:stepView forStep:step];

            [self addSubview:stepView];
            [self.stepViewsById setObject:stepView forKey:step.id];
        } else {
            [self.removeCollector removeObjectForKey:step.id];
        }

        [self.positioningTmpArray addObject:[self.stepViewsById objectForKey:step.id]];
        topY += INTER_STEP_MARGIN;
    }

    for (NSString *key in self.removeCollector) {
        [[self.stepViewsById objectForKey:key] removeFromSuperview];
        [self.stepViewsById removeObjectForKey:key];
    }

    if (needsRepositioning){
        float alpha = 1;
        CGPoint centerPoint = CGPointMake(self.bounds.size.width/2 - 4, self.bounds.size.width/2);
        for (UIView *stepView in self.positioningTmpArray) {
            [UIView animateWithDuration:0.3 animations:^{
                stepView.center = centerPoint;
                stepView.alpha = alpha;
            }];

            centerPoint = CGPointMake(centerPoint.x, centerPoint.y + INTER_STEP_MARGIN);
            alpha -= 0.05;
        }

        [self showBottomClearStep:!containsClearStep];
    }
}

- (void)showBottomClearStep:(BOOL)b {
    // TODO
}

- (void)setShapeOfView:(UIView *)view forStep:(FFHistoryStep *)step {
    view.userInteractionEnabled = NO;
    view.backgroundColor = [UIColor clearColor];

    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    [view.layer addSublayer:shapeLayer];

    shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
    shapeLayer.shadowOffset = CGSizeMake(0, 3);
    shapeLayer.shadowOpacity = 1;
    shapeLayer.shadowRadius = 0;
    shapeLayer.lineCap = @"round";

    CGMutablePathRef path = CGPathCreateMutable();

    CGFloat centerXY = STEP_SYMBOL_SIZE/2;
    if (step.type == kFFHistoryStepMove){
        shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
        CGFloat size = 8.0;
        CGPathAddRoundedRect(path, &CGAffineTransformIdentity,
                CGRectMake((STEP_SYMBOL_SIZE- size)/2, (STEP_SYMBOL_SIZE- size)/2, size, size),
                2, 2);
    } else if (step.type == kFFHistoryStepBack){
        shapeLayer.lineWidth = 4;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        CGPathAddArc(path, &CGAffineTransformIdentity, centerXY-2, centerXY,
                STEP_SYMBOL_SIZE/2-8, (CGFloat) M_PI_2*1.2, -(CGFloat) M_PI_2*1.0, YES);
    } else {    // clear
        shapeLayer.lineWidth = 4;

        CGFloat innerRadius = 6;
        CGFloat outerRadius = STEP_SYMBOL_SIZE/2-3;

        NSArray *angles = @[
                [NSNumber numberWithFloat:0],
                [NSNumber numberWithFloat:(float) (60.0 / 180.0 * M_PI)],
                [NSNumber numberWithFloat:(float) (-60.0 / 180.0 * M_PI)] ];

        for (NSNumber *angle in angles) {
            CGFloat nowSin= (CGFloat) sin([angle floatValue]);
            CGFloat nowCos = (CGFloat) cos([angle floatValue]);

            CGPathMoveToPoint(path, &CGAffineTransformIdentity, centerXY-(outerRadius*nowCos), centerXY+(outerRadius*nowSin));
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, centerXY-(innerRadius*nowCos), centerXY+(innerRadius*nowSin));
            CGPathMoveToPoint(path, &CGAffineTransformIdentity, centerXY+(outerRadius*nowCos), centerXY+(outerRadius*nowSin));
            CGPathAddLineToPoint(path, &CGAffineTransformIdentity, centerXY+(innerRadius*nowCos), centerXY+(innerRadius*nowSin));
        }
    }

    [shapeLayer setPath:path];
}

@end
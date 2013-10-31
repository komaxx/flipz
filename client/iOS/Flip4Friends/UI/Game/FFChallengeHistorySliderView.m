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
#import "FFHistoryStep.h"

#define INTER_STEP_MARGIN 42.0
#define STEP_SYMBOL_SIZE 28.0


@interface FFChallengeHistorySliderView ()
@property (strong, nonatomic) NSMutableDictionary *stepViewsById;
@property (strong, nonatomic) NSMutableDictionary *removeCollector;
@property (strong, nonatomic) NSMutableArray *positioningTmpArray;

@property (weak, nonatomic) UILabel *historyTextField;

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

        [self addHistoryView];
    }

    return self;
}

- (void)addHistoryView {
    UILabel *field = [[UILabel alloc] initWithFrame:
            CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    field.text = @"HISTORY =>";
    field.textColor = [UIColor colorWithWhite:1 alpha:0.2];
    field.layer.shadowColor = [[UIColor blackColor] CGColor];
    field.layer.shadowOpacity = 1;
    field.layer.shadowOffset = CGSizeMake(-3, 0);
    field.layer.shadowRadius = 0;
    field.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:18];
    [field sizeToFit];

    CGPoint center = self.center;
    center.y = self.bounds.size.height / 3;
    field.center = center;

    [field.layer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)-M_PI_2)];
    [self addSubview:field];
    self.historyTextField = field;
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
    NSInteger snapIndex = [self snapIndexForTouch:touch];
    if (snapIndex >= 0 && snapIndex != _lastNotifiedHistoryPosition){
        _lastNotifiedHistoryPosition = snapIndex;
        [self notifyChange];
    }
    return YES;
}

- (void)notifyChange {
    FFGame *game = [[FFGamesCore instance] gameWithId:self.activeGameId];
    [game goBackInHistory:_lastNotifiedHistoryPosition];
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
                    INTER_STEP_MARGIN/2.0)
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

    FFGame *game = [[FFGamesCore instance] gameWithId:self.activeGameId];
    NSArray *history = game.history;

    CGFloat topY = 0;

    [self.positioningTmpArray removeAllObjects];

    for (NSUInteger i = 0; i < history.count; i++){
        if (topY > self.bounds.size.height) break;  // done. Anything more would not be on the screen

        FFHistoryStep *step = [history objectAtIndex:i];

        if (![self.stepViewsById objectForKey:step.id]){
            UIView *stepView = [[UIView alloc] initWithFrame:
                    CGRectMake((self.bounds.size.width- STEP_SYMBOL_SIZE)/2, -100,
                            STEP_SYMBOL_SIZE, STEP_SYMBOL_SIZE)];
            [self setShapeForView:stepView forStep:step];

            [self addSubview:stepView];
            [self.stepViewsById setObject:stepView forKey:step.id];
        } else {
            [self.removeCollector removeObjectForKey:step.id];
        }

        [self.positioningTmpArray addObject:[self.stepViewsById objectForKey:step.id]];
        topY += INTER_STEP_MARGIN;
    }

    for (NSString *key in self.removeCollector) {
        UIView *toRemove = [self.stepViewsById objectForKey:key];
        [self.stepViewsById removeObjectForKey:key];

        [UIView animateWithDuration:0.3 animations:^{
            CGPoint centerPoint = toRemove.center;
            centerPoint.x += self.bounds.size.width/2;
            toRemove.center = centerPoint;
            toRemove.alpha = 0;
        } completion:^(BOOL finished) {
            [toRemove removeFromSuperview];
        }];
    }

    float alpha = 1;
    CGPoint centerPoint = CGPointMake(
//            self.bounds.size.width/2 - 4,
            self.bounds.size.width/2,
            self.bounds.size.width/2);
    for (NSUInteger i = 0; i < self.positioningTmpArray.count; i++){
        UIView *stepView = [self.positioningTmpArray objectAtIndex:i];

        [UIView animateWithDuration:0.3 animations:^{
            stepView.center = centerPoint;
            stepView.alpha = i < game.currentHistoryBackSteps ? alpha/2.0 : alpha;
        }];

        centerPoint = CGPointMake(centerPoint.x, centerPoint.y + INTER_STEP_MARGIN);
        alpha -= 0.05;
    }

    // and position the history text
    centerPoint.y += self.historyTextField.bounds.size.width/2 - 10;
    [UIView animateWithDuration:0.3 animations:^{
        self.historyTextField.center = centerPoint;
    }];
}

- (void)setShapeForView:(UIView *)view forStep:(FFHistoryStep *)step {
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
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
#import "UIColor+FFColors.h"
#import "FFToast.h"

#define INTER_STEP_MARGIN 42.0
#define STEP_SYMBOL_SIZE 28.0


@interface FFChallengeHistorySliderView ()
@property (strong, nonatomic) NSMutableDictionary *stepViewsById;
@property (strong, nonatomic) NSMutableDictionary *removeCollector;
@property (strong, nonatomic) NSMutableArray *positioningTmpArray;

@property (weak, nonatomic) UIButton *historyTextField;
@property (weak, nonatomic) UIView *nowThumb;

@end


@implementation FFChallengeHistorySliderView {
    NSInteger _lastNotifiedHistoryPosition;
    CGFloat _interStepDelta;
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

        _interStepDelta = INTER_STEP_MARGIN;

        [self addHistoryTextField];
        [self addNowThumbView];
    }

    return self;
}

- (void)addNowThumbView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width,
            STEP_SYMBOL_SIZE+8)];
    view.layer.backgroundColor = [[UIColor colorWithHue:0.7 saturation:0.8 brightness:0.8 alpha:1] CGColor];
    view.layer.borderColor = [[UIColor colorWithHue:0.7 saturation:0.8 brightness:0.8 alpha:0.5] CGColor];
    view.layer.cornerRadius = 4;
    view.layer.borderWidth = 4;
    view.userInteractionEnabled = NO;

    [self addSubview:view];
    self.nowThumb = view;
}

- (void)addHistoryTextField {
    UIButton *field = [[UIButton alloc] initWithFrame:
            CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [field setTitle:@"HISTORY =>" forState:UIControlStateNormal];
    [field setTitleColor:[UIColor colorWithWhite:1 alpha:0.2] forState:UIControlStateNormal];
    [field setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateSelected];
    field.titleLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:18];
    field.layer.shadowColor = [[UIColor blackColor] CGColor];
    field.layer.shadowOpacity = 1;
    field.layer.shadowOffset = CGSizeMake(-3, 0);
    field.layer.shadowRadius = 0;
    [field addTarget:self action:@selector(historyTapped:) forControlEvents:UIControlEventTouchUpInside];
    [field sizeToFit];

    CGPoint center = self.center;
    center.y = self.bounds.size.height / 3;
    field.center = center;

    [field.layer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)-M_PI_2)];
    [self addSubview:field];
    self.historyTextField = field;
}

- (void)historyTapped:(id)historyTapped {
    [[FFToast make:NSLocalizedString(@"history_explanation", nil)] show];
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
    }
    return YES;
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
                    _interStepDelta/2.0)
                    / _interStepDelta);

    index = MIN(index, historySize-1);

    return index;
}

- (void)didAppear {
    [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(gameChanged) name:kFFNotificationGameChanged object:nil];
}

- (void)gameChanged {
    [self repositionStepViews];
    [self checkForFailedAttempt];
}

- (void)checkForFailedAttempt {
    FFGame *game = [[FFGamesCore instance] gameWithId:self.activeGameId];

    if (game.currentHistoryBackSteps==0 && ![game stillSolvable]){
        NSArray *history = game.history;
        for (NSUInteger i = 0; i < history.count; i++){
            FFHistoryStep *step = [history objectAtIndex:i];
            UIView *stepView = [self.stepViewsById objectForKey:step.id];
            if (stepView){
                [self performSelector:@selector(pling:) withObject:stepView afterDelay:i*0.08];
            }
        }
    }

}

- (void)pling:(UIView *)view {
    [view.layer setAffineTransform:CGAffineTransformMakeScale(1.7, 2)];
    [UIView animateWithDuration:0.2 animations:^{
        [view.layer setAffineTransform:CGAffineTransformIdentity];
    }];
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

    _interStepDelta = MIN(INTER_STEP_MARGIN, self.bounds.size.height / MAX(1,history.count));
    [self.positioningTmpArray removeAllObjects];

    for (NSUInteger i = 0; i < history.count; i++){
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
        topY += _interStepDelta;
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
            self.bounds.size.width/2,
            self.bounds.size.width/2);
    for (NSUInteger i = 0; i < self.positioningTmpArray.count; i++){
        UIView *stepView = [self.positioningTmpArray objectAtIndex:i];

        [UIView animateWithDuration:0.3 animations:^{
            stepView.center = centerPoint;
            stepView.alpha = i < game.currentHistoryBackSteps ? alpha/2.0 : alpha;
        }];

        centerPoint = CGPointMake(centerPoint.x, centerPoint.y + _interStepDelta);
        alpha -= 0.05;
    }

    // position the 'now' thumb
    CGFloat thumbTargetCenterY = self.bounds.size.width/2
            + game.currentHistoryBackSteps * _interStepDelta;
    [UIView animateWithDuration:0.1 animations:^{
        CGPoint center = self.nowThumb.center;
        center.y = thumbTargetCenterY;
        self.nowThumb.center = center;
    }];

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
    CGPathRelease(path);
}

@end
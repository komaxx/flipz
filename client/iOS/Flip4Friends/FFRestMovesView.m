//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/27/13.
//


#import "FFRestMovesView.h"
#import "FFGame.h"
#import "FFGamesCore.h"

#define DOT_SIZE 16

@interface FFRestMovesView ()

@property (nonatomic, copy) NSString *activeGameId;
@property (nonatomic, strong) NSMutableArray *dots;

@end


@implementation FFRestMovesView {
    int _stepsLeft;
    int _maxSteps;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.dots = [[NSMutableArray alloc] initWithCapacity:5];
    }

    return self;
}

- (void)didAppear {
    [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(gameChanged:) name:kFFNotificationGameChanged object:nil];
}

- (void)didDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setActiveGame:(FFGame *)game {
    self.activeGameId = game.Id;
    [self updateWithGame:game];
}

- (void)gameChanged:(NSNotification *)notification {
    NSString *changedGameID = [notification.userInfo objectForKey:kFFNotificationGameChanged_gameId];
    if ([changedGameID isEqualToString:self.activeGameId]) {
        FFGame *game = [[FFGamesCore instance] gameWithId:changedGameID];
        [self updateWithGame:game];
    }
}

- (void)updateWithGame:(FFGame *)game {
    int nuMaxSteps = game.maxChallengeMoves;
    int nuStepsLeft = nuMaxSteps - [game challengeMovesPlayed];

    if (nuMaxSteps!=_maxSteps || nuStepsLeft!=_stepsLeft){
        _maxSteps = MAX(nuMaxSteps, 0);
        _stepsLeft = MAX(nuStepsLeft, 0);

        [self repositionSteps];
    }
}

- (void)repositionSteps {
    while (self.dots.count > _stepsLeft){
        [self removeDot:self.dots.lastObject];
        [self.dots removeLastObject];
    }

    CGFloat xStep = self.bounds.size.width / (_maxSteps+1);
    CGPoint nowCenter = CGPointMake(xStep, CGRectGetMidY(self.bounds));

    UIView *dot;
    for (NSUInteger i = 0; i < _stepsLeft; i++){
        if (self.dots.count <= i){
            dot = [self makeDot];
            [self.dots addObject:dot];
            [self addSubview:dot];
        } else {
            dot = [self.dots objectAtIndex:i];
        }

        [UIView animateWithDuration:0.2 animations:^{
            dot.center = nowCenter;
        }];

        nowCenter.x += xStep;
    }

    NSLog(@"repositioned for %i/%i", _stepsLeft, _maxSteps);
}

- (UIView *)makeDot {
    CGRect startRec = CGRectMake(-20, self.bounds.size.height + 20, DOT_SIZE, DOT_SIZE);
    UIView *nuDot = [[UIView alloc] initWithFrame:startRec];

    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    [nuDot.layer addSublayer:shapeLayer];

    shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
    shapeLayer.shadowOffset = CGSizeMake(0, 3);
    shapeLayer.shadowOpacity = 1;
    shapeLayer.shadowRadius = 0;
    shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
    shapeLayer.lineCap = @"round";

    CGMutablePathRef path = CGPathCreateMutable();

    shapeLayer.lineWidth = 4;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    CGPathAddArc(path, &CGAffineTransformIdentity, DOT_SIZE/2, DOT_SIZE/2,
            DOT_SIZE/2, (CGFloat) M_PI_2*1.2, -(CGFloat) M_PI_2*1.0, YES);
    [shapeLayer setPath:path];
    CGPathRelease(path);

    return nuDot;
}

- (void)removeDot:(UIView *)toRemove {
    [UIView animateWithDuration:0.3 animations:^{
        toRemove.alpha = 0;

        CGPoint point = toRemove.center;
        point.y = self.bounds.size.height;
        toRemove.center = point;
    }];
}

@end
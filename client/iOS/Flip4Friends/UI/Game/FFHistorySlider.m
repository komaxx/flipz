//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 8/12/13.
//


#import "FFHistorySlider.h"
#import "FFGame.h"
#import "FFGamesCore.h"
#import "UIColor+FFColors.h"
#import "FFGameViewController.h"


#define INTER_STEP_MARGIN 34.0

@implementation FFHistorySlider {
}
@synthesize boardView = _boardView;
@synthesize activeGameId = _activeGameId;


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }

    return self;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    NSInteger snapIndex = [self snapIndexForTouch:touch];
    if (snapIndex >= 0){
        [self.delegate showHistoryStartingFromStepsBack:snapIndex];
        return YES;
    }
    return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    NSInteger snapIndex = [self snapIndexForTouch:touch];
    if (snapIndex >= 0){
        [self.delegate showHistoryStartingFromStepsBack:snapIndex];
        return YES;
    }
    return NO;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if ([self isTracking]) [self.delegate hideHistory];
}

- (NSInteger)snapIndexForTouch:(UITouch *)touch {
    if (!self.activeGameId) return -1;
    FFGame *game = [[FFGamesCore instance] gameWithId:self.activeGameId];
    NSInteger historySize = game.moveHistory.count;
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
            addObserver:self selector:@selector(setNeedsDisplay) name:kFFNotificationGameChanged object:nil];
}

- (void)didDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)panEvent:(UIPanGestureRecognizer *)panRecognizer {
    NSLog(@"panning!!");
}

- (void)drawRect:(CGRect)rect {
    if (!self.activeGameId) return;
    FFGame *game = [[FFGamesCore instance] gameWithId:self.activeGameId];
    if (!game || game.moveHistory.count < 1) return;

    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);

    CGContextSetLineWidth(c, 3);

    CGFloat midX = CGRectGetMidX(self.bounds);

    // current point in time
    CGContextAddEllipseInRect(c, CGRectMake(2, 2, self.bounds.size.width-4, self.bounds.size.width-4));
    CGContextAddEllipseInRect(c, CGRectMake(midX-2, midX-2, 4, 4));
    CGContextSetStrokeColorWithColor(c, [[UIColor whiteColor] CGColor]);
    CGContextSetShadowWithColor(c, CGSizeMake(0, 5), 1,
            [[self colorForMove:[game.moveHistory objectAtIndex:game.moveHistory.count-1] inGame:game] CGColor]);
    CGContextDrawPath(c, kCGPathStroke);

    // history
    for (int i = 0; i < (int)(game.moveHistory.count)-1; i++){
        CGContextAddEllipseInRect(c, CGRectMake(midX-5, midX-5 + (i+1)*INTER_STEP_MARGIN, 10, 10));
        CGContextSetStrokeColorWithColor(c, [[UIColor colorWithWhite:1 alpha:(1- (i+1)*0.12)] CGColor]);
        CGContextSetShadowWithColor(c, CGSizeMake(0, 5), 1,
                [[self colorForMove:[game.moveHistory objectAtIndex:game.moveHistory.count-(i+2)] inGame:game] CGColor]);
        CGContextDrawPath(c, kCGPathStroke);
    }

    CGContextRestoreGState(c);
}

- (UIColor *)colorForMove:(FFMove *)move inGame:(FFGame *)game {
    if ([game.player1.doneMoves objectForKey:move.Pattern.Id]){
        return [UIColor player1color];
    } else {
        return [UIColor player2color];
    }
}


@end
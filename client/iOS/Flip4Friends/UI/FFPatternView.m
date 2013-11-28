//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/30/13.
//


#import <QuartzCore/QuartzCore.h>
#import "FFPatternView.h"
#import "UIColor+FFColors.h"
#import "FFPatternGenerator.h"

#define DEFAULT_PATTERN_SIZE 4

@interface FFPatternView ()

@property (weak, nonatomic) UIView *activeOverlayView;
@property (weak, nonatomic) UIView *historyOverlayView;

@end

@implementation FFPatternView {
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;

        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        self.showsTouchWhenHighlighted = YES;

        UIView *historyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        historyView.alpha = 0.8;
        historyView.hidden = YES;
        historyView.userInteractionEnabled = NO;
        [self addSubview:historyView];
        self.historyOverlayView = historyView;

        UIView *highView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        highView.backgroundColor = [UIColor movePatternBack];
        highView.hidden = YES;
        highView.userInteractionEnabled = NO;
        [self addSubview:highView];
        self.activeOverlayView = highView;

        [self setViewState:kFFPatternViewStateAlreadyPlayed];
        [self setViewState:kFFPatternViewStateNormal];
    }

    return self;
}

- (void)setForPlayer2:(BOOL)forPlayer2 {
    _forPlayer2 = forPlayer2;
    self.activeOverlayView.backgroundColor = forPlayer2 ? [UIColor movePattern2Back] : [UIColor movePatternBack];
}


- (void)setPattern:(FFPattern *)pattern {
    _pattern = pattern;
    [self setNeedsDisplay];
}

- (void)setViewState:(FFPatternViewState)viewState {
    if (_viewState == viewState) return;

    if (viewState == kFFPatternViewStateNormal){
        self.layer.borderWidth = 0;
        self.layer.borderColor = [[UIColor clearColor] CGColor];
        self.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1];
        [self.layer removeAllAnimations];
        self.activeOverlayView.hidden = YES;
    } else if (viewState == kFFPatternViewStateActive){
        self.activeOverlayView.backgroundColor = [UIColor clearColor];
        self.activeOverlayView.layer.borderColor = [[UIColor clearColor] CGColor];
        self.activeOverlayView.layer.borderWidth = 5;
        self.activeOverlayView.hidden = NO;
        [UIView animateWithDuration:0.5 delay:0
                            options:(UIViewAnimationOptionCurveEaseInOut
                                    |UIViewAnimationOptionAutoreverse
                                    |UIViewAnimationOptionRepeat)
                         animations:^{
                             self.activeOverlayView.backgroundColor = [UIColor movePatternBack];
                             self.activeOverlayView.layer.borderColor = [[UIColor movePatternBack] CGColor];
                         } completion:nil];
    } else if (viewState == kFFPatternViewStateAlreadyPlayed){
        self.layer.borderWidth = 2;
        self.layer.borderColor = [[UIColor patternBorder_alreadyPlayed] CGColor];
        self.backgroundColor = [UIColor patternBack_alreadyPlayed];
        [self.layer removeAllAnimations];
        self.activeOverlayView.hidden = YES;
    }

    [self setNeedsDisplay];

    _viewState = viewState;
}

- (void)drawRect:(CGRect)rect {
    if (!self.pattern) return;

    int size = MAX(self.pattern.SizeX, self.pattern.SizeY);
    size = MAX(size, DEFAULT_PATTERN_SIZE);

    CGFloat squareSize = self.bounds.size.width / (size + 1.0);

    [self drawInactiveTilesWithSize:squareSize];
    [self drawRotationRingInRect:rect];
    [self drawActiveTitlesWithSize:squareSize];
}

- (void)drawRotationRingInRect:(CGRect)rect {
    if ([self.pattern differingOrientations] < 2) return;

    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(c, CGRectInset(rect, 2, 2));

    if (self.viewState == kFFPatternViewStateAlreadyPlayed){
        CGContextSetStrokeColorWithColor(c, [[UIColor colorWithWhite:0.1 alpha:0.3] CGColor]);
    } else {
        CGContextSetStrokeColorWithColor(c, [[UIColor colorWithWhite:0.2 alpha:0.5] CGColor]);
    }
    CGContextSetLineWidth(c, 3);
    CGContextDrawPath(c, kCGPathStroke);
}

- (void)drawInactiveTilesWithSize:(CGFloat)squareSize {
    CGContextRef c = UIGraphicsGetCurrentContext();

    int size = MAX(self.pattern.SizeX, self.pattern.SizeY);
    size = MAX(size, DEFAULT_PATTERN_SIZE) + 1;

    CGFloat xOffset = (size-self.pattern.SizeX)%2==0 ? 0 : -squareSize/2.0;
    CGFloat yOffset = (size-self.pattern.SizeY)%2==0 ? 0 : -squareSize/2.0;

    NSInteger count = (NSInteger) ceilf(self.bounds.size.width / squareSize) + 1;
    for (int y = 0; y < count; y ++){
        for (int x = y%2==0?0:1; x < count; x+=2){
            CGContextAddRect(c, CGRectMake(xOffset + x*squareSize, yOffset + y*squareSize, squareSize, squareSize));
        }
    }

    if (self.viewState == kFFPatternViewStateAlreadyPlayed){
        CGContextSetFillColorWithColor(c, [[UIColor colorWithWhite:0.2 alpha:0.1] CGColor]);
    } else {
        CGContextSetFillColorWithColor(c, [[UIColor colorWithWhite:0.65 alpha:1] CGColor]);
    }
    CGContextFillPath(c);
}

- (void)drawActiveTitlesWithSize:(CGFloat)squareSize {
    CGContextRef c = UIGraphicsGetCurrentContext();

    if (self.viewState == kFFPatternViewStateAlreadyPlayed){
        CGContextSetFillColorWithColor(c, [[UIColor colorWithWhite:0.4 alpha:0.5] CGColor]);
        CGContextSetStrokeColorWithColor(c, [[UIColor colorWithWhite:0.4 alpha:0.8] CGColor]);
    } else {
        CGContextSetFillColorWithColor(c, self.forPlayer2 ? [[UIColor movePattern2Back] CGColor] : [[UIColor movePatternBack] CGColor]);
        CGContextSetStrokeColorWithColor(c, self.forPlayer2 ? [[UIColor movePattern2Border] CGColor] : [[UIColor movePatternBorder] CGColor]);
    }
    CGContextSetShadowWithColor(c, CGSizeMake(0, 1), 2, [[UIColor colorWithWhite:0.2 alpha:0.5] CGColor]);
    CGContextSetLineCap(c, kCGLineCapRound);
    CGContextSetLineWidth(c, 2.5);

    CGFloat baseX = (self.bounds.size.width - self.pattern.SizeX*squareSize)/2;
    CGFloat baseY = (self.bounds.size.height - self.pattern.SizeY*squareSize)/2;

    CGRect fillRect = CGRectMake(0, 0, squareSize-4, squareSize-4);

    for (FFCoord *coord in self.pattern.Coords) {
        fillRect.origin.x = baseX + coord.x*squareSize + 2;
        fillRect.origin.y = baseY + coord.y*squareSize + 2;

        CGContextFillRect(c, fillRect);
        CGContextStrokeRect(c, fillRect);
    }
}

- (void)removeYourself {
    [self performSelector:@selector(removeFromSuperview) withObject:self afterDelay:0.33];

    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        // move away?
    }];
}

- (void)positionAtX:(CGFloat)x andY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.x = x;
    frame.origin.y = y;

    [UIView animateWithDuration:0.25 animations:^{
        self.frame = frame;
    }];
}

- (void)setHistoryHighlighted:(BOOL)historyHighlighted asStepBack:(NSInteger)stepBack{
    self.historyOverlayView.backgroundColor =
            [UIColor colorWithPatternImage:[FFPatternGenerator createHistoryMoveOverlayPatternForStep:stepBack]];
    self.historyOverlayView.hidden = !historyHighlighted;
}
@end
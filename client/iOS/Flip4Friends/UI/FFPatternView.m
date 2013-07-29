//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/30/13.
//


#import <QuartzCore/QuartzCore.h>
#import "FFPatternView.h"
#import "UIColor+FFColors.h"

#define DEFAULT_PATTERN_SIZE 3

@interface FFPatternView ()

@property (strong, nonatomic) NSMutableArray *tileSubLayers;

@end

@implementation FFPatternView {
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tileSubLayers = [[NSMutableArray alloc] initWithCapacity:5];

        self.opaque = YES;

        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10;
        self.layer.opaque = YES;

        [self setBackgroundImage:[UIImage imageNamed:@"Default.png"] forState:UIControlStateHighlighted];
        [self setBackgroundImage:[UIImage imageNamed:@"Default.png"] forState:UIControlStateSelected];

        self.showsTouchWhenHighlighted = YES;

        [self setViewState:kFFPatternViewStateNormal];
    }

    return self;
}

- (void)setPattern:(FFPattern *)pattern {
    _pattern = pattern;
    [self updatePatternSublayers];
}

- (void)setViewState:(FFPatternViewState)viewState {
    if (viewState == kFFPatternViewStateNormal){
        self.layer.borderWidth = 0;
        self.layer.borderColor = [[UIColor clearColor] CGColor];
        self.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1];
        [self.layer removeAllAnimations];
    } else if (viewState == kFFPatternViewStateActive){
        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1];
        self.layer.borderColor = [[UIColor clearColor] CGColor];
        self.layer.borderWidth = 3;
        [UIView animateWithDuration:0.4 delay:0
                            options:(UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat)
                         animations:^{
                             self.backgroundColor = [UIColor movePatternBack];
                             self.layer.borderColor = [[UIColor movePatternBack] CGColor];
                         } completion:nil];
    } else if (viewState == kFFPatternViewStateAlreadyPlayed){
        self.layer.borderWidth = 2;
        self.layer.borderColor = [[UIColor movePatternBorder_removing] CGColor];
        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1];
        [self.layer removeAllAnimations];
    }

    _viewState = viewState;
}


- (void)updatePatternSublayers {
    for (CALayer *layer in self.tileSubLayers) {
        [layer removeFromSuperlayer];
    }
    [self.tileSubLayers removeAllObjects];

    if (!self.pattern) return;

    int size = self.pattern.SizeX;
    if (self.pattern.SizeY > size) size = self.pattern.SizeY;
    if (DEFAULT_PATTERN_SIZE > size) size = DEFAULT_PATTERN_SIZE;

    CGFloat squareSize = self.bounds.size.width / (size + 2.0);

    [self addInactiveTilesWithSize:squareSize];
    [self addActiveTitlesWithSize:squareSize];

    [self.layer setSublayers:self.tileSubLayers];
}

- (void)addInactiveTilesWithSize:(CGFloat)squareSize {
    CGFloat xOffset = self.pattern.SizeX%2==1 ? squareSize/2.0 : 0;
    CGFloat yOffset = self.pattern.SizeY%2==1 ? squareSize/2.0 : 0;

    NSInteger count = (NSInteger) ceilf(self.bounds.size.width / squareSize) + 1;
    for (int y = 0; y < count; y ++){
        for (int x = y%2==0?0:1; x < count; x+=2){
            CALayer *subLayer = [[CALayer alloc] init];
            subLayer.borderColor = [[UIColor colorWithWhite:0.65 alpha:1] CGColor];
            subLayer.borderWidth = 1;
            subLayer.cornerRadius = 2;
            subLayer.masksToBounds = YES;

            subLayer.bounds = CGRectMake(0, 0, squareSize, squareSize);
            subLayer.position = CGPointMake(xOffset + x*squareSize, yOffset + y*squareSize);

            [self.tileSubLayers addObject:subLayer];
        }
    }
}

- (void)addActiveTitlesWithSize:(CGFloat)squareSize {
    CGFloat baseX = (self.bounds.size.width - self.pattern.SizeX*squareSize)/2;
    CGFloat baseY = (self.bounds.size.height - self.pattern.SizeY*squareSize)/2;

    for (FFCoord *coord in self.pattern.Coords) {
        CALayer *subLayer = [[CALayer alloc] init];
        subLayer.borderColor = [[UIColor movePatternBorder] CGColor];
        subLayer.backgroundColor = [[UIColor movePatternBack] CGColor];
        subLayer.borderWidth = 2;
        subLayer.cornerRadius = 3;

        subLayer.shadowOffset = CGSizeMake(0, 1);
        subLayer.shadowOpacity = 0.7;
        subLayer.shadowRadius = 1;
        subLayer.shadowColor = [[UIColor blackColor] CGColor];

        subLayer.bounds = CGRectMake(1, 1, squareSize-2, squareSize-2);
        subLayer.position = CGPointMake(baseX + (coord.x+0.5)*squareSize, baseY + (coord.y+0.5)*squareSize - 1);

        [self.tileSubLayers addObject:subLayer];
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

@end
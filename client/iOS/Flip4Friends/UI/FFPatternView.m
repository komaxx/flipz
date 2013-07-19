//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/30/13.
//


#import <QuartzCore/QuartzCore.h>
#import "FFPatternView.h"

#define DEFAULT_PATTERN_SIZE 4

@interface FFPatternView ()

@property (strong, nonatomic) NSMutableArray *tileSubLayers;

@end

@implementation FFPatternView {
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tileSubLayers = [[NSMutableArray alloc] initWithCapacity:5];
        self.backgroundColor = [UIColor colorWithWhite:0.6 alpha:0.2];

        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10;

        self.layer.borderWidth = 2;
        self.layer.borderColor = [[UIColor colorWithWhite:0.55 alpha:0.3] CGColor];

        [self setBackgroundImage:[UIImage imageNamed:@"Default.png"] forState:UIControlStateHighlighted];
        [self setBackgroundImage:[UIImage imageNamed:@"Default.png"] forState:UIControlStateSelected];

        self.showsTouchWhenHighlighted = YES;
    }

    return self;
}

- (void)setPattern:(FFPattern *)pattern {
    _pattern = pattern;
    [self updatePatternSublayers];
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
    CGFloat xOffset = self.pattern.SizeX%2==0 ? squareSize/2.0 : 0;
    CGFloat yOffset = self.pattern.SizeY%2==0 ? squareSize/2.0 : 0;

    NSInteger count = (NSInteger) ceilf(self.bounds.size.width / squareSize);
    for (int y = 0; y < count; y ++){
        for (int x = y%2==0?0:1; x < count; x+=2){
            CALayer *subLayer = [[CALayer alloc] init];
            subLayer.borderColor = [[UIColor lightGrayColor] CGColor];
            subLayer.borderWidth = 1;
            subLayer.cornerRadius = 3;
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
        subLayer.borderColor = [[UIColor cyanColor] CGColor];
        subLayer.backgroundColor = [[UIColor colorWithRed:0 green:1 blue:1 alpha:0.7] CGColor];
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
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

    CGFloat baseX = (self.bounds.size.width - self.pattern.SizeX*squareSize)/2;
    CGFloat baseY = (self.bounds.size.height - self.pattern.SizeY*squareSize)/2;

    NSMutableArray *nuSubLayers = [[NSMutableArray alloc] initWithCapacity:self.pattern.Coords.count];
    for (FFCoord *coord in self.pattern.Coords) {
        CALayer *subLayer = [[CALayer alloc] init];
        subLayer.borderColor = [[UIColor redColor] CGColor];
        subLayer.borderWidth = 2;
        subLayer.cornerRadius = 3;
        subLayer.masksToBounds = YES;

        subLayer.bounds = CGRectMake(0, 0, squareSize, squareSize);
        subLayer.position = CGPointMake(baseX + (coord.x+0.5)*squareSize, baseY + (coord.y+0.5)*squareSize);

        [nuSubLayers addObject:subLayer];
    }
    [self.layer setSublayers:nuSubLayers];
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
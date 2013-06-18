//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/14/13.
//


#import "FFTileView.h"

@implementation FFTileView {
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0;
    }

    return self;
}


- (void)updateFromTile:(FFTile *)tile {
    self.backgroundColor = tile.color==0 ? [UIColor blackColor] : [UIColor whiteColor];

    // TODO: flip to new color if necessary
}

- (void)positionAt:(CGRect)rect {
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = rect;
        self.alpha = 1;         // will make the tile appear in case it was invisible before.
    }];
}


- (void)removeYourself {
    CGRect targetRect = CGRectMake(CGRectGetMidX(self.superview.bounds), CGRectGetMidY(self.superview.bounds), 1, 1);
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
        self.frame = targetRect;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];

    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.26];
}

@end
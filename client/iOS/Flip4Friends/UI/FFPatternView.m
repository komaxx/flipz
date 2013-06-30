//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/30/13.
//


#import "FFPatternView.h"


@implementation FFPatternView {
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }

    return self;
}

- (void)setPattern:(FFPattern *)pattern {
    _pattern = pattern;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (!self.pattern) return;
}


- (void)removeYourself {
    [self performSelector:@selector(removeFromSuperview) withObject:self afterDelay:0.33];

    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        self.contentScaleFactor = 5;
        // move avay?
    }];
}
@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/20/13.
//


#import "FFGrayBackedLabel.h"

#define RADIUS 10

@implementation FFGrayBackedLabel {
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.layer.cornerRadius = RADIUS;
        self.backgroundColor = [UIColor clearColor];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = RADIUS;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:0 alpha:0.2] CGColor]);
    CGContextFillRect(context, rect);

    CGFloat hue = 0;
    CGFloat alpha = 0.8;

    NSArray *colors = @[
            [UIColor colorWithHue:hue saturation:0. brightness:0.0 alpha:alpha],
            [UIColor colorWithHue:hue saturation:0. brightness:0.1 alpha:alpha],
            [UIColor colorWithHue:hue saturation:0. brightness:0.2 alpha:alpha],
            [UIColor colorWithHue:hue saturation:0. brightness:0.3 alpha:alpha],
    ];

    int count = MIN(colors.count, (NSInteger)(self.bounds.size.height/(2* RADIUS)));

    CGRect circleRect = CGRectMake(0, 0, 2*RADIUS, 2*RADIUS);
    for (NSUInteger i = 0; i < count; i++){
        circleRect.origin.x = 0;
        circleRect.origin.y = i*2*RADIUS;
        for (int x = 0; x <= rect.size.width; x+=2*RADIUS){
            CGContextAddEllipseInRect(context, circleRect);
            circleRect.origin.x = x;
        }
        CGContextSetFillColorWithColor(context, [(UIColor *)[colors objectAtIndex:i] CGColor]);
        CGContextFillPath(context);
    }

    CGContextRestoreGState(context);

    [self drawTextInRect:rect];
}


@end
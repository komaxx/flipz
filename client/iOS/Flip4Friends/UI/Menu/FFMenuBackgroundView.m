//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/29/13.
//


#import <QuartzCore/QuartzCore.h>
#import "FFMenuBackgroundView.h"

#define RADIUS 10

@implementation FFMenuBackgroundView {

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.opaque = NO;
        self.backgroundColor =
                [UIColor colorWithHue:0.70 saturation:0.4 brightness:0.4 alpha:0.9];
        self.layer.cornerRadius = RADIUS;
        self.layer.borderWidth = RADIUS/2;
        self.layer.borderColor = [[UIColor colorWithHue:0.70 saturation:0.5 brightness:0.5 alpha:0.1] CGColor];
        self.layer.masksToBounds = YES;

    }

    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    NSArray *colors = @[
            [UIColor colorWithHue:0.7 saturation:0.8 brightness:0.8 alpha:1],
            [UIColor colorWithHue:0.7 saturation:0.7 brightness:0.8 alpha:0.9],
            [UIColor colorWithHue:0.7 saturation:0.6 brightness:0.8 alpha:0.8],
            [UIColor colorWithHue:0.7 saturation:0.5 brightness:0.8 alpha:0.7],
//            [UIColor colorWithHue:0.20 saturation:0.4 brightness:0.4 alpha:1],
    ];

    CGRect circleRect = CGRectMake(0, 0, 2*RADIUS, 2*RADIUS);
    for (int i = 0; i < colors.count; i++){
        circleRect.origin.x = 0;
        circleRect.origin.y = i*2*RADIUS;
        for (int x = 0; x <= rect.size.width; x+=2*RADIUS){
            CGContextAddEllipseInRect(context, circleRect);
            circleRect.origin.x = x;
        }
        CGContextSetFillColorWithColor(context, [(UIColor *)[colors objectAtIndex:i] CGColor]);
        CGContextFillPath(context);

        circleRect.origin.x = 0;
        circleRect.origin.y = self.bounds.size.height - (i+1)*2*RADIUS;
        for (int x = 0; x <= rect.size.width; x+=2*RADIUS){
            CGContextAddEllipseInRect(context, circleRect);
            circleRect.origin.x = x;
        }
        CGContextSetFillColorWithColor(context, [(UIColor *)[colors objectAtIndex:i] CGColor]);
        CGContextFillPath(context);
    }

    CGContextRestoreGState(context);
}

@end
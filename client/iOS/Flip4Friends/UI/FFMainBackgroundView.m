//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 10/4/13.
//


#import "FFMainBackgroundView.h"

#define RADIUS 10

@interface FFMainBackgroundView ()
@end

@implementation FFMainBackgroundView {

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.opaque = YES;
        self.backgroundColor =
                [UIColor colorWithHue:0.20 saturation:0. brightness:0.25 alpha:1];
//        self.layer.cornerRadius = RADIUS;
//        self.layer.borderWidth = RADIUS/2;
//        self.layer.borderColor = [[UIColor colorWithHue:0.70 saturation:0. brightness:0.5 alpha:0.3] CGColor];
        self.layer.masksToBounds = YES;

    }

    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    NSArray *colors = @[
            [UIColor colorWithHue:0.4 saturation:0.3 brightness:0.1 alpha:0.275],
            [UIColor colorWithHue:0.4 saturation:0.3 brightness:0.1 alpha:0.25],
            [UIColor colorWithHue:0.4 saturation:0.3 brightness:0.1 alpha:0.225],
            [UIColor colorWithHue:0.4 saturation:0.2 brightness:0.1 alpha:0.2],
            [UIColor colorWithHue:0.4 saturation:0.2 brightness:0.1 alpha:0.15],
            [UIColor colorWithHue:0.4 saturation:0.1 brightness:0.1 alpha:0.1],
            [UIColor colorWithHue:0.4 saturation:0.1 brightness:0.1 alpha:0.075],
            [UIColor colorWithHue:0.4 saturation:0.1 brightness:0.1 alpha:0.05],

//            [UIColor colorWithHue:0.20 saturation:0.4 brightness:0.4 alpha:1],
    ];

    int count = MIN(colors.count, (NSInteger)(self.bounds.size.height/(2* RADIUS)/2));

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
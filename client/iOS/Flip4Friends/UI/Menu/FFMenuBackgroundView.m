//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/29/13.
//


#import "FFMenuBackgroundView.h"

#define RADIUS 10

@interface FFMenuBackgroundView ()
@end

@implementation FFMenuBackgroundView {

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self basicStyling];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self basicStyling];
    }

    return self;
}

- (void)basicStyling {
    self.opaque = NO;
    self.backgroundColor =
            [UIColor colorWithHue:0.70 saturation:0.4 brightness:0.4 alpha:0.9];
    self.layer.cornerRadius = RADIUS;
    self.layer.borderWidth = RADIUS/2;
    self.layer.borderColor = [[UIColor colorWithHue:0.70 saturation:0.5 brightness:0.8 alpha:0.3] CGColor];
    self.layer.masksToBounds = YES;
}



- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    NSArray *colors = @[
            [UIColor colorWithHue:0.7 saturation:0.8 brightness:0.8 alpha:1],
            [UIColor colorWithHue:0.7 saturation:0.7 brightness:0.8 alpha:0.9],
            [UIColor colorWithHue:0.7 saturation:0.6 brightness:0.8 alpha:0.8],
            [UIColor colorWithHue:0.7 saturation:0.5 brightness:0.8 alpha:0.7],
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

    // add center row?
    int rows = (NSInteger)(self.bounds.size.height/(2*RADIUS));
    if (count < colors.count && rows%2==1){
        circleRect.origin.x = 0;
        circleRect.origin.y = count*2* RADIUS;
        for (int x = 0; x <= rect.size.width; x+=2*RADIUS){
            CGContextAddEllipseInRect(context, circleRect);
            circleRect.origin.x = x;
        }
        CGContextSetFillColorWithColor(context, [(UIColor *)[colors objectAtIndex:count] CGColor]);
        CGContextFillPath(context);
    }


    CGContextRestoreGState(context);
}

@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/24/13.
//


#import "FFPatternGenerator.h"
#import "UIColor+FFColors.h"


@interface FFPatternGenerator()

@end

@implementation FFPatternGenerator {
}


+ (UIImage *)createBackgroundPattern {
//    CGRect rect = CGRectMake(0, 0, 64, 64);
//    // Create a 1 by 1 pixel context
//    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
//    CGContextRef c = UIGraphicsGetCurrentContext();
//
//    // actual drawing
//    CGContextSetFillColorWithColor(c, [[UIColor backgroundBasic] CGColor]);
//    CGContextFillRect(c, rect);
//
//
//
//    // done
//
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    CGContextRelease(c);
//    UIGraphicsEndImageContext();
//    return image;

    UIImage *ret = [UIImage imageNamed:@"back_pattern.png"];
    return ret;
}


+ (UIImage *)createHistoryMoveOverlayPatternForStep:(NSInteger)step {
    static NSMutableArray *cache = nil;
    if (!cache){
        cache = [[NSMutableArray alloc] initWithCapacity:5];
        int MAX_STEPS = 4;

        for (int i = 0; i < MAX_STEPS; i++){
            CGRect rect = CGRectMake(0, 0, 16, 16);

            UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
            CGContextRef c = UIGraphicsGetCurrentContext();

            // actual drawing
            CGContextSetLineWidth(c, 3 - i*0.8);

            if (i%2==0){
                for (int x = -16 + (i*2); x <= 16; x += 8){
                    CGContextMoveToPoint(c, x-10, -10);
                    CGContextAddLineToPoint(c, x+100, 100);
                }
            } else {
                for (int x = -24 + (i*2); x <= 24; x += 8){
                    CGContextMoveToPoint(c, x, 24);
                    CGContextAddLineToPoint(c, x+30, -6);
                }
            }


            UIColor *stepColor = [UIColor colorWithHue:(0.0 + i*90.0/360.0)
                       saturation:0.9
                       brightness:0.8
                            alpha:1 - i*0.15];
            CGContextSetStrokeColorWithColor(c, [stepColor CGColor]);

            CGContextSetShadowWithColor(c, CGSizeMake(0, 1), 0.5,
                    [[UIColor colorWithWhite:0.1 alpha:0.2] CGColor]);
            CGContextDrawPath(c, kCGPathStroke);

            // done
            [cache addObject:UIGraphicsGetImageFromCurrentImageContext()];
            UIGraphicsEndImageContext();
        }
    }

    return [cache objectAtIndex:MIN(cache.count - 1, step)];
}

@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/24/13.
//


#import "FFPatternGenerator.h"
#import "UIColor+FFColors.h"


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
@end
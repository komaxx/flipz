//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/22/13.
//


#import "UIColor+FFColors.h"

#define COLOR_MACRO(VAR,HEX_COLOR) if (!VAR) VAR = [UIColor colorFromHexString:HEX_COLOR]; return VAR;

@implementation UIColor (FFColors)


+ (UIColor *)randomColor {
    return [UIColor colorWithHue:(arc4random_uniform(1000) / 1000.0f) saturation:1 brightness:1 alpha:1];
}

static UIColor *backBasic;
+ (UIColor *)backgroundBasic { COLOR_MACRO(backBasic, @"333333") }
static UIColor *backFill1;
+ (UIColor *)backgroundFill1 { COLOR_MACRO(backFill1, @"666666") }
static UIColor *backFill2;
+ (UIColor *)backgroundFill2 { COLOR_MACRO(backFill2, @"999999") }


    static UIColor *movePatternBack;
+ (UIColor *)movePatternBack { COLOR_MACRO(movePatternBack, @"7835ED66") }
    static UIColor *movePatternBorder;
+ (UIColor *)movePatternBorder { COLOR_MACRO(movePatternBorder, @"7835EDFF") }
    static UIColor *movePatternBack_removal;
+ (UIColor *)movePatternBack_removing { COLOR_MACRO(movePatternBack_removal, @"D9525280") }
    static UIColor *movePatternBorder_removal;
+ (UIColor *)movePatternBorder_removing { COLOR_MACRO(movePatternBorder_removal, @"D95252FF") }




+ (UIColor *) colorFromHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                                                 [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                                                 [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                                                 [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }

    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];

    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
@end

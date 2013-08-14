//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/22/13.
//


#import <Foundation/Foundation.h>

@interface UIColor (FFColors)

+ (UIColor *)randomColor;

+ (UIColor *)backgroundBasic;

+ (UIColor *)backgroundFill1;

+ (UIColor *)backgroundFill2;


+ (UIColor *)movePatternBorder;
+ (UIColor *)movePatternBack;

+ (UIColor *)movePatternBorder_removing;
+ (UIColor *)movePatternBack_removing;


+ (UIColor *)patternBorder_alreadyPlayed;

+ (UIColor *)patternBack_alreadyPlayed;

+ (UIColor *)player1color;

+ (UIColor *)player2color;
@end
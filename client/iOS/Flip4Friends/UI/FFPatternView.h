//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/30/13.
//


#import <UIKit/UIKit.h>
#import "FFPattern.h"


@interface FFPatternView : UIButton

@property (strong, nonatomic) FFPattern* pattern;

- (void)removeYourself;
- (void)positionAtX:(CGFloat)x andY:(CGFloat)y;

@end
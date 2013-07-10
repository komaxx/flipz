//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/30/13.
//


#import <UIKit/UIKit.h>
#import "FFPattern.h"


@interface FFPatternView : UIView

@property (weak, nonatomic) FFPattern* pattern;

- (void)removeYourself;

- (void)positionAtX:(CGFloat)x andY:(CGFloat)y;
@end
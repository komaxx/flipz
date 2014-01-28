//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 1/23/14.
//


#import <Foundation/Foundation.h>
#import "FFMenuBackgroundView.h"


@interface FFLevelStrip : FFMenuBackgroundView

@property (nonatomic) CGFloat disappearTime;

+ (FFLevelStrip *)make:(NSInteger)number;

- (void)show;
@end
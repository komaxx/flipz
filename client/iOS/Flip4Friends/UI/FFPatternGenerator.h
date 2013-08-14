//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/24/13.
//


#import <Foundation/Foundation.h>


@interface FFPatternGenerator : NSObject
    + (UIImage *)createBackgroundPattern;
    + (UIImage *)createHistoryMoveOverlayPatternForStep:(NSInteger)step;
@end
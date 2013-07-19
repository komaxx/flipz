//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import <UIKit/UIKit.h>
#import "FFPattern.h"


@interface FFGameViewController : UIView

- (void)didAppear;

- (void)didDisappear;

- (void)setPatternSelectedForMove:(FFPattern *)pattern;

- (void)didLoad;
@end
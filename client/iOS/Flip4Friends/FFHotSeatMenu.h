//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/21/13.
//


#import <Foundation/Foundation.h>
#import "FFMenuBackgroundView.h"

@class FFMenuViewController;


@interface FFHotSeatMenu : FFMenuBackgroundView

@property(nonatomic, weak) FFMenuViewController *delegate;

- (void)hide:(BOOL)b;

@end
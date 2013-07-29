//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/29/13.
//


#import <Foundation/Foundation.h>

@class FFMenuViewController;

@interface FFGamePausedMenu : FFMenuBackgroundView

@property(nonatomic, weak) FFMenuViewController *delegate;

- (void)hide:(BOOL)b;
@end
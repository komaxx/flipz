//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 8/13/13.
//


#import <UIKit/UIKit.h>

@class FFMenuViewController;

@interface FFMainMenu : UIView
@property(nonatomic, weak) FFMenuViewController *delegate;

- (void)hide:(BOOL)b;
@end
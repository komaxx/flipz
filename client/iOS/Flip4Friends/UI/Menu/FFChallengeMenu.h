//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/25/13.
//


#import <UIKit/UIKit.h>

@class FFMenuViewController;

@interface FFChallengeMenu : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) FFMenuViewController *delegate;

- (void)hide:(BOOL)b;

@end
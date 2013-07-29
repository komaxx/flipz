//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/25/13.
//


#import <Foundation/Foundation.h>

@class FFMenuViewController;

@interface FFChallengeMenuControl : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) FFMenuViewController *delegate;

- (id)initWithScrollView:(UITableView *)view;
- (void)hide:(BOOL)b;

@end
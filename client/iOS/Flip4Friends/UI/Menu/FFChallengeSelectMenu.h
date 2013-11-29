//
//  FFChallengeSelectMenu.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 11/28/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFMenuViewController;

@interface FFChallengeSelectMenu : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) FFMenuViewController *delegate;

- (void)hide:(BOOL)b;
- (void)refreshListCells;

@end

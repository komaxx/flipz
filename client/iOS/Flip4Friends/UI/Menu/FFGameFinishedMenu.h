//
//  FFGameFinishedMenu.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 7/25/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFMenuBackgroundView.h"

@class FFMenuViewController;

@interface FFGameFinishedMenu : FFMenuBackgroundView

@property(nonatomic, weak) FFMenuViewController *delegate;

- (void)hide:(BOOL)b;
@end

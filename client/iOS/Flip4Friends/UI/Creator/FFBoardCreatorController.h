//
//  FFChallengeCreatorController.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 9/18/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FFBoardCreatorController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (void)tileTappedToPaintX:(NSUInteger)x andY:(NSUInteger)y done:(BOOL)done;

- (void)movePainting:(UISwipeGestureRecognizerDirection)direction;

- (void)paintingEnded;
@end

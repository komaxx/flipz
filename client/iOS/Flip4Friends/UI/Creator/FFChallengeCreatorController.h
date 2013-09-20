//
//  FFChallengeCreatorController.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 9/18/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FFChallengeCreatorController : UIViewController

- (void)tileTappedToPaintX:(NSUInteger)i andY:(NSUInteger)y;

- (void)movePainting:(UISwipeGestureRecognizerDirection)direction;
@end

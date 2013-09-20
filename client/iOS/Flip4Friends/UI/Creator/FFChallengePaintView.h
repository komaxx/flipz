//
//  FFChallengePaintView.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 9/18/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFBoardView;
@class FFChallengeCreatorController;

@interface FFChallengePaintView : UIView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) FFChallengeCreatorController *delegate;
@property (weak, nonatomic) FFBoardView* boardView;

@end

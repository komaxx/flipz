//
//  FFChallengePaintView.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 9/18/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFBoardView;
@class FFBoardCreatorController;

@interface FFBoardPaintView : UIView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) FFBoardCreatorController *delegate;
@property (weak, nonatomic) FFBoardView* boardView;

@end

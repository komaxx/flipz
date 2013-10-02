//
//  FFPatternPaintView.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 9/24/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFMove;
@class FFBoardView;
@class FFChallengeCreatorViewController;

@protocol FFPatternPaintViewDelegate
- (void) moveAborted;
- (void) moveStarted;
- (void)movePainting:(UISwipeGestureRecognizerDirection)direction;
@end

@interface FFPatternPaintView : UIView

@property (nonatomic, weak) FFBoardView* boardView;
@property (nonatomic, weak) id<FFPatternPaintViewDelegate> delegate;

- (void)reset;

- (FFMove *)getCurrentMoveWithRotationAllowed:(BOOL)rotating;
@end

//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/13/13.
//


#import <UIKit/UIKit.h>
#import "FFPattern.h"

@class FFGameViewController;
@class FFBoardView;
@class FFGame;

@protocol FFMoveViewControlDelegate
- (void)moveCompletedWithPattern:(FFPattern *)pattern at:(FFCoord *)coord withDirection:(NSInteger)direction;
- (void)cancelMoveWithPattern:(FFPattern *)pattern;
// called whenever the user stopped moving around the current pattern. Should trigger the move automatically
// when it wins the challenge
- (void)checkForWinningPositioning:(FFPattern *)pattern at:(FFCoord *)at withDirection:(NSInteger)direction;
@end

@interface FFMoveViewControl : UIView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<FFMoveViewControlDelegate> delegate;
@property(nonatomic, weak) FFBoardView *boardView;


- (void)didLoad;
- (void)didAppear;
- (void)didDisappear;

- (void)moveFinished;

- (void)startMoveWithPattern:(FFPattern *)pattern
                     atCoord:(FFCoord *)atCoord
               andAppearFrom:(UIView *)appearView
                withRotation:(NSInteger)startDirection
                  forPlayer2:(BOOL)player2;

- (void)executeCurrentMove;
@end
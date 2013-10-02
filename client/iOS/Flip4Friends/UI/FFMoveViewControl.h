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

@end
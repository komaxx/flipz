//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/13/13.
//


#import <UIKit/UIKit.h>
#import "FFPattern.h"

@class FFGameViewController;
@class FFBoardView;

@interface FFMoveViewControl : UIView

@property (weak, nonatomic) FFGameViewController *delegate;
@property(nonatomic, weak) FFBoardView *boardView;


- (void)didLoad;
- (void)didAppear;
- (void)didDisappear;

- (void)moveFinished;

- (void)startMoveWithPattern:(FFPattern *)pattern
                     atCoord:(FFCoord *)atCoord
               andAppearFrom:(UIView *)appearView
                withRotation:(NSInteger)startDirection;

@end
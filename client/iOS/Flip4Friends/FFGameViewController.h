//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import <UIKit/UIKit.h>
#import "FFPattern.h"
#import "FFPatternsViewControl.h"
#import "FFHistorySlider.h"
#import "FFMoveViewControl.h"

@protocol FFGameViewControllerDelegate <NSObject>
- (NSString *)activeGameId;
@end

@interface FFGameViewController : UIView <FFPatternsViewControlDelegate, FFHistorySliderProtocol, FFMoveViewControlDelegate>

@property (weak, nonatomic) id<FFGameViewControllerDelegate> delegate;

- (void)didLoad;
- (void)didAppear;

- (void)selectedGameWithId:(NSString *)gameID;

- (void)didDisappear;

- (void)setPatternSelectedForMove:(FFPattern *)pattern fromView:(UIView *)view;
- (void)moveCompletedWithPattern:(FFPattern *)pattern at:(FFCoord *)coord withDirection:(NSInteger)direction;

- (void)cancelMoveWithPattern:(FFPattern *)pattern;

- (void)showHistoryStartingFromStepsBack:(NSInteger)stepsBack;
- (void)hideHistory;

- (void)gameCleaned;

- (void)undo;
@end
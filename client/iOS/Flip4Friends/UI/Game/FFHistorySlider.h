//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 8/12/13.
//


#import <UIKit/UIKit.h>
#import "FFBoardView.h"
#import "FFPatternsViewControl.h"

@class FFGameViewController;


@protocol FFHistorySliderProtocol
- (void)showHistoryStartingFromStepsBack:(NSInteger)stepsBack;
- (void)hideHistory;
@end

@interface FFHistorySlider : UIControl

@property (nonatomic, weak) id<FFHistorySliderProtocol> delegate;

@property (nonatomic, weak) FFBoardView *boardView;
@property(nonatomic, copy) NSString *activeGameId;

- (void)didAppear;
- (void)didDisappear;

@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 8/12/13.
//


#import <UIKit/UIKit.h>
#import "FFBoardView.h"
#import "FFPatternsViewControl.h"

@class FFGameViewController;

extern NSString *const kFFNotificationHistoryShowStateChanged;
extern NSString *const kFFNotificationHistoryShowStateChanged_stepsBack;

@interface FFHistorySlider : UIControl

@property(nonatomic, copy) NSString *activeGameId;

- (void)didAppear;
- (void)didDisappear;

@end
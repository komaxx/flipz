//
//  FFChallengeHistorySliderView.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 10/4/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFHistorySlider.h"

@interface FFChallengeHistorySliderView : UIControl

@property(nonatomic, copy) NSString *activeGameId;

- (void)didAppear;
- (void)didDisappear;

@end

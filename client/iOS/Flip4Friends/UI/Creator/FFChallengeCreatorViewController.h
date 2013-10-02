//
//  FFChallengeCreatorViewController.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 9/23/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFPatternPaintView.h"

@interface FFChallengeCreatorViewController : UIViewController <FFPatternPaintViewDelegate>

- (void)moveStarted;
- (void)moveAborted;

@end

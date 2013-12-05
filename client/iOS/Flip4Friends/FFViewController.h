//
//  FFViewController.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFGameViewController.h"
#import "FFMenuViewController.h"

@class FFGame;

@interface FFViewController : UIViewController <FFGameViewControllerDelegate, FFMenuViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (copy, nonatomic, readonly) NSString *activeGameId;

@end

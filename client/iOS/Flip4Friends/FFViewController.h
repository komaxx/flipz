//
//  FFViewController.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFGame;
@interface FFViewController : UIViewController

@property (strong, nonatomic) FFGame *activeGame;

@end

//
//  FFAppDelegate.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFStoreDataHandler;

@interface FFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) FFStoreDataHandler* dataHandler;

@end

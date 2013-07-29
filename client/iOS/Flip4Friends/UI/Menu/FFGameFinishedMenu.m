//
//  FFGameFinishedMenu.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 7/25/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FFGameFinishedMenu.h"
#import "FFButton.h"
#import "FFMenuViewController.h"


@implementation FFGameFinishedMenu
@synthesize delegate = _delegate;


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

        FFButton *menuButton = (FFButton *) [self viewWithTag:601];
        [menuButton addTarget:self action:@selector(menuTapped:) forControlEvents:UIControlEventTouchUpInside];

        FFButton *retryButton = (FFButton *) [self viewWithTag:602];
        [retryButton addTarget:self action:@selector(retryTapped:) forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

- (void)retryTapped:(id)retryTapped {
    [self.delegate restartGame];
}

- (void)menuTapped:(id)menuTapped {
    [self.delegate goBackToMenuAfterFinished];
}

@end

//
//  FFGameFinishedMenu.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 7/25/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFGameFinishedMenu.h"
#import "FFButton.h"
#import "FFMenuViewController.h"
#import "FFGamesCore.h"


@implementation FFGameFinishedMenu
@synthesize delegate = _delegate;


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

        FFButton *menuButton = (FFButton *) [self viewWithTag:601];
        [menuButton addTarget:self action:@selector(menuTapped:) forControlEvents:UIControlEventTouchUpInside];

        FFButton *nextButton = (FFButton *) [self viewWithTag:602];
        [nextButton addTarget:self action:@selector(nextTapped:) forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

- (void)nextTapped:(id)retryTapped {
    [self.delegate proceedToNextChallenge];
}

- (void)menuTapped:(id)menuTapped {
    [self.delegate goBackToMenuAfterFinished];
}

- (void)hide:(BOOL)nowHidden {
    if (self.hidden && !nowHidden){
        FFGame *game = [[FFGamesCore instance] gameWithId:[self.delegate.delegate activeGameId]];

        NSString *nuTitle = nil;
        NSString *nuMessage = nil;
        if (game.Type == kFFGameTypeSingleChallenge){
            nuTitle = NSLocalizedString(@"finished_title_success", nil);
            nuMessage = NSLocalizedString(@"finished_message_challenge_complete", nil);
        } else if (game.Type == kFFGameTypeHotSeat){
            nuTitle = NSLocalizedString(@"finished_title_congratulations", nil);
            nuMessage = NSLocalizedString(@"finished_message_you_won", nil);

            if ([[game winningPlayer].id isEqualToString:game.player2.id]){
                self.transform = CGAffineTransformMakeRotation((CGFloat) M_PI);
            } else {
                self.transform = CGAffineTransformMakeRotation(0);
            }
        }

        for (int i = 0; i < 4; i++) ((UILabel *)[self viewWithTag:(610+i)]).text = nuTitle;
        ((UILabel *)[self viewWithTag:(620)]).text = nuMessage;
    }
    self.hidden = nowHidden;
}
@end

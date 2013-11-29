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
#import "FFStorageUtil.h"

@interface FFGameFinishedMenu ()
@property (weak, nonatomic) FFButton* nextRepeatButton;
@property (nonatomic) SEL nextRepeatButtonAction;
@end

@implementation FFGameFinishedMenu
@synthesize delegate = _delegate;


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

        FFButton *menuButton = (FFButton *) [self viewWithTag:601];
        [menuButton addTarget:self action:@selector(menuTapped:) forControlEvents:UIControlEventTouchUpInside];

        self.nextRepeatButton = (FFButton *) [self viewWithTag:602];
        [self.nextRepeatButton addTarget:self action:@selector(nextTapped:) forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

- (void)nextTapped:(id)retryTapped {
    [self.delegate performSelector:self.nextRepeatButtonAction];
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
            self.transform = CGAffineTransformMakeRotation(0);

            if ([game isRandomChallenge]){
                [self.nextRepeatButton setTitle:NSLocalizedString(@"btn_another", nil) forState:UIControlStateNormal];
                self.nextRepeatButtonAction = @selector(anotherRandomChallenge);

                if (game.gameState == kFFGameState_Won){
                    nuTitle = NSLocalizedString(@"finished_title_success", nil);
                    nuMessage = [NSString stringWithFormat:NSLocalizedString(@"finished_message_challenge_success", nil),
                                   [self challengesWonSimilarTo:game], [self challengesPlayedSimilarTo:game]];
                } else {        // the game was lost
                    nuTitle = NSLocalizedString(@"finished_title_failed", nil);
                    nuMessage = [NSString stringWithFormat:NSLocalizedString(@"finished_message_challenge_failed", nil)];
                }
            } else {        // it's a manual puzzle
                nuTitle = NSLocalizedString(@"finished_title_success", nil);
                nuMessage = NSLocalizedString(@"finished_message_puzzle_success", nil);
                [self.nextRepeatButton setTitle:NSLocalizedString(@"btn_next", nil) forState:UIControlStateNormal];
                self.nextRepeatButtonAction = @selector(proceedToNextChallenge);
            }
        } else if (game.Type == kFFGameTypeHotSeat){
            nuTitle = NSLocalizedString(@"finished_title_congratulations", nil);

            if ([[game winningPlayer].id isEqualToString:game.player2.id]){
                self.transform = CGAffineTransformMakeRotation((CGFloat) M_PI);
                nuMessage = [NSString stringWithFormat:NSLocalizedString(@"finished_message_you_won", nil),
                                                       [game scoreForColor:1], [game scoreForColor:0]];
            } else {
                self.transform = CGAffineTransformMakeRotation(0);
                nuMessage = [NSString stringWithFormat:NSLocalizedString(@"finished_message_you_won", nil),
                                                       [game scoreForColor:0], [game scoreForColor:1]];
            }

            [self.nextRepeatButton setTitle:NSLocalizedString(@"btn_rematch", nil) forState:UIControlStateNormal];
            self.nextRepeatButtonAction = @selector(rematch);
        }

        for (int i = 0; i < 4; i++) ((UILabel *)[self viewWithTag:(610+i)]).text = nuTitle;
        ((UILabel *)[self viewWithTag:(620)]).text = nuMessage;
    }
    self.hidden = nowHidden;
}

- (int)challengesPlayedSimilarTo:(FFGame *)game {
    [FFStorageUtil getTimesPlayedForChallengeLevel:[[game challengeIndex] unsignedIntegerValue]];
}

- (int)challengesWonSimilarTo:(FFGame *)game {
    [FFStorageUtil getTimesWonForChallengeLevel:[[game challengeIndex] unsignedIntegerValue]];
}

@end

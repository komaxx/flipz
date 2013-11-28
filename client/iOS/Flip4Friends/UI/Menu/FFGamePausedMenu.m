//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/29/13.
//


#import "FFMenuBackgroundView.h"
#import "FFGamePausedMenu.h"
#import "FFMenuViewController.h"
#import "FFButton.h"
#import "FFGamesCore.h"

@interface FFGamePausedMenu ()
@property (weak, nonatomic) FFButton *menuButton;
@property (weak, nonatomic) FFButton *resumeButton;
@end


@implementation FFGamePausedMenu


@synthesize delegate = _delegate;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

        self.menuButton = (FFButton *) [self viewWithTag:701];
        [self.menuButton addTarget:self action:@selector(menuTapped:) forControlEvents:UIControlEventTouchUpInside];

        self.resumeButton = (FFButton *) [self viewWithTag:702];
        [self.resumeButton addTarget:self action:@selector(resumeTapped:) forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

- (void)resumeTapped:(id)retryTapped {
    [self.delegate resumeGame];
}

- (void)menuTapped:(id)menuTapped {
    FFGame *game = [[FFGamesCore instance] gameWithId:self.delegate.delegate.activeGameId];

    if (game && [game.Type isEqualToString:kFFGameTypeSingleChallenge]){
        [self.delegate giveUpAndBackToChallengeMenu];
    } else {
        [self.delegate goBackToMainMenu];
    }
}

- (void)hide:(BOOL)b {
    if (!b && self.hidden){
        FFGame *game = [[FFGamesCore instance] gameWithId:self.delegate.delegate.activeGameId];
        if (game && [game.Type isEqualToString:kFFGameTypeHotSeat]){
            self.transform = CGAffineTransformMakeRotation((CGFloat) M_PI / -2.0);
        } else {
            self.transform = CGAffineTransformIdentity;
        }

        if ([game isRandomChallenge]){
            [self.menuButton setTitle:NSLocalizedString(@"btn_give_up", nil) forState:UIControlStateNormal];
        } else {
            [self.menuButton setTitle:NSLocalizedString(@"btn_menu", nil) forState:UIControlStateNormal];
        }
    }

    self.hidden = b;
}
@end
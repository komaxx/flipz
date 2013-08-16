//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/29/13.
//


#import "FFMenuBackgroundView.h"
#import "FFGamePausedMenu.h"
#import "FFMenuViewController.h"
#import "FFButton.h"
#import "FFGamesCore.h"


@implementation FFGamePausedMenu {

}
@synthesize delegate = _delegate;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

        FFButton *menuButton = (FFButton *) [self viewWithTag:701];
        [menuButton addTarget:self action:@selector(menuTapped:) forControlEvents:UIControlEventTouchUpInside];

        FFButton *resumeButton = (FFButton *) [self viewWithTag:702];
        [resumeButton addTarget:self action:@selector(resumeTapped:) forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

- (void)resumeTapped:(id)retryTapped {
    [self.delegate resumeGame];
}

- (void)menuTapped:(id)menuTapped {
    [self.delegate giveUpAndBackToChallengeMenu];
}

- (void)hide:(BOOL)b {
    if (!b && self.hidden){
        FFGame *game = [[FFGamesCore instance] gameWithId:self.delegate.delegate.activeGameId];
        if (game && [game.Type isEqualToString:kFFGameTypeHotSeat]){
            self.transform = CGAffineTransformMakeRotation((CGFloat) M_PI / -2.0);
        } else {
            self.transform = CGAffineTransformIdentity;
        }
    }

    self.hidden = b;
}
@end
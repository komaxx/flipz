//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/21/13.
//


#import "FFHotSeatMenu.h"
#import "FFMenuViewController.h"
#import "FFGame.h"
#import "FFGamesCore.h"
#import "FFButton.h"

@interface FFHotSeatMenu ()
@end


@implementation FFHotSeatMenu {
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        FFButton *backButton = (FFButton *) [self viewWithTag:701];
        [backButton addTarget:self action:@selector(backTapped:) forControlEvents:UIControlEventTouchUpInside];

        FFButton *startButton = (FFButton *) [self viewWithTag:702];
        [startButton addTarget:self action:@selector(startTapped:) forControlEvents:UIControlEventTouchUpInside];

        UILabel *text = (UILabel *) [self viewWithTag:705];
        text.text = NSLocalizedString(@"hot_seat_start_explanation", nil);

        self.transform = CGAffineTransformMakeRotation((CGFloat) M_PI / -2.0);
    }

    return self;
}

- (void)startTapped:(id)dog {
    [self.delegate startHotSeatGame];
}

- (void)backTapped:(id)menuTapped {
    [self.delegate goBackToMainMenu];
}

- (void)hide:(BOOL)b {
    self.hidden = b;
}


@end
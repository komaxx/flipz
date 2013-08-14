//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 8/13/13.
//


#import "FFMainMenu.h"
#import "FFMenuViewController.h"


@implementation FFMainMenu {

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [(UIButton *)[self viewWithTag:11]
                addTarget:self action:@selector(buttonChallengeTapped) forControlEvents:UIControlEventTouchUpInside];
        [(UIButton *)[self viewWithTag:12]
                addTarget:self action:@selector(buttonHotSeatTapped) forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

- (void)buttonHotSeatTapped {
    [self.delegate hotSeatTapped];
}

- (void)buttonChallengeTapped {
    [self.delegate localChallengeSelected];
}


@end
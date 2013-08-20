//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 8/20/13.
//


#import "FFChallengeFooter.h"
#import "FFGamesCore.h"
#import "FFMenuViewController.h"


@implementation FFChallengeFooter {
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [(UIButton *) [self viewWithTag:401] addTarget:self action:@selector(pauseTapped) forControlEvents:UIControlEventTouchUpInside];
        [(UIButton *) [self viewWithTag:402] addTarget:self action:@selector(cleanTapped) forControlEvents:UIControlEventTouchUpInside];
        [(UIButton *) [self viewWithTag:403] addTarget:self action:@selector(undoTapped) forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

- (void)pauseTapped {
    [self.delegate pauseTapped];
}

- (void)cleanTapped {
    [self.delegate.delegate cleanCurrentGame];
    FFGame *game = [[FFGamesCore instance] gameWithId:[self.delegate.delegate activeGameId]];
    [game clean];
}

- (void)undoTapped {
    FFGame *game = [[FFGamesCore instance] gameWithId:[self.delegate.delegate activeGameId]];
    [game undoLastMove];
}

@end
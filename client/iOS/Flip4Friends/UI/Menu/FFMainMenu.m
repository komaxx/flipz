//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 8/13/13.
//


#import "FFMainMenu.h"
#import "FFMenuViewController.h"
#import "FFAutoPlayer.h"
#import "FFGamesCore.h"


@implementation FFMainMenu {

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [(UIButton *)[self viewWithTag:11]
                addTarget:self action:@selector(buttonChallengeTapped) forControlEvents:UIControlEventTouchUpInside];
        [(UIButton *)[self viewWithTag:12]
                addTarget:self action:@selector(buttonHotSeatTapped) forControlEvents:UIControlEventTouchUpInside];
        [(UIButton *)[self viewWithTag:13]
                addTarget:self action:@selector(buttonTestRunTapped) forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

- (void)buttonTestRunTapped {
    [self performSelectorInBackground:@selector(testRun) withObject:nil];
}

- (void)testRun {
    int whiteWins = 0;
    int plays = 100;

    for (int i = 0; i < plays; i++){
        FFGame *hotSeatGame = [[FFGamesCore instance] generateNewHotSeatGame];
        [hotSeatGame start];

        FFAutoPlayer *player1 = [[FFAutoPlayer alloc] initWithGameId:hotSeatGame.Id andPlayerId:hotSeatGame.player1.id];
        FFAutoPlayer *player2 = [[FFAutoPlayer alloc] initWithGameId:hotSeatGame.Id andPlayerId:hotSeatGame.player2.id];

        [player2 startPlaying];
        [player1 startPlaying];

        if ([hotSeatGame.winningPlayer.id isEqualToString:hotSeatGame.player1.id]){
            whiteWins++;
//            NSLog(@"WHITE victory, quota: %i/%i = %f", whiteWins, (i+1), (CGFloat)whiteWins/(CGFloat)(i+1));
        } else {
//            NSLog(@"black victory, quota: %i/%i = %f", whiteWins, (i+1), (CGFloat)whiteWins/(CGFloat)(i+1));
        }

        if (i%5 == 0) NSLog(@"..quota: white won %i/%i = %f", whiteWins, (i+1), (CGFloat)whiteWins/(CGFloat)(i+1));

        [player2 endPlaying];
        [player1 endPlaying];
    }

    NSLog(@"Quota: white won %i/%i", whiteWins, plays);
}

- (void)buttonHotSeatTapped {
    [self.delegate hotSeatTapped];
}

- (void)buttonChallengeTapped {
    [self.delegate localChallengeSelected];
}


@end
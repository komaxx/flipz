//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 8/13/13.
//


#import "FFMainMenu.h"
#import "FFMenuViewController.h"
#import "FFAutoPlayer.h"
#import "FFGamesCore.h"

@interface FFMainMenu ()
@property (strong) NSMutableDictionary *autoPlayer;
@end


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

        self.autoPlayer = [[NSMutableDictionary alloc] initWithCapacity:1000];
    }

    return self;
}

- (void)buttonTestRunTapped {
    [self performSelectorInBackground:@selector(testRun) withObject:nil];
}

- (void)testRun {
    static BOOL alreadyRegistered = NO;
    if (!alreadyRegistered) {
        [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(gameChanged:) name:kFFNotificationGameChanged object:nil];
        alreadyRegistered = YES;
    }

    for (int i = 0; i < 50; i++){
        FFGame *hotSeatGame = [[FFGamesCore instance] generateNewHotSeatGame];
        [hotSeatGame start];

        FFAutoPlayer *player1 = [[FFAutoPlayer alloc] initWithGameId:hotSeatGame.Id andPlayerId:hotSeatGame.player1.id];
        FFAutoPlayer *player2 = [[FFAutoPlayer alloc] initWithGameId:hotSeatGame.Id andPlayerId:hotSeatGame.player2.id];

        [self.autoPlayer setObject:@[player1,player2] forKey:hotSeatGame.Id];

        [player2 startPlaying];
        [player1 startPlaying];
    }

    NSLog(@"++++");
}

- (void)gameChanged:(NSNotification *)notification {
    static int whiteWins = 0;
    static int plays = 0;

//    NSLog(@"gameChanged");

    NSString *changedGameID = [notification.userInfo objectForKey:kFFNotificationGameChanged_gameId];
    NSArray *players = [self.autoPlayer objectForKey:changedGameID];
    if (!players) return;  // not waiting for anything anymore!

    FFGame * game = [[FFGamesCore instance] gameWithId:changedGameID];
    if (game.gameState == kFFGameState_Finished){
//        NSLog(@"finished!");

        [[players objectAtIndex:1] endPlaying];
        [[players objectAtIndex:0] endPlaying];

        [self.autoPlayer removeObjectForKey:changedGameID];

        plays++;
        if ([[game winningPlayer].id isEqualToString:game.player1.id]) whiteWins++;


        if (plays%10 == 0) NSLog(@"Quota: white won %i/%i = %f", whiteWins, plays, (CGFloat)whiteWins/(CGFloat)plays);
    }
}

- (void)buttonHotSeatTapped {
    [self.delegate hotSeatTapped];
}

- (void)buttonChallengeTapped {
    [self.delegate localChallengeSelected];
}


@end
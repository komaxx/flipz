//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 8/13/13.
//


#import "FFMainMenu.h"
#import "FFMenuViewController.h"
#import "FFAutoPlayer.h"
#import "FFGamesCore.h"
#import "FFAutoSolver.h"
#import "FFAnalytics.h"
#import "FFStorageUtil.h"

@interface FFMainMenu ()
@property (strong) NSMutableDictionary *autoPlayer;
@property (weak, nonatomic) UIButton *soundOnOffButton;
@end


@implementation FFMainMenu {
    BOOL _hiding;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [(UIButton *)[self viewWithTag:11]
                addTarget:self action:@selector(buttonSelectPuzzleTapped) forControlEvents:UIControlEventTouchUpInside];
        [(UIButton *)[self viewWithTag:12]
                addTarget:self action:@selector(buttonSelectChallengeTapped) forControlEvents:UIControlEventTouchUpInside];
        [(UIButton *)[self viewWithTag:13]
                addTarget:self action:@selector(buttonHotSeatTapped) forControlEvents:UIControlEventTouchUpInside];
        [(UIButton *)[self viewWithTag:14]
                addTarget:self action:@selector(feedbackTapped) forControlEvents:UIControlEventTouchUpInside];

        self.soundOnOffButton = (UIButton *)[self viewWithTag:15];
        [self.soundOnOffButton addTarget:self action:@selector(soundOnOffTapped) forControlEvents:UIControlEventTouchUpInside];

        self.autoPlayer = [[NSMutableDictionary alloc] initWithCapacity:1000];
        _hiding = self.hidden;
    }

    return self;
}

- (void)soundOnOffTapped {
    BOOL wasDisabled = [FFStorageUtil isSoundDisabled];
    [FFStorageUtil setSoundDisabled:!wasDisabled];

    [self updateDisableSoundButton];
}

- (void)updateDisableSoundButton {
    UIImage *nuPic = [UIImage imageNamed:[FFStorageUtil isSoundDisabled] ? @"sound_off.png" : @"sound_on.png"];
    [self.soundOnOffButton setImage:nuPic forState:UIControlStateNormal];
}

- (void)feedbackTapped {
    [FFAnalytics log:@"MAIN_MENU_FEEDBACK_TAPPED"];
    [self.delegate openFeedbackForm];
}

- (void)buttonSelectChallengeTapped {
    [FFAnalytics log:@"MAIN_MENU_CHALLENGE_TAPPED"];
    [self.delegate chooseRandomChallengeSelected];
}

- (void)buttonSelectPuzzleTapped {
    [FFAnalytics log:@"MAIN_MENU_PUZZLE_TAPPED"];
    [self.delegate choosePuzzleSelected];
}

- (void)buttonHotSeatTapped {
    [FFAnalytics log:@"MAIN_MENU_HOT_SEAT_TAPPED"];
    [self.delegate hotSeatTapped];
}

- (void)hide:(BOOL)hide {
    if (hide == _hiding) return;

    CGPoint center = self.center;
    if (hide){
        [UIView animateWithDuration:0.2 animations:^{
            self.center = CGPointMake(-160, center.y);
        } completion:^(BOOL finished) {
            if (finished) self.hidden = YES;
        }];
    } else {
        self.hidden = NO;
        [self updateDisableSoundButton];
        [UIView animateWithDuration:0.2 animations:^{
            self.center = CGPointMake(160, center.y);
        }];
    }

    _hiding = hide;
}


// //////////////////////////////////////////////////////////////////////////////
// teesting stuff


- (void)buttonTestRunTapped {
//    [self performSelectorInBackground:@selector(testRun) withObject:nil];
    [self performSelectorInBackground:@selector(solveGames) withObject:nil];
}

- (void)solveGames {
    for (NSUInteger i = 44; i < [[FFGamesCore instance] puzzlesCount]; i++){

        NSLog(@" ------------ %i ------------", i);

        FFGame* game = [[FFGamesCore instance] puzzle:i];
        FFAutoSolver *solver = [[FFAutoSolver alloc] initWithGame:game];
        [solver solveSynchronouslyAndAbortWhenFirstFound:NO];

        NSLog(@" //////////// %i ////////////", i);
    }
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

        NSLog(@"Final score: %i / %i", [hotSeatGame scoreForColor:0], [hotSeatGame scoreForColor:1]);
    }

    NSLog(@"++++");
}

- (void)gameChanged:(NSNotification *)notification {
    NSString *changedGameID = [notification.userInfo objectForKey:kFFNotificationGameChanged_gameId];
    NSArray *players = [self.autoPlayer objectForKey:changedGameID];
    if (!players) return;  // not waiting for anything anymore!

    [self updateAutoPlayerWithChangedGameId:changedGameID];
}

- (void)updateAutoPlayerWithChangedGameId:(NSString *)changedGameID {
    static int whiteWins = 0;
    static int plays = 0;

    NSArray *players = [self.autoPlayer objectForKey:changedGameID];
    FFGame * game = [[FFGamesCore instance] gameWithId:changedGameID];
    if (game.gameState == kFFGameState_Won){
//        NSLog(@"finished!");

        [[players objectAtIndex:1] endPlaying];
        [[players objectAtIndex:0] endPlaying];

        [self.autoPlayer removeObjectForKey:changedGameID];

        plays++;
        if ([[game winningPlayer].id isEqualToString:game.player1.id]) whiteWins++;

        if (plays%10 == 0) NSLog(@"Quota: white won %i/%i = %f", whiteWins, plays, (CGFloat)whiteWins/(CGFloat)plays);
    }
}
@end
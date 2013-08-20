//
//  FFMenuViewController.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 7/25/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFMenuViewController.h"
#import "FFChallengeMenu.h"
#import "FFGamesCore.h"
#import "FFGameFinishedMenu.h"
#import "FFGamePausedMenu.h"
#import "FFMainMenu.h"
#import "FFAutoPlayer.h"
#import "FFChallengeFooter.h"
#import "FFVersusFooter.h"


typedef enum {
    menuState_unset,
    menuState_mainMenu,
    menuState_chooseChallenge,
    menuState_gameStarting,
    menuState_gameRunning,
    menuState_gamePaused,
    menuState_gameFinished
} menuState;

@interface FFMenuViewController ()

@property (strong, nonatomic) FFMainMenu * mainMenu;
@property (strong, nonatomic) FFChallengeMenu * challengeMenu;
@property (weak, nonatomic) FFGameFinishedMenu* finishedMenu;
@property (weak, nonatomic) FFGamePausedMenu* pausedMenu;

@property (weak, nonatomic) FFChallengeFooter *challengeFooter;
@property (weak, nonatomic) FFVersusFooter* versusFooter;

@property (strong, nonatomic) FFAutoPlayer *tmpAutoPlayer1;
@property (strong, nonatomic) FFAutoPlayer *tmpAutoPlayer2;

@end

@implementation FFMenuViewController {
    menuState _state;
}

- (void)didLoad {
    self.mainMenu = (FFMainMenu *)[self viewWithTag:10];
    self.mainMenu.delegate = self;

    self.challengeMenu = (FFChallengeMenu *) [self viewWithTag:500];
    self.challengeMenu.delegate = self;

    self.finishedMenu = (FFGameFinishedMenu *) [self viewWithTag:600];
    self.finishedMenu.delegate = self;

    self.pausedMenu = (FFGamePausedMenu *) [self viewWithTag:700];
    self.pausedMenu.delegate = self;

    self.challengeFooter = (FFChallengeFooter *) [self.superview viewWithTag:400];
    self.challengeFooter.delegate = self;

    self.versusFooter = (FFVersusFooter *) [self.superview viewWithTag:410];
    self.versusFooter.delegate = self;

    [self changeState:menuState_mainMenu];
}

- (void)changeState:(menuState)state {
    if (state == _state) return;

    self.hidden = state==menuState_gameRunning;
    [self.challengeMenu hide:state != menuState_chooseChallenge];
    [self.pausedMenu hide:state!=menuState_gamePaused];
    [self showFooter:state==menuState_gameRunning];
    [self.finishedMenu hide:state!=menuState_gameFinished];
    self.mainMenu.hidden = state!=menuState_mainMenu;

    switch (state){
        case menuState_mainMenu:
            [self.delegate activateGameWithId:nil];
            break;
        case menuState_chooseChallenge:
            [self.delegate activateGameWithId:nil];
            break;
        case menuState_gameStarting:
            break;
        case menuState_gameRunning:
            break;
        case menuState_gamePaused:
            break;
        case menuState_gameFinished:
            break;
    }

    _state = state;
}

- (void)showFooter:(BOOL)b {
    BOOL isChallenge = [[[FFGamesCore instance] gameWithId:self.delegate.activeGameId].Type isEqualToString:kFFGameTypeSingleChallenge];

    self.challengeFooter.hidden = !b || !isChallenge;
    self.versusFooter.hidden = !b || isChallenge;
}

- (void)didAppear {
    [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(gameChanged:) name:kFFNotificationGameChanged object:nil];
}

- (void)gameChanged:(NSNotification *)notification {
    NSString *gameID = [notification.userInfo objectForKey:kFFNotificationGameChanged_gameId];
    if (![gameID isEqualToString:[self.delegate activeGameId]]) return;     // not the active game. Ignore.

    FFGame *game = [[FFGamesCore instance] gameWithId:gameID];
    if (_state == menuState_gameRunning && game.gameState==kFFGameState_Finished){
        if (self.tmpAutoPlayer1){
            [self.tmpAutoPlayer1 endPlaying];
            [self.tmpAutoPlayer2 endPlaying];
            self.tmpAutoPlayer1 = nil;
            self.tmpAutoPlayer2 = nil;
        }

        [self changeState:menuState_gameFinished];
    }
}

- (void)didDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pauseTapped {
    [self changeState:menuState_gamePaused];
}

// ////////////////////////////////////////////////////////////
// sub-menu calls

- (void)goBackToMainMenu {
    [self changeState:menuState_mainMenu];
}

- (void)hotSeatTapped {
    [self changeState:menuState_gameRunning];
    FFGame *hotSeatGame = [[FFGamesCore instance] generateNewHotSeatGame];


    /*/ /////////////////////////////////////////////////////////////
    // TODO remove for manual play
    self.tmpAutoPlayer1 = [[FFAutoPlayer alloc] initWithGameId:hotSeatGame.Id andPlayerId:hotSeatGame.player1.id];
    self.tmpAutoPlayer2 = [[FFAutoPlayer alloc] initWithGameId:hotSeatGame.Id andPlayerId:hotSeatGame.player2.id];

    [self.tmpAutoPlayer2 startPlaying];
    [self.tmpAutoPlayer1 startPlaying];
    //*/ /////////////////////////////////////////////////////////////

    [hotSeatGame start];

    [self.delegate activateGameWithId:hotSeatGame.Id];


//    self.tmpAutoPlayer = [[FFAutoPlayer alloc] initWithGameId:hotSeatGame.Id andPlayerId:hotSeatGame.player2.id];
//    [self.tmpAutoPlayer startPlaying];
}

- (void)localChallengeSelected {
    [self changeState:menuState_chooseChallenge];
}

- (void)goBackToMenuAfterFinished {
    FFGame *game = [[FFGamesCore instance] gameWithId:[self.delegate activeGameId]];
    if ([game.Type isEqualToString:kFFGameTypeSingleChallenge]){
        [self changeState:menuState_chooseChallenge];
    } else {
        [self changeState:menuState_mainMenu];
    }
}

- (void)giveUpAndBackToChallengeMenu {
    FFGame *selectedGame = [[FFGamesCore instance] gameWithId:[self.delegate activeGameId]];
    [selectedGame giveUp];
    [self changeState:menuState_chooseChallenge];
}

- (void) activateGameWithId:(NSString *)gameId {
    // start the game
    FFGame *selectedGame = [[FFGamesCore instance] gameWithId:gameId];

    if (selectedGame.gameState == kFFGameState_NotYetStarted){
        [self changeState:menuState_gameRunning];
        [selectedGame start];
    } else if (selectedGame.gameState == kFFGameState_Running){
        if (selectedGame.activePlayer.local){
            [self changeState:menuState_gameRunning];
            [selectedGame start];
        } else {
            // not local. We're waiting for the other guy to do his move
        }
    } else {
        // already finished, restarting
        [self changeState:menuState_gameRunning];
        [selectedGame start];
    }

    [self.delegate activateGameWithId:gameId];
}

- (void)restartGame {
    FFGame *selectedGame = [[FFGamesCore instance] gameWithId:[self.delegate activeGameId]];
    [selectedGame start];

    [self.delegate restartCurrentGame];
    [self changeState:menuState_gameRunning];
}

- (void)resumeGame {
    [self changeState:menuState_gameRunning];
}

// sub-menu calls
// ////////////////////////////////////////////////////////////

@end

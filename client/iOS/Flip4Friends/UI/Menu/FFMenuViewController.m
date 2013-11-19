//
//  FFMenuViewController.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 7/25/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFHistorySlider.h"
#import "FFMenuViewController.h"
#import "FFChallengeMenu.h"
#import "FFGamesCore.h"
#import "FFGameFinishedMenu.h"
#import "FFGamePausedMenu.h"
#import "FFMainMenu.h"
#import "FFAutoPlayer.h"
#import "FFChallengeSidebar.h"
#import "FFStorageUtil.h"
#import "FFHotSeatSidebar.h"


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

@property (weak, nonatomic) FFChallengeSidebar *challengeSidebar;
@property (weak, nonatomic) FFHotSeatSidebar* hotSeatSidebar;

@property (strong, nonatomic) FFAutoPlayer *tmpAutoPlayer1;
@property (strong, nonatomic) FFAutoPlayer *tmpAutoPlayer2;

@end

@implementation FFMenuViewController {
    menuState _state;
    NSUInteger _currentlyAttemptedChallenge;
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

    self.challengeSidebar = (FFChallengeSidebar *) [self.superview viewWithTag:400];
    self.challengeSidebar.delegate = self;

    self.hotSeatSidebar = (FFHotSeatSidebar *) [self.superview viewWithTag:450];
    self.hotSeatSidebar.delegate = self;

    [self changeState:menuState_mainMenu];
}

- (void)changeState:(menuState)state {
    if (state == _state) return;

    self.hidden = state==menuState_gameRunning;
    [self.challengeMenu hide:state != menuState_chooseChallenge];
    [self.pausedMenu hide:state!=menuState_gamePaused];
    [self showSidebar:state == menuState_gameRunning];
    [self.finishedMenu hide:state!=menuState_gameFinished];
    [self.mainMenu hide:state!=menuState_mainMenu];

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
        case menuState_unset:
            // should never happen
            NSLog(@"ERROR: MenuController reset to 'unset'!");
            break;
    }

    _state = state;
}

- (void)showSidebar:(BOOL)b {
    BOOL isChallenge = [[[FFGamesCore instance] gameWithId:self.delegate.activeGameId].Type isEqualToString:kFFGameTypeSingleChallenge];

    self.challengeSidebar.hidden = !b || !isChallenge;
    self.hotSeatSidebar.hidden = !b || isChallenge;
}

- (void)didAppear {
    [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(gameChanged:) name:kFFNotificationGameChanged object:nil];
    [self.challengeSidebar didAppear];
    [self.hotSeatSidebar didAppear];
}

- (void)gameChanged:(NSNotification *)notification {
    NSString *gameID = [notification.userInfo objectForKey:kFFNotificationGameChanged_gameId];
    if (![gameID isEqualToString:[self.delegate activeGameId]]) return;     // not the active game. Ignore.

    FFGame *game = [[FFGamesCore instance] gameWithId:gameID];
    if (_state == menuState_gameRunning && game.gameState==kFFGameState_Won){
//        if (self.tmpAutoPlayer1){
//            [self.tmpAutoPlayer1 endPlaying];
//            [self.tmpAutoPlayer2 endPlaying];
//            self.tmpAutoPlayer1 = nil;
//            self.tmpAutoPlayer2 = nil;
//        }

        // SOLVED! Remember this fine victory

        int challengeIndex = [[FFGamesCore instance] indexForChallenge:game];

        if (challengeIndex+1 == [FFStorageUtil firstUnsolvedChallengeIndex]){
            [FFStorageUtil setFirstUnsolvedChallengeIndex:([FFStorageUtil firstUnsolvedChallengeIndex]+1)];
        }
        [self.challengeMenu refreshListCells];

        [self changeState:menuState_gameFinished];
    }
}

- (void)didDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.challengeSidebar didDisappear];
    [self.hotSeatSidebar didDisappear];
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
//    self.tmpAutoPlayer1 = [[FFAutoPlayer alloc] initWithGameId:hotSeatGame.Id andPlayerId:hotSeatGame.player1.id];
//    [self.tmpAutoPlayer1 startPlaying];

    self.tmpAutoPlayer2 = [[FFAutoPlayer alloc] initWithGameId:hotSeatGame.Id andPlayerId:hotSeatGame.player2.id];
    [self.tmpAutoPlayer2 startPlaying];
    //*/ /////////////////////////////////////////////////////////////

    [hotSeatGame start];

    [self.delegate activateGameWithId:hotSeatGame.Id];
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

- (void)activateChallengeAtIndex:(NSUInteger)i {
    _currentlyAttemptedChallenge = i;
    [self activateGameWithId:[[FFGamesCore instance] challenge:i].Id];
}

- (void) activateGameWithId:(NSString *)gameId {
    // start the game
    FFGame *selectedGame = [[FFGamesCore instance] gameWithId:gameId];
    [self.delegate activateGameWithId:gameId];

    if (selectedGame.gameState == kFFGameState_NotYetStarted){
        [self changeState:menuState_gameRunning];
        [selectedGame start];
    } else if (selectedGame.gameState == kFFGameState_Running){
        if (selectedGame.ActivePlayer.local){
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
    [self.challengeSidebar setActiveGameWithId:gameId];
    [self.hotSeatSidebar setActiveGameWithId:gameId];
}

- (void)proceedToNextChallenge {
    [self activateChallengeAtIndex:_currentlyAttemptedChallenge+1];
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

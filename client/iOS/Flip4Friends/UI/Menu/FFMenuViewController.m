//
//  FFMenuViewController.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 7/25/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFHistorySlider.h"
#import "FFMenuViewController.h"
#import "FFPuzzleSelectMenu.h"
#import "FFGamesCore.h"
#import "FFGameFinishedMenu.h"
#import "FFGamePausedMenu.h"
#import "FFMainMenu.h"
#import "FFAutoPlayer.h"
#import "FFChallengeSidebar.h"
#import "FFStorageUtil.h"
#import "FFHotSeatSidebar.h"
#import "FFHotSeatMenu.h"
#import "FFToast.h"
#import "FFChallengeSelectMenu.h"


typedef enum {
    menuState_unset,
    menuState_mainMenu,
    menuState_choosePuzzle,
    menuState_chooseChallenge,
    menuState_startHotSeat,
    menuState_gameStarting,
    menuState_gameRunning,
    menuState_gamePaused,
    menuState_gameFinished
} menuState;

@interface FFMenuViewController ()

@property (strong, nonatomic) FFMainMenu * mainMenu;
@property (weak, nonatomic) FFPuzzleSelectMenu *puzzleSelectMenu;
@property (weak, nonatomic) FFChallengeSelectMenu *challengeSelectMenu;
@property (weak, nonatomic) FFHotSeatMenu *hotSeatMenu;
@property (weak, nonatomic) FFGameFinishedMenu* finishedMenu;
@property (weak, nonatomic) FFGamePausedMenu* pausedMenu;

@property (weak, nonatomic) FFChallengeSidebar *challengeSidebar;
@property (weak, nonatomic) FFHotSeatSidebar* hotSeatSidebar;

@property (strong, nonatomic) FFAutoPlayer *tmpAutoPlayer1;
@property (strong, nonatomic) FFAutoPlayer *tmpAutoPlayer2;

@end

@implementation FFMenuViewController {
    menuState _state;
    NSUInteger _currentlyAttemptedPuzzle;
    NSUInteger _currentRandomChallenge;
}

- (void)didLoad {
    self.mainMenu = (FFMainMenu *)[self viewWithTag:10];
    self.mainMenu.delegate = self;

    self.puzzleSelectMenu = (FFPuzzleSelectMenu *) [self viewWithTag:500];
    self.puzzleSelectMenu.delegate = self;

    self.challengeSelectMenu = (FFChallengeSelectMenu *) [self viewWithTag:550];
    self.challengeSelectMenu.delegate = self;

    self.finishedMenu = (FFGameFinishedMenu *) [self viewWithTag:600];
    self.finishedMenu.delegate = self;

    self.pausedMenu = (FFGamePausedMenu *) [self viewWithTag:700];
    self.pausedMenu.delegate = self;

    self.hotSeatMenu = (FFHotSeatMenu *)[self viewWithTag:750];
    self.hotSeatMenu.delegate = self;

    self.challengeSidebar = (FFChallengeSidebar *) [self.superview viewWithTag:400];
    self.challengeSidebar.delegate = self;

    self.hotSeatSidebar = (FFHotSeatSidebar *) [self.superview viewWithTag:450];
    self.hotSeatSidebar.delegate = self;

    [self changeState:menuState_mainMenu];
}

- (void)changeState:(menuState)state {
    if (state == _state) return;

    self.hidden = state==menuState_gameRunning;
    [self.puzzleSelectMenu hide:state != menuState_choosePuzzle];
    [self.challengeSelectMenu hide:state != menuState_chooseChallenge];
    [self.pausedMenu hide:state!=menuState_gamePaused];
    [self showSidebar:state == menuState_gameRunning];
    [self.finishedMenu hide:state!=menuState_gameFinished];
    [self.mainMenu hide:state!=menuState_mainMenu];
    [self.hotSeatMenu hide:state!=menuState_startHotSeat];

    switch (state){
        case menuState_mainMenu:
            [self.delegate activateGameWithId:nil];
            break;
        case menuState_choosePuzzle:
            [self.delegate activateGameWithId:nil];
            break;
        case menuState_gameStarting:break;
        case menuState_gameRunning:break;
        case menuState_gamePaused:break;
        case menuState_gameFinished:break;
        case menuState_startHotSeat:break;
        case menuState_chooseChallenge:break;
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
        // SOLVED! Remember this fine victory
        int challengeIndex = [[FFGamesCore instance] indexForPuzzle:game];
        if (challengeIndex+1 == [FFStorageUtil firstUnsolvedPuzzleIndex]){
            [FFStorageUtil setFirstUnsolvedPuzzleIndex:([FFStorageUtil firstUnsolvedPuzzleIndex]+1)];
            [self showChallengeUnlockToastIfNecessary];
        }
        [self.puzzleSelectMenu refreshListCells];

        if ([game isRandomChallenge]){
            NSUInteger level = [game.challengeIndex unsignedIntegerValue];
            [FFStorageUtil setTimesWon:([FFStorageUtil getTimesWonForChallengeLevel:level] + 1)
                        forChallengeLevel:level];
        }

        [self changeState:menuState_gameFinished];
    }
    if (_state == menuState_gameRunning && game.gameState==kFFGameState_Aborted){
        [self changeState:menuState_gameFinished];
    }
}

- (void)showChallengeUnlockToastIfNecessary {
    int unlockLevel = [FFStorageUtil firstUnsolvedPuzzleIndex];

    for (int i = 0; i < [[FFGamesCore instance] autoGeneratedLevelCount]; i++){
        if (unlockLevel == [[FFGamesCore instance] unlockLevelForChallenge:i]){
            [[FFToast make:NSLocalizedString(@"challenge_unlocked", nil)] show];
        }
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
    [self changeState:menuState_startHotSeat];
}

- (void)startHotSeatGame {
    [self changeState:menuState_gameRunning];
    FFGame *hotSeatGame = [[FFGamesCore instance] generateNewHotSeatGame];
    [hotSeatGame start];

    [self.delegate activateGameWithId:hotSeatGame.Id];
    [self.hotSeatSidebar setActiveGameWithId:hotSeatGame.Id];

    [self performSelector:@selector(showHotSeatTutorialToast) withObject:nil afterDelay:0.1];
}

- (void)showHotSeatTutorialToast {
    FFToast *toast = [FFToast make:NSLocalizedString(@"hot_seat_explanation_toast", nil)];
    toast.disappearTime = 4;
    [toast show];
}

- (void)choosePuzzleSelected {
    [self changeState:menuState_choosePuzzle];
}

- (void)chooseRandomChallengeSelected {
    [self changeState:menuState_chooseChallenge];
}

- (void)goBackToMenuAfterFinished {
    FFGame *game = [[FFGamesCore instance] gameWithId:[self.delegate activeGameId]];
    if ([game.Type isEqualToString:kFFGameTypeSingleChallenge]){
        if ([game isRandomChallenge]){
            [self changeState:menuState_chooseChallenge];
        } else {
            [self changeState:menuState_choosePuzzle];
        }
    } else {
        [self changeState:menuState_mainMenu];
    }
}

- (void)giveUpAndBackToChallengeMenu {
    FFGame *selectedGame = [[FFGamesCore instance] gameWithId:[self.delegate activeGameId]];
    [selectedGame giveUp];
    if ([selectedGame isRandomChallenge]){
        [self changeState:menuState_chooseChallenge];
    } else {
        [self changeState:menuState_choosePuzzle];
    }
}

- (void)activatePuzzleAtIndex:(NSUInteger)i {
    _currentlyAttemptedPuzzle = i;
    [self activateGameWithId:[[FFGamesCore instance] puzzle:i].Id];
}

- (void)activateRandomChallengeAtIndex:(NSUInteger)i {
    _currentRandomChallenge = i;
    FFGame* game = [[FFGamesCore instance] autoGeneratedChallenge:i];
    [FFStorageUtil setTimesPlayed:([FFStorageUtil getTimesPlayedForChallengeLevel:i] + 1)
                forChallengeLevel:i];
    [self activateGameWithId:game.Id];
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
    [self activatePuzzleAtIndex:_currentlyAttemptedPuzzle + 1];
}

- (void)anotherRandomChallenge {
    [self activateRandomChallengeAtIndex:_currentRandomChallenge];
}

- (void)rematch {
    [self restartGame];
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

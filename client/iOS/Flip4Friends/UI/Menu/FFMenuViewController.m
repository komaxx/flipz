//
//  FFMenuViewController.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 7/25/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFMenuViewController.h"
#import "FFChallengeMenuControl.h"
#import "FFGamesCore.h"
#import "FFGameFinishedMenu.h"
#import "FFGamePausedMenu.h"


typedef enum {
    menuState_unset,
    menuState_chooseGame,
    menuState_gameStarting,
    menuState_gameRunning,
    menuState_gamePaused,
    menuState_gameFinished
} menuState;

@interface FFMenuViewController ()
@property (strong, nonatomic) FFChallengeMenuControl* challengeMenu;
@property (weak, nonatomic) FFGameFinishedMenu* finishedMenu;
@property (weak, nonatomic) FFGamePausedMenu* pausedMenu;
@property (weak, nonatomic) UIView* activeFooter;
@end

@implementation FFMenuViewController {
    menuState _state;
}

- (void)didLoad {
    self.challengeMenu = [[FFChallengeMenuControl alloc] initWithScrollView:(UITableView *) [self viewWithTag:500]];
    self.challengeMenu.delegate = self;

    self.finishedMenu = (FFGameFinishedMenu *) [self viewWithTag:600];
    self.finishedMenu.delegate = self;

    self.pausedMenu = (FFGamePausedMenu *) [self viewWithTag:700];
    self.pausedMenu.delegate = self;

    self.activeFooter = [self.superview viewWithTag:400];
    [(UIButton *) [self.activeFooter viewWithTag:401] addTarget:self action:@selector(pauseTapped) forControlEvents:UIControlEventTouchUpInside];

    [self changeState:menuState_chooseGame];
}

- (void)changeState:(menuState)state {
    switch (state){
        case menuState_chooseGame:
            self.hidden = NO;
            [self.challengeMenu hide:NO];
            [self.pausedMenu hide:YES];
            [self showFooter:NO];
            self.finishedMenu.hidden = YES;
            break;
        case menuState_gameStarting:
            self.hidden = NO;
            [self.pausedMenu hide:YES];
            [self.challengeMenu hide:YES];
            [self showFooter:NO];
            break;
        case menuState_gameRunning:
            self.hidden = YES;
            [self showFooter:YES];
            [self.pausedMenu hide:YES];
            [self.challengeMenu hide:YES];
            break;
        case menuState_gamePaused:
            self.hidden = NO;
            [self showFooter:YES];
            [self.pausedMenu hide:NO];
            break;
        case menuState_gameFinished:
            self.hidden = NO;
            [self showFooter:NO];
            self.finishedMenu.hidden = NO;
            break;
    }
    _state = state;
}

- (void)showFooter:(BOOL)b {
    self.activeFooter.hidden = !b;
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
        [self changeState:menuState_gameFinished];
    }
}

- (void)didDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// ////////////////////////////////////////////////////////////
// parent calls

- (void)selectedGameWithId:(NSString *)gameId {
    [self changeState:menuState_gameRunning];

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
}

- (void)pauseTapped {
    [self changeState:menuState_gamePaused];
}


// parent calls
// ////////////////////////////////////////////////////////////
// sub-menu calls

- (void)goBackToMenuAfterFinished {
    [self changeState:menuState_chooseGame];
}

- (void)giveUpAndBackToMenu {
    [self changeState:menuState_chooseGame];
}

- (void) activateGameWithId:(NSString *)gameId {
    [self.delegate activateGameWithId:gameId];
}

- (void)restartGame {
    [self.delegate restartCurrentGame];
}

- (void)resumeGame {
    [self changeState:menuState_gameRunning];
}

// sub-menu calls
// ////////////////////////////////////////////////////////////


@end

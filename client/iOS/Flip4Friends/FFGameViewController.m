//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import "FFGameViewController.h"
#import "FFGame.h"
#import "FFGamesCore.h"
#import "FFToast.h"
#import "FFTutorial.h"
#import "FFScoreRowsView.h"
#import "FFRestUndosView.h"

@interface FFGameViewController ()

@property (weak, nonatomic) UIScrollView *gameBoardDrawer;

@property (weak, nonatomic) FFBoardView *boardView;
@property (weak, nonatomic) FFMoveViewControl* moveViewControl;
@property (weak, nonatomic) FFScoreRowsView *scoreRowsView;

@property (strong, nonatomic) FFPatternsViewControl* player1PatternsControl;
@property (strong, nonatomic) FFPatternsViewControl* player2PatternsControl;

@property (weak, nonatomic) UIView *challengeFooter;
@property (weak, nonatomic) FFRestUndosView *restMovesView;

@property (weak, nonatomic) FFTutorial *tutorial;
@property (weak, nonatomic) FFToast *failToast;

@property (copy, nonatomic) NSString *lastPlayerId;

@end

@implementation FFGameViewController {
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.gameBoardDrawer = (UIScrollView *) [self viewWithTag:60];
        self.boardView = (FFBoardView *) [self viewWithTag:100];

        self.player1PatternsControl = [[FFPatternsViewControl alloc] initWithScrollView:(UIScrollView *) [self viewWithTag:200]];
        self.player1PatternsControl.delegate = self;

        self.player2PatternsControl = [[FFPatternsViewControl alloc] initWithScrollView:(UIScrollView *) [self viewWithTag:201]];
        self.player2PatternsControl.delegate = self;
        self.player2PatternsControl.secondPlayer = YES;

        self.moveViewControl = (FFMoveViewControl *) [self viewWithTag:300];
        self.moveViewControl.delegate = self;
        self.moveViewControl.boardView = self.boardView;
        
        self.scoreRowsView = (FFScoreRowsView *) [self viewWithTag:310];
        self.scoreRowsView.boardView = self.boardView;

        self.tutorial = (FFTutorial *) [self viewWithTag:212];

        self.challengeFooter = [self viewWithTag:222];
        self.restMovesView = (FFRestUndosView *) [self viewWithTag:223];
    }

    return self;
}

- (void)didAppear {
    [self.boardView didAppear];
    [self.player1PatternsControl didAppear];
    [self.player2PatternsControl didAppear];
    [self.moveViewControl didAppear];
    [self.scoreRowsView didAppear];
    [self.restMovesView didAppear];

    [self updateBoardAndDrawerPosition];

    [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(gameChanged:) name:kFFNotificationGameChanged object:nil];
}

- (void)gameChanged:(NSNotification *)notification {
    NSString *changedGameID = [notification.userInfo objectForKey:kFFNotificationGameChanged_gameId];
    if (![changedGameID isEqualToString:[self.delegate activeGameId]]) {
        return;  // ignore. Update for the wrong game (not the active one).
    }

    FFGame *game = [[FFGamesCore instance] gameWithId:changedGameID];
    if (![game.ActivePlayer.id isEqualToString:self.lastPlayerId]){
        [self updateBoardAndDrawerPosition];
    }
    [self showFailToastIfNecessaryForGame:game];
}


- (void)updateBoardAndDrawerPosition {
    FFGame *game = [[FFGamesCore instance] gameWithId:[self.delegate activeGameId ]];
    BOOL centerBoard = !game || !game.ActivePlayer;

    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.boardView.frame;
        frame.origin.x = centerBoard ? 25 : 5;
        self.boardView.frame = frame;
    }];

    if (centerBoard){
        [UIView animateWithDuration:0.4 animations:^{
            self.gameBoardDrawer.center = self.center;
        }];
    } else {
        if (game.ActivePlayer == game.player1){
            [UIView animateWithDuration:0.4 delay:0.4 options:0 animations:^{
                self.gameBoardDrawer.center =
                        CGPointMake(self.center.x, self.gameBoardDrawer.frame.size.height/2);
            } completion:^(BOOL finished) {}];
        } else {
            [UIView animateWithDuration:0.4 delay:0.4 options:0 animations:^{
                self.gameBoardDrawer.center =
                        CGPointMake(self.center.x,
                                self.bounds.size.height - self.gameBoardDrawer.frame.size.height/2);
            } completion:^(BOOL finished) {}];
        }
    }

    if (![self.delegate activeGameId]){
        self.gameBoardDrawer.center = self.center;

        CGRect frame = self.boardView.frame;
        frame.origin.x = 25;
        self.boardView.frame = frame;
    } else {
        CGRect boardFrame = self.boardView.frame;
        boardFrame.origin.x = 5;
        self.boardView.frame = boardFrame;
    }
}

- (void)selectedGameWithId:(NSString *)gameID{
    FFGame *game = [[FFGamesCore instance] gameWithId:gameID];
    [self.boardView setActiveGame:game];
    [self.scoreRowsView setActiveGame:game];
    [self.restMovesView setActiveGame:game];

    [self.failToast disappear];
    self.failToast = nil;

//    if ([game.Type isEqualToString:kFFGameTypeSingleChallenge]){
        self.gameBoardDrawer.alwaysBounceVertical = NO;
//    } else if ([game.Type isEqualToString:kFFGameTypeHotSeat]){
//        self.gameBoardDrawer.alwaysBounceVertical = YES;
//    } else if ([game.Type isEqualToString:kFFGameTypeRemote]){
//        self.gameBoardDrawer.alwaysBounceVertical = YES;
//    }

    self.player1PatternsControl.activeGameId = nil;
    self.player2PatternsControl.activeGameId = nil;
    [self.moveViewControl moveFinished];
    self.player1PatternsControl.activeGameId = gameID;
    self.player2PatternsControl.activeGameId = gameID;

    [self.tutorial showForChallenge:game];

    self.challengeFooter.hidden = ![game isRandomChallenge];

    [self updateBoardAndDrawerPosition];
}

- (void)gameCleaned {
    [self selectedGameWithId:[self.delegate activeGameId]];
}

- (void)activateUndonePatternWithId:(FFMove *)undoneMove {
    [self.player1PatternsControl activatePatternWithId:undoneMove.Pattern.Id];
    [self.moveViewControl
            startMoveWithPattern:undoneMove.Pattern
                         atCoord:undoneMove.Position
                   andAppearFrom:nil
                    withRotation:undoneMove.Orientation
                      forPlayer2:NO];
}

- (void)didLoad {
    [self.moveViewControl didLoad];
}

- (void)didDisappear {
    [self.boardView didDisappear];
    [self.player1PatternsControl didDisappear];
    [self.player2PatternsControl didDisappear];
    [self.moveViewControl didDisappear];
    [self.scoreRowsView didDisappear];
    [self.restMovesView didDisappear];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// //////////////////////////////////////////////////////////////////////////////
// calls from child controls

/**
* Called when the user selects a different pattern when previously another pattern
* was selected.
*/
- (void)executeCurrentMove {
    [self.moveViewControl executeCurrentMove];
}

- (void)setPatternSelectedForMove:(FFPattern *)pattern fromView:(UIView *)view {
    FFGame* game = [[FFGamesCore instance] gameWithId:[self.delegate activeGameId]];
    FFMove *move = [[game doneMovesForPlayer:game.ActivePlayer] objectForKey:pattern.Id];
    if (move){
        // already moved -> illegal!
        return;
    }

    BOOL player1Active = game.ActivePlayer==game.player1;
    [self.moveViewControl
            startMoveWithPattern:pattern
                         atCoord:[move Position]
                   andAppearFrom:view
                    withRotation:player1Active ? 0 : 2
                      forPlayer2:!player1Active];
}

- (void)showFailToastIfNecessaryForGame:(FFGame *)game {
    if (game.Type==kFFGameTypeSingleChallenge &&
            [game doneMovesForPlayer:game.ActivePlayer].count+1 >=
                    game.ActivePlayer.playablePatterns.count){

        // this is the last move
        if (![game stillSolvable] && !self.failToast){
            // not solvable anymore!
            FFToast *toast = [FFToast make:NSLocalizedString(@"you_failed_go_back_by_history", nil)];
            self.failToast = toast;
            self.failToast.disappearTime = 1000;    // == forever ;)

            [self.failToast show];
        }
    } else if (self.failToast) {
        [self.failToast disappear];
        self.failToast = nil;
    }
}

- (void)moveCompletedWithPattern:(FFPattern *)pattern at:(FFCoord *)coord withDirection:(NSInteger)direction {
    // make sure, we have the freshest one!
    FFGame *activeGame = [[FFGamesCore instance] gameWithId:[self.delegate activeGameId]];

    FFMove *move = [[FFMove alloc] initWithPattern:pattern atPosition:coord andOrientation:(FFOrientation) direction];
    int ret = [activeGame executeMove:move byPlayer:activeGame.ActivePlayer];

    if (ret == -5){
        [[FFToast make:NSLocalizedString(@"no_undos_left", nil)] show];
    }

    [self.moveViewControl moveFinished];
    [self.player1PatternsControl cancelMove];
    [self.player2PatternsControl cancelMove];
}

- (void)checkForWinningPositioning:(FFPattern *)pattern at:(FFCoord *)coord withDirection:(NSInteger)direction {
    FFGame *activeGame = [[FFGamesCore instance] gameWithId:[self.delegate activeGameId]];
    FFMove *move = [[FFMove alloc] initWithPattern:pattern atPosition:coord andOrientation:(FFOrientation) direction];

    if ([activeGame moveWouldWinChallenge:move byPlayer:activeGame.ActivePlayer]) {
        [self moveCompletedWithPattern:pattern at:coord withDirection:direction];
    }
}


- (void)cancelMoveWithPattern:(FFPattern *)pattern {
    [self.moveViewControl moveFinished];
    [self.player1PatternsControl cancelMove];
    [self.player2PatternsControl cancelMove];
}

// calls from child controls
// //////////////////////////////////////////////////////////////////////////////

@end
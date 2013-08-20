//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import "FFGameViewController.h"
#import "FFBoardView.h"
#import "FFGame.h"
#import "FFPatternsViewControl.h"
#import "FFMoveViewControl.h"
#import "FFGamesCore.h"
#import "FFHistorySlider.h"

@interface FFGameViewController ()

@property (weak, nonatomic) UIScrollView *gameBoardDrawer;

@property (weak, nonatomic) FFBoardView *boardView;
@property (weak, nonatomic) FFMoveViewControl* moveViewControl;
@property (weak, nonatomic) FFHistorySlider * historySlider;

@property (strong, nonatomic) FFPatternsViewControl* player1PatternsControl;
@property (strong, nonatomic) FFPatternsViewControl* player2PatternsControl;

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

        self.historySlider = (FFHistorySlider *)[self viewWithTag:350];
        self.historySlider.delegate = self;
        self.historySlider.boardView = self.boardView;

        self.historySlider.hidden = YES;
    }

    return self;
}

- (void)didAppear {
    [self.boardView didAppear];
    [self.player1PatternsControl didAppear];
    [self.player2PatternsControl didAppear];
    [self.moveViewControl didAppear];
    [self.historySlider didAppear];

    [self updateBoardAndDrawerPosition];

    [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(gameChanged:) name:kFFNotificationGameChanged object:nil];
}

- (void)gameChanged:(NSNotification *)notification {
    NSString *changedGameID = [notification.userInfo objectForKey:kFFNotificationGameChanged_gameId];
    if (![changedGameID isEqualToString:[self.delegate activeGameId]]) {
        // ignore. Update for the wrong game (not the active one).
        return;
    }

    FFGame *game = [[FFGamesCore instance] gameWithId:changedGameID];
    if (![game.activePlayer.id isEqualToString:self.lastPlayerId]){
        [self updateBoardAndDrawerPosition];
    }
}

- (void)updateBoardAndDrawerPosition {
    FFGame *game = [[FFGamesCore instance] gameWithId:[self.delegate activeGameId ]];
    BOOL centerBoard = !game || game.moveHistory.count < 1;
    centerBoard = YES;          //

    self.historySlider.hidden = centerBoard;

    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.boardView.frame;
        frame.origin.x = centerBoard ? 25 : 10;
        self.boardView.frame = frame;
    }];

    if (!game || !game.activePlayer){
        [UIView animateWithDuration:0.4 animations:^{
            self.gameBoardDrawer.center = self.center;
        }];
    } else {
        if (game.activePlayer == game.player1){
            [UIView animateWithDuration:0.4 animations:^{
                self.gameBoardDrawer.center =
                        CGPointMake(self.center.x, self.gameBoardDrawer.frame.size.height/2);
            }];
        } else {
            [UIView animateWithDuration:0.4 animations:^{
                self.gameBoardDrawer.center =
                        CGPointMake(self.center.x,
                                self.bounds.size.height - self.gameBoardDrawer.frame.size.height/2);
            }];
        }
    }
//    if (![self.delegate activeGameId]){
//        self.gameBoardDrawer.center = self.center;
//
//        CGRect frame = self.boardView.frame;
//        frame.origin.x = 25;
//        self.boardView.frame = frame;
//
//        self.historySlider.hidden = YES;
//    } else {
//        CGRect frame = self.gameBoardDrawer.frame;
//        frame.origin.y = 0;
//        self.gameBoardDrawer.frame = frame;
//
//        frame = self.boardView.frame;
//        frame.origin.x = 10;
//        self.boardView.frame = frame;
//
//        self.historySlider.hidden = NO;
//    }
}

- (void)selectedGameWithId:(NSString *)gameID{
    FFGame *game = [[FFGamesCore instance] gameWithId:gameID];
    [self.boardView setActiveGame:game];

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
    
    self.historySlider.activeGameId = gameID;

    [self updateBoardAndDrawerPosition];
}

- (void)gameCleaned {
    [self selectedGameWithId:[self.delegate activeGameId]];
}

- (void)didLoad {
    [self.moveViewControl didLoad];
}

- (void)didDisappear {
    [self.boardView didDisappear];
    [self.player1PatternsControl didDisappear];
    [self.player2PatternsControl didDisappear];
    [self.moveViewControl didDisappear];
    [self.historySlider didDisappear];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// //////////////////////////////////////////////////////////////////////////////
// calls from child controls

- (void)setPatternSelectedForMove:(FFPattern *)pattern fromView:(UIView *)view {
    FFGame* game = [[FFGamesCore instance] gameWithId:[self.delegate activeGameId]];
    FFMove *move = [game.activePlayer.doneMoves objectForKey:pattern.Id];
    if (move){
        [game undoMove:move];
    }

    BOOL player1Active = game.activePlayer==game.player1;

    [self.moveViewControl
            startMoveWithPattern:pattern
                         atCoord:[move Position]
                   andAppearFrom:view
                    withRotation:player1Active ? 0 : 2
                      forPlayer2:!player1Active];
}

- (void)moveCompletedWithPattern:(FFPattern *)pattern at:(FFCoord *)coord withDirection:(NSInteger)direction {
    // make sure, we have the freshest one!
    FFGame *activeGame = [[FFGamesCore instance] gameWithId:[self.delegate activeGameId]];

    FFMove *move = [[FFMove alloc] initWithPattern:pattern atPosition:coord andOrientation:(FFOrientation) direction];
    [activeGame executeMove:move byPlayer:activeGame.activePlayer];

    [self.moveViewControl moveFinished];
    [self.player1PatternsControl cancelMove];
    [self.player2PatternsControl cancelMove];
}

- (void)cancelMoveWithPattern:(FFPattern *)pattern {
    [self.moveViewControl moveFinished];
    [self.player1PatternsControl cancelMove];
    [self.player2PatternsControl cancelMove];
}

- (void)showHistoryStartingFromStepsBack:(NSInteger) stepsBack {
    [self cancelMoveWithPattern:nil];

    [self.boardView showHistoryStartingFromStepsBack:(NSUInteger) stepsBack];
    [self.player1PatternsControl showHistoryStartingFromStepsBack:(NSUInteger) stepsBack];
    [self.player2PatternsControl showHistoryStartingFromStepsBack:(NSUInteger) stepsBack];
}

- (void)hideHistory {
    [self.boardView hideHistory];
    [self.player1PatternsControl hideHistory];
    [self.player2PatternsControl hideHistory];
}

// calls from child controls
// //////////////////////////////////////////////////////////////////////////////

@end
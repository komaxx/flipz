//
//  FFTestGameViewController.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 9/25/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFTestGameViewController.h"
#import "FFGame.h"
#import "FFGamesCore.h"
#import "FFCreateChallengeSession.h"

@interface FFTestGameViewController ()

@property (weak, nonatomic) IBOutlet FFBoardView *boardView;
@property (weak, nonatomic) IBOutlet FFMoveViewControl *moveViewControl;
@property (weak, nonatomic) IBOutlet FFHistorySlider *historySlider;
@property (weak, nonatomic) IBOutlet UIScrollView *player1PatternsScroller;

@property (strong, nonatomic) FFPatternsViewControl *player1PatternsControl;

@end

@implementation FFTestGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.player1PatternsControl = [[FFPatternsViewControl alloc] initWithScrollView:self.player1PatternsScroller];
    self.player1PatternsControl.delegate = self;

    self.moveViewControl.boardView = self.boardView;
    self.moveViewControl.delegate = self;
    [self.moveViewControl didLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.boardView didAppear];
    [self.player1PatternsControl didAppear];
    [self.moveViewControl didAppear];
    [self.historySlider didAppear];

    [self selectedGameWithId:[FFCreateChallengeSession tmpGameId]];
}

- (void)selectedGameWithId:(NSString *)gameID{
    FFGame *game = [[FFGamesCore instance] gameWithId:gameID];
    [self.boardView setActiveGame:game];

    self.player1PatternsControl.activeGameId = nil;
    [self.moveViewControl moveFinished];
    self.player1PatternsControl.activeGameId = gameID;

    self.historySlider.activeGameId = gameID;

    [game start];
}

- (IBAction)cleanTapped:(id)sender {
    FFGame *game = [[FFGamesCore instance] gameWithId:[FFCreateChallengeSession tmpGameId]];
    [game clean];
}

- (void)gameCleaned {
    [self selectedGameWithId:[FFCreateChallengeSession tmpGameId]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.boardView didDisappear];
    [self.player1PatternsControl didDisappear];
    [self.moveViewControl didDisappear];
    [self.historySlider didDisappear];

    [super viewDidDisappear:animated];
}

// //////////////////////////////////////////////////////////////////////////////
// calls from child controls

- (void)setPatternSelectedForMove:(FFPattern *)pattern fromView:(UIView *)view {
    FFGame* game = [[FFGamesCore instance] gameWithId:[FFCreateChallengeSession tmpGameId]];
    FFMove *move = [[game doneMovesForPlayer:game.ActivePlayer] objectForKey:pattern.Id];
    if (move){
        // already moved -> illegal!
        NSLog(@"This pattern was already moved!");
        return;
    }

    [self.moveViewControl
            startMoveWithPattern:pattern
                         atCoord:[move Position]
                   andAppearFrom:view
                    withRotation:NO
                      forPlayer2:NO];
}

- (IBAction)closeTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)executeCurrentMove {
    [self.moveViewControl executeCurrentMove];
}

- (void)checkForWinningPositioning:(FFPattern *)pattern at:(FFCoord *)coord withDirection:(NSInteger)direction {
    // NO
//    FFGame *activeGame = [[FFGamesCore instance] gameWithId:[self.delegate activeGameId]];
//    FFMove *move = [[FFMove alloc] initWithPattern:pattern atPosition:coord andOrientation:(FFOrientation) direction];
//
//    if ([activeGame moveWouldWinChallenge:move byPlayer:activeGame.ActivePlayer]) {
//        [self moveCompletedWithPattern:pattern at:coord withDirection:direction];
//    }
}

- (void)moveCompletedWithPattern:(FFPattern *)pattern at:(FFCoord *)coord withDirection:(NSInteger)direction {
    // make sure, we have the freshest one!
    FFGame *activeGame = [[FFGamesCore instance] gameWithId:[FFCreateChallengeSession tmpGameId]];

    FFMove *move = [[FFMove alloc] initWithPattern:pattern atPosition:coord andOrientation:(FFOrientation) direction];
    [activeGame executeMove:move byPlayer:activeGame.ActivePlayer];

    [self.moveViewControl moveFinished];
    [self.player1PatternsControl cancelMove];
}

- (void)cancelMoveWithPattern:(FFPattern *)pattern {
    [self.moveViewControl moveFinished];
    [self.player1PatternsControl cancelMove];
}

// calls from child controls
// //////////////////////////////////////////////////////////////////////////////

@end

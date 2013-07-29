//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import "FFGameViewController.h"
#import "FFBoardView.h"
#import "FFGame.h"
#import "FFPattern.h"
#import "FFPatternsViewControl.h"
#import "FFMoveViewControl.h"
#import "FFPatternView.h"
#import "FFGamesCore.h"
#import "FFPatternGenerator.h"
#import "FFViewController.h"

@interface FFGameViewController ()

@property (weak, nonatomic) FFBoardView *boardView;
@property (weak, nonatomic) FFMoveViewControl* moveViewControl;
@property (strong, nonatomic) FFPatternsViewControl* patternsControl;

@end

@implementation FFGameViewController {
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor darkGrayColor];

        self.boardView = (FFBoardView *) [self viewWithTag:100];

        self.patternsControl = [[FFPatternsViewControl alloc] initWithScrollView:(UIScrollView *) [self viewWithTag:200]];
        self.patternsControl.delegate = self;

        self.moveViewControl = (FFMoveViewControl *) [self viewWithTag:300];
        self.moveViewControl.delegate = self;
        self.moveViewControl.boardView = self.boardView;
    }

    return self;
}

- (void)pauseTapped {
    [self.delegate pauseTapped];
}

- (void)didAppear {
    [self.boardView didAppear];
    [self.patternsControl didAppear];
    [self.moveViewControl didAppear];

    [self updateElementPositionsAnimated:NO];
}

- (void)selectedGameWithId:(NSString *)gameID{
    [self updateElementPositionsAnimated:YES];

    FFGame *game = [[FFGamesCore instance] gameWithId:gameID];
    [self.boardView updateWithGame:game];

    self.patternsControl.activeGameId = nil;
    self.patternsControl.activeGameId = gameID;
}

- (void)updateElementPositionsAnimated:(BOOL)animated {
    if (![self.delegate activeGameId]){
        self.boardView.center = self.center;
    } else {
        CGRect rect = self.boardView.frame;
        rect.origin = CGPointMake(rect.origin.x, 10);
        self.boardView.frame = rect;
    }

}

- (void)didLoad {
    [self.moveViewControl didLoad];
}

- (void)didDisappear {
    [self.boardView didDisappear];
    [self.patternsControl didDisappear];
    [self.moveViewControl didDisappear];
}

// //////////////////////////////////////////////////////////////////////////////
// calls from child controls

- (void)setPatternSelectedForMove:(FFPattern *)pattern fromView:(UIView *)view {
    FFGame* game = [[FFGamesCore instance] gameWithId:[self.delegate activeGameId]];
    FFMove *move = [game.activePlayer.doneMoves objectForKey:pattern.Id];
    if (move){
        [game undoMove:move];
    }

    [self.moveViewControl startMoveWithPattern:pattern atCoord:[move Position] andAppearFrom:view];
}

- (void)moveCompletedWithPattern:(FFPattern *)pattern at:(FFCoord *)coord withDirection:(NSInteger)direction {
    // make sure, we have the freshest one!
    FFGame *activeGame = [[FFGamesCore instance] gameWithId:[self.delegate activeGameId]];

    FFMove *move = [[FFMove alloc] initWithPattern:pattern atPosition:coord andOrientation:(FFOrientation) direction];
    [activeGame executeMove:move byPlayer:activeGame.activePlayer];

    [self.moveViewControl moveFinished];
    [self.patternsControl cancelMove];
}

- (void)cancelMoveWithPattern:(FFPattern *)pattern {
    [self.moveViewControl moveFinished];
    [self.patternsControl cancelMove];
}

// calls from child controls
// //////////////////////////////////////////////////////////////////////////////

@end
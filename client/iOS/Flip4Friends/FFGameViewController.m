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

//#define DO_INTRO_RANDOM_MOVES

@interface FFGameViewController ()

@property (weak, nonatomic) FFBoardView *boardView;
@property (weak, nonatomic) FFMoveViewControl* moveViewControl;
@property (strong, nonatomic) FFPatternsViewControl* patternsControl;

@property (strong, nonatomic) FFGame *activeGame;

@end

@implementation FFGameViewController {
    BOOL _visible;
    BOOL _runningIntro;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.boardView = (FFBoardView *) [self viewWithTag:100];
        self.patternsControl = [[FFPatternsViewControl alloc] initWithScrollView:(UIScrollView *) [self viewWithTag:200]];
        self.patternsControl.delegate = self;
        self.moveViewControl = (FFMoveViewControl *) [self viewWithTag:300];
        self.moveViewControl.delegate = self;
        self.moveViewControl.boardView = self.boardView;

        // create a mock-up game that just makes the board flip a lot...
        _runningIntro = YES;
        self.activeGame = [[FFGame alloc] initWithId:@"introDemoGameId" Type:kFFGameTypeDemo andBoardSize:6];
        [self.activeGame.Board shuffle];

        [self.boardView updateWithGame:self.activeGame];

        self.patternsControl.activeGameId = @"fake";
    }

    return self;
}


- (void)didAppear {
    _visible = YES;
    [self.boardView didAppear];
    [self.patternsControl didAppear];
    [self.moveViewControl didAppear];

#ifdef DO_INTRO_RANDOM_MOVES
    [self doRandomIntroMove];
    #endif
}


// ///////////////////////////////////////////////////////////////////////////
// intro stuff

- (void)doRandomIntroMove {
    if (!_runningIntro || !_visible) return;

    FFPattern *randomPattern = [[FFPattern alloc] initWithRandomCoords:(arc4random()%8) andMaxDistance:3];
    FFMove *randomMove = [self makeRandomMoveWithPattern:randomPattern];

    [self.activeGame executeMove:randomMove byPlayer:nil];
    [self.boardView updateWithGame:self.activeGame];

    [self performSelector:@selector(doRandomIntroMove) withObject:nil afterDelay:0.4];
}

- (FFMove *)makeRandomMoveWithPattern:(FFPattern *)pattern {
    NSUInteger maxX = self.activeGame.Board.BoardSize - pattern.SizeX;
    NSUInteger maxY = self.activeGame.Board.BoardSize - pattern.SizeY;

    FFCoord *movePos = [[FFCoord alloc] initWithX:(ushort)(rand()%(maxX+1)) andY:(ushort)(rand()%(maxY+1))];

    FFMove *move = [[FFMove alloc] initWithPattern:pattern atPosition:movePos andOrientation:kFFOrientation_0_degrees];
    return move;
}

- (void)didLoad {
    [self.moveViewControl didLoad];
}

- (void)didDisappear {
    _visible = NO;
    [self.boardView didDisappear];
    [self.patternsControl didDisappear];
    [self.moveViewControl didDisappear];
}

// //////////////////////////////////////////////////////////////////////////////
// calls from child controls

- (void)setPatternSelectedForMove:(FFPattern *)pattern {
    [self.moveViewControl startMoveWithPattern:pattern];
}

// calls from child controls
// //////////////////////////////////////////////////////////////////////////////

@end
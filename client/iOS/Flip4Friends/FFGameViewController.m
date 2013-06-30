//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import "FFGameViewController.h"
#import "FFBoardView.h"
#import "FFGame.h"
#import "FFPattern.h"
#import "FFPatternsViewControl.h"


@interface FFGameViewController ()

@property (weak, nonatomic) FFBoardView *boardView;
@property (weak, nonatomic) FFPatternsViewControl* patternsView;

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
        self.patternsView = (FFPatternsViewControl *) [self viewWithTag:200];

        // create a mock-up game that just makes the board flip a lot...
        _runningIntro = YES;
        self.activeGame = [[FFGame alloc] initWithId:@"introDemoGameId" Type:kFFGameTypeDemo andBoardSize:6];
        [self.activeGame.Board shuffle];

        [self.boardView updateWithGame:self.activeGame];
    }

    return self;
}

- (void)didAppear {
    _visible = YES;
    [self.boardView didAppear];
    [self.patternsView didAppear];

    [self doRandomIntroMove];
}


// ///////////////////////////////////////////////////////////////////////////
// intro stuff

- (void)doRandomIntroMove {
    if (!_runningIntro || !_visible) return;

    FFPattern *randomPattern = [[FFPattern alloc] initWithRandomCoords:(arc4random()%5) andMaxDistance:3];
    FFMove *randomMove = [self makeRandomMoveWithPattern:randomPattern];

    [self.activeGame executeMove:randomMove byPlayer:nil];
    [self.boardView updateWithGame:self.activeGame];

    [self performSelector:@selector(doRandomIntroMove) withObject:nil afterDelay:1];
}

- (FFMove *)makeRandomMoveWithPattern:(FFPattern *)pattern {
    NSUInteger maxX = self.activeGame.Board.BoardSize - pattern.SizeX;
    NSUInteger maxY = self.activeGame.Board.BoardSize - pattern.SizeY;

    FFCoord *movePos = [[FFCoord alloc] initWithX:(ushort)(rand()%(maxX+1)) andY:(ushort)(rand()%(maxY+1))];

    FFMove *move = [[FFMove alloc] initWithPattern:pattern atPosition:movePos andOrientation:kFFOrientation_0_degrees];
    return move;
}

- (void)didDisappear {
    _visible = NO;
    [self.boardView didDisappear];
    [self.patternsView didDisappear];
}
@end
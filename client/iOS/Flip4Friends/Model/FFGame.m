//
//  FFGame.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFGame.h"
#import "FFPattern.h"
#import "FFHistoryStep.h"

NSString *const kFFNotificationGameChanged = @"ffGameChanged";
NSString *const kFFNotificationGameChanged_gameId = @"gameId";

NSString *const kFFGameTypeSingleChallenge = @"gtLocalChallenge";
NSString *const kFFGameTypeHotSeat = @"gtHotSeat";
NSString *const kFFGameTypeRemote = @"gtRemote";


@interface FFGame ()

@property(nonatomic, readwrite) NSString *const Type;
@property(nonatomic, copy, readwrite) NSString *Id;
@property(nonatomic, readwrite) GameState gameState;

@property(nonatomic, strong, readwrite) FFPlayer *player1;
@property(nonatomic, strong, readwrite) FFPlayer *player2;

@property(nonatomic, readwrite) NSUInteger currentHistoryBackSteps;
@property(nonatomic, strong, readwrite) NSArray *history;       // the current state is always at pos 0!

@end

@implementation FFGame {
    NSInteger _challengeMoves;
    NSInteger _doneUndos;
}
@synthesize Id = _Id;
@synthesize Type = _Type;


- (id)initWithId:(NSString *)id Type:(NSString * const)type andBoardSize:(NSInteger)size {
    self = [super init];
    if (self){
        self.Id = id;
        self.Type = type;
        self.gameState = kFFGameState_NotYetStarted;

        self.history = [[NSMutableArray alloc] initWithCapacity:10];

        self.player1 = [[FFPlayer alloc] init];
        self.player1.local = YES;
        self.player1.id = @"_unknownPlayer_";

        FFBoard *board = [[FFBoard alloc] initWithSize:(NSUInteger) size];
        board.BoardType = kFFBoardType_multiStated_clamped;
        FFHistoryStep *rootHistoryStep = [[FFHistoryStep alloc] initCleanStepWithBoard:board];
        rootHistoryStep.activePlayerId = self.player1.id;
        [(NSMutableArray *) self.history addObject:rootHistoryStep];
    }
    return self;
}

- (id)initGeneratedChallengeWithId:(NSString *)id andBoard:(FFBoard *)board andPatterns:(NSMutableArray *)patterns andMaxUndos:(NSUInteger)undos {
    self = [super init];
    if (self){
        self.Id = id;
        self.Type = kFFGameTypeSingleChallenge;
        self.gameState = kFFGameState_NotYetStarted;
        self.maxUndos = @(undos);

        self.history = [[NSMutableArray alloc] initWithCapacity:10];

        self.player1 = [[FFPlayer alloc] init];
        self.player1.local = YES;
        self.player1.id = @"autoChallengePlayer";
        [self.player1 resetWithPatterns:patterns];

        FFHistoryStep *rootHistoryStep = [[FFHistoryStep alloc] initCleanStepWithBoard:board];
        rootHistoryStep.activePlayerId = self.player1.id;
        [(NSMutableArray *) self.history addObject:rootHistoryStep];
    }
    return self;
}

- (id)initTestChallengeWithId:(NSString*)id andBoard:(FFBoard *)board{
    self = [super init];
    if (self){
        self.Id = id;
        self.Type = kFFGameTypeSingleChallenge;
        self.gameState = kFFGameState_NotYetStarted;

        self.player1 = [[FFPlayer alloc] init];
        self.player1.id = @"challengeTestPlayer";
        self.player1.local = YES;

        self.history = [[NSMutableArray alloc] initWithCapacity:10];
        FFHistoryStep *rootHistoryStep = [[FFHistoryStep alloc] initCleanStepWithBoard:board];
        rootHistoryStep.activePlayerId = self.player1.id;
        [(NSMutableArray *) self.history addObject:rootHistoryStep];
    }
    return self;
}

- (id)initHotSeat {
    self = [super init];
    if (self){
        static int id = 0;

        self.Id = [NSString stringWithFormat:@"hotSeat%i", ++id];
        self.Type = kFFGameTypeHotSeat;
        self.gameState = kFFGameState_NotYetStarted;

        self.player1 = [[FFPlayer alloc] init];
        self.player1.local = YES;
        self.player1.id = [NSString stringWithFormat:@"_LocalHotSeat%iPlayer1", id];

        self.player2 = [[FFPlayer alloc] init];
        self.player2.local = YES;
        self.player2.id = [NSString stringWithFormat:@"_LocalHotSeat%iPlayer2", id];

        FFBoard *board = [[FFBoard alloc] initWithSize:(NSUInteger) 6];
        board.BoardType = kFFBoardType_twoStated;
        board.lockMoves = 2;
        FFHistoryStep *rootHistoryStep = [[FFHistoryStep alloc] initCleanStepWithBoard:board];
        rootHistoryStep.activePlayerId = self.player1.id;

        self.history = [[NSMutableArray alloc] initWithCapacity:10];
        [(NSMutableArray *) self.history addObject:rootHistoryStep];
    }
    return self;
}

- (BOOL)moveWouldWinChallenge:(FFMove *)move byPlayer:(FFPlayer *)player {
    int checkScore = [self checkIfValidMove:move byPlayer:player];
    if (checkScore != 0) return NO;

    FFBoard *boardCopy = [[FFBoard alloc] initWithBoard:[self Board]];
    [boardCopy doMoveWithCoords:[move buildToFlipCoords]];

    return [boardCopy isInTargetState];
}

/**
* @return: 0 when everything worked out, and the move was done.
* -1, -2, -3 : see checkIfValidMove
* -5: No undo left (only in random challenges)
*/
- (NSInteger)executeMove:(FFMove *)move byPlayer:(FFPlayer *)player {
    int checkScore = [self checkIfValidMove:move byPlayer:player];
    if (checkScore != 0) return checkScore;

    if (self.currentHistoryBackSteps > 0){
        if ([self isRandomChallenge] && [self undosLeft] < 1){
            NSLog(@"Not allowing the move: No undos left?");
            return -5;
        }

        _doneUndos++;
        for (int i = 0; i < self.currentHistoryBackSteps; i++){
            [(NSMutableArray *) self.history removeObjectAtIndex:0];
        }
        self.currentHistoryBackSteps = 0;

        [[self currentHistoryStep] returnedToStep];
    }

    _challengeMoves++;

    FFHistoryStep *nuStep = [[FFHistoryStep alloc]
            initWithMove:move
               byPlayer1:player==self.player1
         andPreviousStep:[self currentHistoryStep]];

    [(NSMutableArray *)self.history insertObject:nuStep atIndex:0];

    [self keepHotSeatScore];

    [self checkIfGameFinished];
    [self endPlayersTurn];

    [self notifyChange];

    return 0;
}

- (void)keepHotSeatScore {
    if (self.Type != kFFGameTypeHotSeat) return;
    self.player1.score += [[self Board] scoreForColor:0];
    self.player2.score += [[self Board] scoreForColor:1];

//    NSLog(@"Combined Score: %i / %i", self.player1.score, self.player2.score);
}

- (int)checkIfValidMove:(FFMove *)move byPlayer:(FFPlayer *)player {
    if (self.gameState == kFFGameState_Won || self.gameState == kFFGameState_Aborted){
        NSLog(@"Illegal move: game already finished. Declined.");
        return -1;
    } else if (![move isLegalOnBoardWithSize:self.Board.BoardSize]){
        NSLog(@"Illegal move: outside of boardView. Declined.");
        return -2;
    }

    if (player != self.ActivePlayer){
        NSLog(@"Illegal move: not by active player!!");
        return -3;
    }
    return 0;
}

- (void)goBackInHistory:(NSInteger)stepsBack {
    if (![self.Type isEqualToString:kFFGameTypeSingleChallenge]) return;
    if (stepsBack < 0) {
        stepsBack = 0;
    } else if (stepsBack >= self.history.count){
        NSLog(@"ERROR! History stack is too small to go %i steps back!", stepsBack);
        NSLog(@"Aborted.");
        return;
    }

    self.currentHistoryBackSteps = (NSUInteger) stepsBack;
    [self notifyChange];
}

- (void)checkIfGameFinished {
    if (self.Type == kFFGameTypeSingleChallenge){
        if ([self.Board isSingleChromatic]){
            self.gameState = kFFGameState_Won;
        } else if ([self isRandomChallenge]
                && [self undosLeft]<=0
                && [self puzzleMovesLeft] < 2
                && ![self stillSolvable]){
            self.gameState = kFFGameState_Aborted;
        }
    } else if (self.Type == kFFGameTypeHotSeat){
        if ([self allPatternsPlayedForPlayer:self.player1] && [self allPatternsPlayedForPlayer:self.player2]){
            [self currentHistoryStep].activePlayerId = nil;
            self.gameState = kFFGameState_Won;
        }
    }
}

- (int)puzzleMovesLeft {
    return self.ActivePlayer.playablePatterns.count - [self doneMovesForPlayer:self.ActivePlayer].count;
}

- (NSInteger)undosLeft {
    return [self.maxUndos intValue] - _doneUndos;
}

- (BOOL)isRandomChallenge {
    return nil!=_maxUndos;
}

- (BOOL)stillSolvable {
    if (self.Type != kFFGameTypeSingleChallenge) return NO; // only challenges are solvable

    FFHistoryStep *step = [self currentHistoryStep];
    int restFlips = 0;
    for (FFPattern *pattern in self.ActivePlayer.playablePatterns){
        if ([step.doneMovesPlayer1 objectForKey:pattern.Id]) continue;
        restFlips += pattern.Coords.count;
    }

    return [step.board computeMinimumRestFlips] <= restFlips;
}

- (BOOL)allPatternsPlayedForPlayer:(FFPlayer *)player {
    NSDictionary *playedMoves = player==self.player1 ?
            [self currentHistoryStep].doneMovesPlayer1 : [self currentHistoryStep].doneMovesPlayer2;
    for (FFPattern *pattern in player.playablePatterns) {
        if (![playedMoves objectForKey:pattern.Id]) return NO;
    }
    return YES;
}

- (FFHistoryStep *)currentHistoryStep {
    return [self.history objectAtIndex:self.currentHistoryBackSteps];
}

- (void)endPlayersTurn {
    if (self.Type == kFFGameTypeSingleChallenge){
        // nothing
    } else if (self.Type == kFFGameTypeHotSeat){
        if ([self.player1.id isEqualToString:[self currentHistoryStep].activePlayerId]){
            [self currentHistoryStep].activePlayerId = self.player2.id;
        } else {
            [self currentHistoryStep].activePlayerId = self.player1.id;
        }
    }
}

- (void)notifyChange {
    // postpone in same thread?
    [self doNotify];
}

- (void)doNotify {
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:self.Id, kFFNotificationGameChanged_gameId, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFFNotificationGameChanged object:nil userInfo:userInfo];
}

- (void)clean {
    if (self.Type != kFFGameTypeSingleChallenge){
        NSLog(@"Tried to clean a non-challenge game. Not doing it. Na-a!");
        return;
    }

    if (self.history.count < 1){
        NSLog(@"Not clearing, nothing in the history.");
        return;
    }


    while (self.history.count > 1){
        [(NSMutableArray *) self.history removeObjectAtIndex:0];
    }
    self.currentHistoryBackSteps = 0;

    [self notifyChange];
}

- (void)start {
    if (self.gameState == kFFGameState_NotYetStarted){
        [self generateGame];
        self.player1.score = 0;
        self.player2.score = 0;

        [self currentHistoryStep].activePlayerId = self.player1.id;
        self.gameState = kFFGameState_Running;
    } else if (self.gameState == kFFGameState_Running){
        NSLog(@"Can not start running game. ignored.");
    } else {
        NSLog(@"REstarting finished game! %@", self.Id);

        [self generateGame];
        self.player1.score = 0;
        self.player2.score = 0;
        self.currentHistoryBackSteps = 0;
        [self currentHistoryStep].activePlayerId = self.player1.id;
        self.gameState = kFFGameState_Running;
    }

    [self notifyChange];
}

- (void)giveUp {
    self.gameState = kFFGameState_Aborted;
    [self notifyChange];
}

- (NSUInteger)scoreForColor:(int)color {
    if (color == 0) return self.player1.score;
    if (color == 1) return self.player2.score;
    NSLog(@"ununsed color: %i", color);
    return 0;
}

- (int)challengeMovesPlayed {
    return _challengeMoves;
}

- (FFPlayer*)winningPlayer {
    if ([self.Type isEqualToString:kFFGameTypeSingleChallenge]){
        return self.player1;
    }

    if (self.player1.score > self.player2.score) return self.player1;
    if (self.player1.score < self.player2.score) return self.player2;

//    NSUInteger scoreWhite = [self.Board scoreForColor:0];
//    NSUInteger scoreBlack = [self.Board scoreForColor:1];
//    if (scoreWhite > scoreBlack){
//        return self.player1;
//    } else if (scoreWhite < scoreBlack){
//        return self.player2;
//    }

    // winning condition 2: who has more tiles
    //*
    NSUInteger whiteTileCount = [self.Board countTilesWithColor:0];
    NSUInteger blackTileCount = self.Board.BoardSize*self.Board.BoardSize - whiteTileCount;
    if (whiteTileCount > blackTileCount){
        return self.player1;
    } else if (whiteTileCount < blackTileCount){
        return self.player2;
    }
    //*/

    // winning condition 3: cluster size
    /*
    NSUInteger whiteClusterSize = [self.Board computeMaxClusterSizeForColor:0];
    NSUInteger blackClusterSize = [self.Board computeMaxClusterSizeForColor:1];
    if (whiteClusterSize > blackClusterSize){
        return self.player1;
    } else if (whiteClusterSize < blackClusterSize){
        return self.player2;
    }
    //*/

    NSLog(@"player 1 winning by default");

    return self.player1;
}

// /////////////////////////////////////////////////////////////////////////////////////
// game generation

- (void)generateGame {
    _challengeMoves = 0;
    _doneUndos = 0;

    if (self.Type == kFFGameTypeSingleChallenge){
        [self clean];

        //  TODO: Maybe re-phrase the puzzle (mirror / rotate it).

    } else if (self.Type == kFFGameTypeHotSeat){
        [self generateHotSeatGame];
    }
}

// game generation
// /////////////////////////////////////////////////////////////////////////////////////
// hot seat

- (void)generateHotSeatGame {
    // make the boardView: random coloring
    [self.Board checker];
    [self.Board unlock];

    // give the players some patterns
    NSMutableArray *player1Patterns = [[NSMutableArray alloc] initWithCapacity:8];
    NSMutableArray *player2Patterns = [[NSMutableArray alloc] initWithCapacity:8];

    for (int i = 0; i < 8; i++){
        NSUInteger maxDistance = 3 + arc4random()%2;
        NSUInteger tileCount = MAX(3,
                    arc4random()%4 + arc4random()%4);
        tileCount = MAX(i,2);

        tileCount = MIN(tileCount, maxDistance*maxDistance);
        FFPattern *p1Pattern = [[FFPattern alloc]
                initWithRandomCoords:tileCount
                      andMaxDistance:maxDistance
                    andAllowRotating:YES];

        [player1Patterns addObject:p1Pattern];
        [player2Patterns addObject:[[FFPattern alloc] initAsMirroredCloneFrom:p1Pattern]];
    }

    [self.player1 resetWithPatterns:player1Patterns];
    [self.player2 resetWithPatterns:player2Patterns];
}

- (FFBoard *)Board {
    return [self currentHistoryStep].board;
}

- (NSDictionary *)doneMovesForPlayer:(FFPlayer *)player {
    if ([self.player2.id isEqualToString:player.id]){
        return [self currentHistoryStep].doneMovesPlayer2;
    }
    return [self currentHistoryStep].doneMovesPlayer1;
}

- (FFPlayer *)ActivePlayer {
    NSString* activePlayerId = [self currentHistoryStep].activePlayerId;
    if (!activePlayerId) return nil;
    return ([activePlayerId isEqualToString:self.player2.id]) ? self.player2 : self.player1;
}


// hot seat
// /////////////////////////////////////////////////////////////////////////////////////
// DEBUG

- (void)DEBUG_replaceBoardWith:(FFBoard *)board {
    NSLog(@"Replacing Board in game! This is DEBUG, right?");

    [[self currentHistoryStep] DEBUG_replaceBoardWith:board];
    [self notifyChange];
}
@end

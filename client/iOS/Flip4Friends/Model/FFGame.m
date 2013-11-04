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

- (NSInteger)executeMove:(FFMove *)move byPlayer:(FFPlayer *)player {
    int checkScore = [self checkIfValidMove:move byPlayer:player];
    if (checkScore != 0) return checkScore;

    _challengeMoves++;

    if (self.currentHistoryBackSteps > 0){
        for (int i = 0; i < self.currentHistoryBackSteps; i++){
            [(NSMutableArray *) self.history removeObjectAtIndex:0];
        }
        self.currentHistoryBackSteps = 0;

        [[self currentHistoryStep] returnedToStep];
    }

    FFHistoryStep *nuStep = [[FFHistoryStep alloc]
            initWithMove:move
               byPlayer1:player==self.player1
         andPreviousStep:[self currentHistoryStep]];

    [(NSMutableArray *)self.history insertObject:nuStep atIndex:0];

    [self checkIfGameFinished];
    [self endPlayersTurn];

    [self notifyChange];

    return 0;
}

- (int)checkIfValidMove:(FFMove *)move byPlayer:(FFPlayer *)player {
    if (self.gameState == kFFGameState_Finished){
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
        if (![self.Board isSingleChromatic]) return;

        NSLog(@"Took me %i moves", _challengeMoves);

        self.gameState = kFFGameState_Finished;
    } else if (self.Type == kFFGameTypeHotSeat){
        if ([self allPatternsPlayedForPlayer:self.player1] && [self allPatternsPlayedForPlayer:self.player1]){
            [self currentHistoryStep].activePlayerId = nil;
            self.gameState = kFFGameState_Finished;
        }
    }
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

    _challengeMoves++;


    for (NSUInteger i = self.history.count-1; i > 0; --i){
        [(NSMutableArray *) self.history removeObjectAtIndex:i];
    }

    [self notifyChange];
}

- (void)start {
    if (self.gameState == kFFGameState_NotYetStarted){
        [self generateGame];

        [self currentHistoryStep].activePlayerId = self.player1.id;
        self.gameState = kFFGameState_Running;
    } else if (self.gameState == kFFGameState_Running){
        NSLog(@"Can not start running game. ignored.");
    } else {
        NSLog(@"REstarting finished game! %@", self.Id);

        [self generateGame];
        _challengeMoves = 0;
        self.currentHistoryBackSteps = 0;
        [self currentHistoryStep].activePlayerId = self.player1.id;
        self.gameState = kFFGameState_Running;
    }

    [self notifyChange];
}

- (void)giveUp {
    self.gameState = kFFGameState_Finished;
    [self.Board cleanMonochromaticTo:9];
    [self notifyChange];
}

- (FFPlayer*)winningPlayer {
    if ([self.Type isEqualToString:kFFGameTypeSingleChallenge]){
        return self.player1;
    }

    NSUInteger scoreWhite = [self.Board scoreForColor:0];
    NSUInteger scoreBlack = [self.Board scoreForColor:1];
    if (scoreWhite > scoreBlack){
        return self.player1;
    } else if (scoreWhite < scoreBlack){
        return self.player2;
    }

    // winning condition 1: who has more tiles
    NSUInteger whiteTileCount = [self.Board countTilesWithColor:0];
    NSUInteger blackTileCount = self.Board.BoardSize*self.Board.BoardSize - whiteTileCount;
    if (whiteTileCount > blackTileCount){
        return self.player1;
    } else if (whiteTileCount < blackTileCount){
        return self.player2;
    }

    NSUInteger whiteClusterSize = [self.Board computeMaxClusterSizeForColor:0];
    NSUInteger blackClusterSize = [self.Board computeMaxClusterSizeForColor:1];
    if (whiteClusterSize > blackClusterSize){
        return self.player1;
    } else if (whiteClusterSize < blackClusterSize){
        return self.player2;
    }

//    NSLog(@"Tile counts (w/b): %i/%i", whiteTileCount, blackTileCount);
//    NSLog(@"Max cluster sizes (w/b): %i/%i", whiteClusterSize, blackClusterSize);

    return self.player1;
}

// /////////////////////////////////////////////////////////////////////////////////////
// game generation

- (void)generateGame {
    _challengeMoves = 0;

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

    // give the players some patterns
    NSMutableArray *player1Patterns = [[NSMutableArray alloc] initWithCapacity:8];
    NSMutableArray *player2Patterns = [[NSMutableArray alloc] initWithCapacity:8];

    for (int i = 0; i < 9; i++){
        NSUInteger maxDistance = 3 + arc4random()%2;
        NSUInteger tileCount = MAX(3,
                    arc4random()%4 + arc4random()%4);
        tileCount = MIN(tileCount, maxDistance*maxDistance);

        FFPattern *p1Pattern = [[FFPattern alloc]
                initWithRandomCoords:tileCount
                      andMaxDistance:maxDistance
                    andAllowRotating:YES];
        [player1Patterns addObject:p1Pattern];

        [player2Patterns addObject:[[FFPattern alloc] initAsMirroredCloneFrom:p1Pattern]];
    }

    // corrections
    //* give white an extra move
    FFPattern *p1Pattern = [[FFPattern alloc] initWithRandomCoords:1 andMaxDistance:4 andAllowRotating:YES];
    [player1Patterns addObject:p1Pattern];
    //*/

    //* balance extra move by weakening another pattern
    FFPattern *pattern;
    for (FFPattern *p in player1Patterns) {
        if (p.Coords.count > 2) {
            pattern = p;
            break;
        }
    }
    NSMutableArray *nuPatternCoords = [[NSMutableArray alloc] initWithCapacity:pattern.Coords.count-1];
    for (int i = 1; i < pattern.Coords.count; i++){
        [nuPatternCoords addObject:[pattern.Coords objectAtIndex:(NSUInteger)i]];
    }

    [player1Patterns removeObject:pattern];
    [player1Patterns addObject:[[FFPattern alloc] initWithCoords:nuPatternCoords andAllowRotation:YES]];
    //*/

    [self.player1 resetWithPatterns:player1Patterns];
    [self.player2 resetWithPatterns:player2Patterns];
}

- (FFBoard *)Board {
    return [self currentHistoryStep].board;
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

- (NSDictionary *)doneMovesForPlayer:(FFPlayer *)player {
    if ([self.player2.id isEqualToString:player.id]){
        return [self currentHistoryStep].doneMovesPlayer2;
    }
    return [self currentHistoryStep].doneMovesPlayer1;
}

@end

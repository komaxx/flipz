//
//  FFGame.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFGame.h"
#import "FFPattern.h"
#import "FFChallengeLoader.h"

NSString *const kFFNotificationGameChanged = @"ffGameChanged";
NSString *const kFFNotificationGameChanged_gameId = @"gameId";

NSString *const kFFGameTypeSingleChallenge = @"gtLocalChallenge";
NSString *const kFFGameTypeHotSeat = @"gtHotSeat";
NSString *const kFFGameTypeRemote = @"gtRemote";

@interface FFGame ()

@property(nonatomic, readwrite) NSString *const Type;
@property(nonatomic, strong, readwrite) FFBoard *Board;
@property(nonatomic, copy, readwrite) NSString *Id;
@property(nonatomic, readwrite) GameState gameState;

@property(nonatomic, strong, readwrite) FFPlayer *player1;
@property(nonatomic, strong, readwrite) FFPlayer *player2;
@property(nonatomic, strong, readwrite) FFPlayer *activePlayer;

@property(nonatomic, strong, readwrite) NSArray *moveHistory;
@property(nonatomic, strong, readwrite) NSArray *boardHistory;

@end

@implementation FFGame {
    NSInteger _challengeDifficulty;         // only for challenges...
    NSInteger _challengeMoves;
}
@synthesize Board = _Board;
@synthesize Id = _Id;
@synthesize Type = _Type;


- (id)initWithId:(NSString *)id Type:(NSString * const)type andBoardSize:(NSInteger)size {
    self = [super init];
    if (self){
        self.Id = id;
        self.Type = type;
        self.gameState = kFFGameState_NotYetStarted;
        self.Board = [[FFBoard alloc] initWithSize:(NSUInteger) size];
        self.Board.BoardType = kFFBoardType_multiStated_clamped;

        self.moveHistory = [[NSMutableArray alloc] initWithCapacity:10];
        self.boardHistory = [[NSMutableArray alloc] initWithCapacity:10];

        self.player1 = [[FFPlayer alloc] init];
        self.player1.local = YES;
        self.player1.id = @"_LocalChallengePlayer_";
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
        self.Board = [[FFBoard alloc] initWithSize:6];
        self.Board.BoardType = kFFBoardType_twoStated;

        self.moveHistory = [[NSMutableArray alloc] initWithCapacity:10];
        self.boardHistory = [[NSMutableArray alloc] initWithCapacity:10];

        self.player1 = [[FFPlayer alloc] init];
        self.player1.local = YES;
        self.player1.id = [NSString stringWithFormat:@"_LocalHotSeat%iPlayer1", id];

        self.player2 = [[FFPlayer alloc] init];
        self.player2.local = YES;
        self.player2.id = [NSString stringWithFormat:@"_LocalHotSeat%iPlayer2", id];
    }
    return self;
}

- (id)initChallengeWithDifficulty:(int)difficulty {
    self = [super init];
    if (self){
        _challengeDifficulty = difficulty;

        self.Id = [NSString stringWithFormat:@"local_challenge_%i", difficulty];
        self.Type = kFFGameTypeSingleChallenge;
        self.gameState = kFFGameState_NotYetStarted;
        self.Board = [[FFBoard alloc] initWithSize:2];

        self.moveHistory = [[NSMutableArray alloc] initWithCapacity:10];
        self.boardHistory = [[NSMutableArray alloc] initWithCapacity:10];

        self.player1 = [[FFPlayer alloc] init];
        self.player1.local = YES;
        self.player1.id = @"_LocalChallengePlayer_";
    }
    return self;
}

- (NSInteger)executeMove:(FFMove *)move byPlayer:(FFPlayer *)player {
    // check, whether the move was legal
    if (self.gameState == kFFGameState_Finished){
        NSLog(@"Illegal move: game already finished. Declined.");
        return -1;
    } else if (![move isLegalOnBoardWithSize:self.Board.BoardSize]){
        NSLog(@"Illegal move: outside of boardView. Declined.");
        return -2;
    }

    if (player != self.activePlayer){
        NSLog(@"Illegal move: not by active player!!");
        return -3;
    }

    _challengeMoves++;
    [(NSMutableArray *)self.moveHistory addObject:move];
    FFBoard *historyBoard = [[FFBoard alloc] initWithSize:self.Board.BoardSize];
    [historyBoard duplicateStateFrom:self.Board];
    [(NSMutableArray *)self.boardHistory addObject:historyBoard];

    [player setDoneMove:move];
    NSArray *flippedCoords = [self.Board doMoveWithCoords:[move buildToFlipCoords]];
    move.FlippedCoords = flippedCoords;

    [self winningPlayer];       // TODO remove

    [self checkIfGameFinished];
    [self endPlayersTurn];

    [self notifyChange];

    return 0;
}

- (void)undo {
    if (![self.Type isEqualToString:kFFGameTypeSingleChallenge]) return;

    if ([self.moveHistory count] < 1) return;

    if (![self.Type isEqualToString:kFFGameTypeSingleChallenge]) return;

    _challengeMoves++;

    FFMove *move = self.moveHistory.lastObject;
    FFBoard *board = self.boardHistory.lastObject;

    [self.activePlayer undoMove:move];
    self.Board = board;

    [(NSMutableArray *)self.moveHistory removeObject:move];
    [(NSMutableArray *)self.boardHistory removeObject:board];

    [self notifyChange];
}

- (void)redo {
    if (![self.Type isEqualToString:kFFGameTypeSingleChallenge]) return;

//    if ([self.moveHistory count] < 1) return;
//
//    [self undoMove:self.moveHistory.lastObject];
    // TODO
}

- (void)checkIfGameFinished {
    if (self.Type == kFFGameTypeSingleChallenge){
        if (![self.Board isSingleChromatic]) return;

        [self printGameAsJson];

        self.gameState = kFFGameState_Finished;
    } else if (self.Type == kFFGameTypeHotSeat){
        if ([self.player1 allPatternsPlayed] && [self.player2 allPatternsPlayed]){
            self.activePlayer = nil;
            self.gameState = kFFGameState_Finished;
        }
    }
}

- (void)printGameAsJson {
    NSLog(@"Took me %i moves", _challengeMoves);
    NSLog(@"{}");
}

- (void)endPlayersTurn {
    if (self.Type == kFFGameTypeSingleChallenge){
        // nothing
    } else if (self.Type == kFFGameTypeHotSeat){
        if (self.player1 == self.activePlayer){
            self.activePlayer = self.player2;
        } else {
            self.activePlayer = self.player1;
        }
    }
}

- (void)notifyChange {
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

    if (self.boardHistory.count < 1){
        NSLog(@"Not clearing, nothing in the history.");
        return;
    }

    _challengeMoves++;

    self.Board = [self.boardHistory objectAtIndex:0];
    [(NSMutableDictionary *) self.player1.doneMoves removeAllObjects];

    [(NSMutableArray *) self.moveHistory removeAllObjects];
    [(NSMutableArray *) self.boardHistory removeAllObjects];

    [self notifyChange];
}

- (void)start {
    if (self.gameState == kFFGameState_NotYetStarted){
        [self generateGame];

        self.activePlayer = self.player1;
        self.gameState = kFFGameState_Running;
    } else if (self.gameState == kFFGameState_Running){
        NSLog(@"Can not start running game. ignored.");
    } else {
        NSLog(@"REstarting finished game! %@", self.Id);

        [self generateGame];
        self.activePlayer = self.player1;
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
    [(NSMutableArray *) self.moveHistory removeAllObjects];
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
    self.ruleAllowPatternRotation = YES;
    self.ruleAllowPatternMirroring = NO;

    // make the boardView: random coloring
    self.Board = [[FFBoard alloc] initWithSize:6];
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
                      andMaxDistance:maxDistance];
        [player1Patterns addObject:p1Pattern];

        [player2Patterns addObject:[[FFPattern alloc] initAsMirroredCloneFrom:p1Pattern]];
    }

    // corrections
    //* give white an extra move
    FFPattern *p1Pattern = [[FFPattern alloc] initWithRandomCoords:1 andMaxDistance:4];
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
    for (int i = 1; i < pattern.Coords.count; i++) [nuPatternCoords addObject:[pattern.Coords objectAtIndex:i]];

    [player1Patterns removeObject:pattern];
    [player1Patterns addObject:[[FFPattern alloc] initWithCoords:nuPatternCoords]];
    //*/

    [self.player1 resetWithPatterns:player1Patterns];
    [self.player2 resetWithPatterns:player2Patterns];
}

// hot seat
// /////////////////////////////////////////////////////////////////////////////////////
// DEBUG

- (void)DEBUG_replaceBoardWith:(FFBoard *)board {
    NSLog(@"Replacing Board in game! This is DEBUG, right?");

    self.Board = board;
    [self notifyChange];
}

@end

//
//  FFGame.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFGame.h"
#import "FFPattern.h"

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

@end

@implementation FFGame {
    NSUInteger _nextMoveOrdinal;

    NSInteger _challengeDifficulty;         // only for challenges...
    NSInteger _challengeMoves;
}
@synthesize Board = _Board;
@synthesize Id = _Id;
@synthesize Type = _Type;


- (id)initWithId:(NSString *)id Type:(NSString * const)type andBoardSize:(NSUInteger)size {
    self = [super init];
    if (self){
        self.Id = id;
        self.Type = type;
        self.gameState = kFFGameState_NotYetStarted;
        self.Board = [[FFBoard alloc] initWithSize:size];
        self.Board.BoardType = kFFBoardType_multiStated;

        self.moveHistory = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (id)initHotSeat {
    self = [super init];
    if (self){
        static int id = 0;

        self.Id = [NSString stringWithFormat:@"hotSeat%i", id++];
        self.Type = kFFGameTypeHotSeat;
        self.gameState = kFFGameState_NotYetStarted;
        self.Board = [[FFBoard alloc] initWithSize:6];
        self.Board.BoardType = kFFBoardType_twoStated;

        self.moveHistory = [[NSMutableArray alloc] initWithCapacity:10];

        self.player1 = [[FFPlayer alloc] init];
        self.player1.local = YES;
        self.player1.id = @"_LocalHotSeatPlayer_1_";

        self.player2 = [[FFPlayer alloc] init];
        self.player2.local = YES;
        self.player2.id = @"_LocalHotSeatPlayer_2_";
    }
    return self;
}

- (id)initChallengeWithDifficulty:(int)difficulty {
    self = [super init];
    if (self){
        _challengeDifficulty = difficulty;

        self.Id = [NSString stringWithFormat:@"local_challenge %i", difficulty];
        self.Type = kFFGameTypeSingleChallenge;
        self.gameState = kFFGameState_NotYetStarted;
        self.Board = [self makeBoardForDifficulty:difficulty];

        self.moveHistory = [[NSMutableArray alloc] initWithCapacity:10];

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
        NSLog(@"Illegal move: outside of board. Declined.");
        return -2;
    }

    if (player != self.activePlayer){
        NSLog(@"Illegal move: not by active player!!");
        return -3;
    }

    _challengeMoves++;
    move.ordinal = _nextMoveOrdinal++;

    [player setDoneMove:move];
    [self.Board flipCoords:[move buildCoordsToFlip] countingUp:NO];

    [self checkForVictory];
    [self endPlayersTurn];

    [(NSMutableArray *)self.moveHistory addObject:move];
    [self notifyChange];

    return 0;
}

- (void)undoLastMove {
    if (![self.Type isEqualToString:kFFGameTypeSingleChallenge]) return;

    if ([self.moveHistory count] < 1) return;
    [self undoMove:self.moveHistory.lastObject];
}

- (void)undoMove:(FFMove *)move {
    if (![self.Type isEqualToString:kFFGameTypeSingleChallenge]) return;

    [self.activePlayer undoMove:move];
    [self.Board flipCoords:[move buildCoordsToFlip] countingUp:YES];
    [(NSMutableArray *)self.moveHistory removeObject:move];
    _challengeMoves++;

    [self notifyChange];
}

- (void)checkForVictory {
    if (self.Type == kFFGameTypeSingleChallenge){
        if (![self.Board isSingleChromatic]) return;

        self.gameState = kFFGameState_Finished;
    } else if (self.Type == kFFGameTypeHotSeat){
        if ([self.player1 allPatternsPlayed] && [self.player2 allPatternsPlayed]){
            self.gameState = kFFGameState_Finished;
        }
    }
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
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:self.Id, kFFNotificationGameChanged_gameId, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFFNotificationGameChanged object:nil userInfo:userInfo];
}

- (void)clean {
    if (self.Type != kFFGameTypeSingleChallenge){
        NSLog(@"Tried to clean a non-challenge game. Not doing it. Na-a!");
        return;
    }

    NSDictionary *moves = [NSDictionary dictionaryWithDictionary:self.player1.doneMoves];
    for (NSString *key in moves) {
        FFMove *move = [moves objectForKey:key];
        [self.player1 undoMove:move];
        [self.Board flipCoords:[move buildCoordsToFlip] countingUp:YES];
    }
    [(NSMutableArray *) self.moveHistory removeAllObjects];
    _challengeMoves++;

    [self notifyChange];
}

- (void)start {
    if (self.gameState == kFFGameState_NotYetStarted){
        [self generateGame];

        self.activePlayer = self.player1;
        self.gameState = kFFGameState_Running;
    } else if (self.gameState == kFFGameState_Running){

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

// /////////////////////////////////////////////////////////////////////////////////////
// game generation

- (void)generateGame {
    [(NSMutableArray *) self.moveHistory removeAllObjects];
    _challengeMoves = 0;

    if (self.Type == kFFGameTypeSingleChallenge){
        [self generateChallenge];
    } else if (self.Type == kFFGameTypeHotSeat){
        [self generateHotSeatGame];
    }
}

- (FFBoard *)makeBoardForDifficulty:(int)difficulty {
    NSUInteger boardSize = 4;
    if (difficulty > 6) boardSize = 5;
    if (difficulty > 12) boardSize = 6;

    return [[FFBoard alloc] initWithSize:boardSize];
}

// game generation
// /////////////////////////////////////////////////////////////////////////////////////
// challenges

- (void)generateChallenge {
    NSUInteger patternsCount = (NSUInteger) _challengeDifficulty;

    NSMutableArray *playablePatterns = [[NSMutableArray alloc] initWithCapacity:patternsCount];
    for (int i = 0; i < patternsCount; i++){
        FFPattern *pattern = [[FFPattern alloc] initWithRandomCoords:(1+arc4random()%6) andMaxDistance:3];
        [playablePatterns addObject:pattern];
    }
    [self.player1 resetWithPatterns:playablePatterns];

    self.Board.BoardType = kFFBoardType_multiStated;
    [self.Board cleanMonochromaticTo:0];
    for (FFPattern *pattern in playablePatterns) {
        FFMove *move = [self makeRandomMoveWithPattern:pattern];
        [self.Board flipCoords:[move buildCoordsToFlip] countingUp:YES];
    }
}

- (FFMove *)makeRandomMoveWithPattern:(FFPattern *)pattern {
    NSUInteger maxX = self.Board.BoardSize - pattern.SizeX;
    NSUInteger maxY = self.Board.BoardSize - pattern.SizeY;

    FFCoord *movePos = [[FFCoord alloc] initWithX:(ushort)(rand()%(maxX+1)) andY:(ushort)(rand()%(maxY+1))];

    FFMove *move = [[FFMove alloc] initWithPattern:pattern atPosition:movePos andOrientation:kFFOrientation_0_degrees];
    return move;
}

// challenges
// /////////////////////////////////////////////////////////////////////////////////////
// hot seat

- (void)generateHotSeatGame {
    // make the board: random coloring
    self.Board = [[FFBoard alloc] initWithSize:5];

    int blackTiles = 0;
    while (blackTiles < (self.Board.BoardSize*self.Board.BoardSize)/2){
        NSUInteger x = arc4random() % self.Board.BoardSize;
        NSUInteger y = arc4random() % self.Board.BoardSize;

        FFTile *tile = [self.Board tileAtX:x andY:y];
        if (tile.color == 1) continue;

        [tile flipCountingUp:YES];
        blackTiles++;
    }

    // give the players some patterns
    NSMutableArray *player1Patterns = [[NSMutableArray alloc] initWithCapacity:8];
    NSMutableArray *player2Patterns = [[NSMutableArray alloc] initWithCapacity:8];
    for (int i = 0; i < 8; i++){
        NSUInteger maxDistance = 3 + arc4random()%2;
        NSUInteger tileCount = 1 + arc4random()%6;
        tileCount = MIN(tileCount, maxDistance*maxDistance);

        [player1Patterns addObject:[[FFPattern alloc] initWithRandomCoords:tileCount andMaxDistance:maxDistance]];
        [player2Patterns addObject:[[FFPattern alloc] initWithRandomCoords:tileCount andMaxDistance:maxDistance]];
    }
    [self.player1 resetWithPatterns:player1Patterns];
    [self.player2 resetWithPatterns:player2Patterns];
}

// hot seat
// /////////////////////////////////////////////////////////////////////////////////////

@end

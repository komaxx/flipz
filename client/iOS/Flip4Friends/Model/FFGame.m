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
@property(nonatomic, strong, readwrite) FFPlayer *activePlayer;


@end

@implementation FFGame {
    NSInteger _difficultyLevel;         // only for challenges...
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
    }
    return self;
}

- (id)initChallengeWithDifficulty:(int)difficulty {
    self = [super init];
    if (self){
        _difficultyLevel = difficulty;

        self.Id = [NSString stringWithFormat:@"local_challenge %i", difficulty];
        self.Type = kFFGameTypeSingleChallenge;
        self.gameState = kFFGameState_NotYetStarted;
        self.Board = [self makeBoardForDifficulty:difficulty];

        self.player1 = [[FFPlayer alloc] init];
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

    // TODO check move by correct player

    [player setDoneMove:move];
    [self.Board flipCoords:[move buildCoordsToFlip]];

    [self checkForVictory];
    [self endPlayersTurn];

    [self notifyChange];

    return 0;
}

- (void)undoMove:(FFMove *)move {
    [self.activePlayer undoMove:move];
    [self.Board flipCoords:[move buildCoordsToFlip]];

    [self notifyChange];
}

- (void)checkForVictory {
    if (self.Type == kFFGameTypeSingleChallenge){
        if (![self.Board isSingleChromatic]) return;
        [self stopTimer];

        self.gameState = kFFGameState_Finished;
    } else {
        // TODO: Other cases
    }
}

- (void)startTimer {
    // TODO
}

- (void)stopTimer {
    // TODO
}

- (void)endPlayersTurn {
    if (self.Type == kFFGameTypeSingleChallenge){
        // nothing
    } else {
        // TODO go to next player
    }
}

- (void)notifyChange {
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:self.Id, kFFNotificationGameChanged_gameId, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFFNotificationGameChanged object:nil userInfo:userInfo];
}

- (void)start {
    if (self.gameState == kFFGameState_NotYetStarted){
        [self generateGame];

        self.activePlayer = self.player1;
    } else if (self.gameState == kFFGameState_Running){

    } else {
        NSLog(@"REstarting finished game! %@", self.Id);

        [self generateGame];
        self.activePlayer = self.player1;
        self.gameState = kFFGameState_Running;
    }

    [self notifyChange];
}

// /////////////////////////////////////////////////////////////////////////////////////
// game generation

- (void)generateGame {
    if (self.Type == kFFGameTypeSingleChallenge){
        [self generateChallenge];
    }
}

- (FFBoard *)makeBoardForDifficulty:(int)difficulty {
    NSUInteger boardSize = 6;

    return [[FFBoard alloc] initWithSize:boardSize];
}

// game generation
// /////////////////////////////////////////////////////////////////////////////////////
// challenges

- (void)generateChallenge {
    NSUInteger patternsCount = (NSUInteger) _difficultyLevel;

    NSMutableArray *playablePatterns = [[NSMutableArray alloc] initWithCapacity:patternsCount];
    for (int i = 0; i < patternsCount; i++){
        FFPattern *pattern = [[FFPattern alloc] initWithRandomCoords:(1+arc4random()%6) andMaxDistance:3];
        [playablePatterns addObject:pattern];
    }
    [self.player1 resetWithPatterns:playablePatterns];

    [self.Board cleanMonochromaticToWhite];
    for (FFPattern *pattern in playablePatterns) {
        FFMove *move = [self makeRandomMoveWithPattern:pattern];
        [self.Board flipCoords:[move buildCoordsToFlip]];
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

@end

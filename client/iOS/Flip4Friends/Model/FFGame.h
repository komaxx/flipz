//
//  FFGame.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFBoard.h"
#import "FFMove.h"
#import "FFPlayer.h"

@class FFHistoryStep;


/**
* Name of the notification whenever a game changes somehow. Will contain the id of the FFGame
* that was changed in the userData under key 'kFFNotificationGameChanged_gameId'
*/
extern NSString *const kFFNotificationGameChanged;
/**
* Key for the game_id that is delivered in the 'game changed' notification
*/
extern NSString *const kFFNotificationGameChanged_gameId;


/**
* A local game where the player tries to use the patterns to flip all tiles to the same color.
*/
extern NSString *const kFFGameTypeSingleChallenge;
/**
* Game type for a local game: Two players in front of the same device, handing each other the
* device after their move.
*/
extern NSString *const kFFGameTypeHotSeat;
/**
* Game type for a remote game: The moves are sent over servers from one player's device to the
* opponent's.
*/
extern NSString *const kFFGameTypeRemote;

typedef enum {
    kFFGameState_NotYetStarted, kFFGameState_Running, kFFGameState_Won, kFFGameState_Aborted
} GameState;



@interface FFGame : NSObject

@property (nonatomic, copy, readonly) NSString *Id;

/**
* Started, playing, won, aborted, ...
*/
@property (nonatomic, readonly) GameState gameState;

/**
* kFFGameTypeSingleChallenge, kFFGameTypeHotSeat, ..
*/
@property (nonatomic, readonly) NSString *const Type;

/**
* Holds all the patterns that were played and can still be played.
*/
@property (nonatomic, strong, readonly) FFPlayer *player1;

/**
* Maybe nil when playing a challenge!
*/
@property (nonatomic, strong, readonly) FFPlayer *player2;

/**
* All previous states of the game. The last state of the game is simply
* the last element of this stack.
*/
@property (nonatomic, strong, readonly) NSArray *history;

/**
* When the current state of the game is called, it's always in respect
* to this value. If it's 0 calls to Board&co deliver the latest state.
*/
@property(nonatomic, readonly) NSUInteger currentHistoryBackSteps;

/**
* Only used and set for challenges (~randomly created levels).
* A game is to be considered lost when this is <= 0 and the game can no longer be completed.
*/
@property (nonatomic, strong) NSNumber *maxUndos;

/**
* Only set for challenges (not puzzles, hot seat games, ...)
*/
@property (strong, nonatomic) NSNumber *challengeIndex;

/**
* Key of a localized string. Mostly nil, only set for puzzles (!) that
* introduce something new.
*/
@property (copy, nonatomic) NSString *tutorialId;


- (id)initWithId:(NSString *)id Type:(NSString * const)type andBoardSize:(NSInteger)size;

/**
* The given move is executed, with all consequences (boardView adjustment, player's turn change,
* if applicable sending the move to a remote server, ...).
* When this returns !=0, the move was declined as illegal (game already finished, not the
* given player's turn, move outside of boardView, ...)
*/
- (NSInteger)executeMove:(FFMove *)move byPlayer:(FFPlayer*)player;

- (FFBoard*)Board;

- (FFPlayer*)ActivePlayer;

- (id)initTestChallengeWithId:(NSString *)id1 andBoard:(FFBoard *)board;

- (id)initHotSeat;

- (void)start;

- (id)initGeneratedChallengeWithId:(NSString *)id andBoard:(FFBoard *)board andPatterns:(NSMutableArray *)patterns andMaxUndos:(NSUInteger)undos;

- (void)giveUp;

- (FFHistoryStep *)currentHistoryStep;

- (void)clean;

/**
* position is measured from the top of the move stack! So undo one move is -1. If a move
* is executed when the step was set to anything but 0, the position will then be set to 0
* and all moves on top of that stack element will be discarded.
*/
- (void)goBackInHistory:(NSInteger)position;

/**
* nil/wrong unless in state kFFGameFinished
*/
- (FFPlayer*)winningPlayer;

- (void)DEBUG_replaceBoardWith:(FFBoard *)board;

- (NSDictionary *)doneMovesForPlayer:(FFPlayer *)player;

- (BOOL)moveWouldWinChallenge:(FFMove *)move byPlayer:(FFPlayer *)player;

- (NSInteger)undosLeft;

- (BOOL)isRandomChallenge;

- (BOOL)stillSolvable;

- (NSUInteger)scoreForColor:(int)color;

- (int)challengeMovesPlayed;
@end

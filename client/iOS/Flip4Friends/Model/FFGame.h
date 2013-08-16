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
    kFFGameState_NotYetStarted, kFFGameState_Running, kFFGameState_Finished
} GameState;




@interface FFGame : NSObject

@property (nonatomic, copy, readonly) NSString *Id;
@property (nonatomic, readonly) GameState gameState;
@property (nonatomic, readonly) NSString *const Type;

@property (nonatomic, strong, readonly) FFPlayer *player1;
/**
* Maybe nil when playing a challenge!
*/
@property (nonatomic, strong, readonly) FFPlayer *player2;

/**
* Either nil (e.g., at demo games) player1 or player2.
*/
@property (nonatomic, readonly) FFPlayer *activePlayer;

/**
* Guess.
*/
@property (nonatomic, strong, readonly) FFBoard *Board;

@property (nonatomic, strong, readonly) NSArray *moveHistory;

- (id)initWithId:(NSString *)id Type:(NSString * const)type andBoardSize:(NSUInteger)size;

- (id)initChallengeWithDifficulty:(int)i;

/**
* The given move is executed, with all consequences (board adjustment, player's turn change,
* if applicable sending the move to a remote server, ...).
* When this returns !=0, the move was declined as illegal (game already finished, not the
* given player's turn, move outside of board, ...)
*/
- (NSInteger)executeMove:(FFMove *)move byPlayer:(FFPlayer*)player;

- (id)initHotSeat;

- (void)start;

- (void)undoLastMove;

- (void)undoMove:(FFMove *)move;

- (void)giveUp;

- (void)clean;

/**
* nil/wrong unless in state kFFGameFinished
*/
- (FFPlayer*)winningPlayer;
@end

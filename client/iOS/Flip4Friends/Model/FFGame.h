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
* This game type is not really a game. It contains no real game but is just used as a visual
* backdrop and for development/testing/debugging purposes.
*/
extern NSString *const kFFGameTypeDemo;
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

@property (nonatomic, readonly) FFPlayer *player1;
@property (nonatomic, readonly) FFPlayer *player2;

/**
* Either nil (e.g., at demo games) player1 or player2.
*/
@property (nonatomic, readonly) FFPlayer *activePlayer;

@property (nonatomic, strong, readonly) FFBoard *Board;


- (id)initWithId:(NSString *)id Type:(NSString * const)type andBoardSize:(NSUInteger)size;

/**
* The given move is executed, with all consequences (board adjustment, player's turn change,
* if applicable sending the move to a remote server, ...).
* When this returns !=0, the move was declined as illegal (game already finished, not the
* given player's turn, move outside of board, ...)
*/
- (NSInteger)executeMove:(FFMove *)move byPlayer:(FFPlayer*)player;

@end

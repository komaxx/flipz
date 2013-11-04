//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 10/2/13.
//


#import <Foundation/Foundation.h>

@class FFBoard;
@class FFMove;

typedef enum {
    kFFHistoryStepMove = 0,
    kFFHistoryStepBack = 1,     // note: can be more than one step back!
    kFFHistoryStepClear = 2,     // undo all moves.
} FFHistoryStepType;


/**
* An entry in the history of a game. Contains a type, a board and possibly
* the executed move (when played a pattern).
*/
@interface FFHistoryStep : NSObject

@property (strong, nonatomic, readonly) NSString *id;

@property (strong, nonatomic, readonly) FFBoard *board;
@property (strong, nonatomic, readonly) NSArray *flippedTiles;

@property (strong, nonatomic) NSString *activePlayerId;

@property (strong, nonatomic, readonly) NSDictionary *doneMovesPlayer1;
@property (strong, nonatomic, readonly) NSDictionary *doneMovesPlayer2;

@property (strong, nonatomic, readonly) NSArray *affectedPatternIDs;
@property (nonatomic, readonly) FFHistoryStepType type;

@property (nonatomic, readonly) NSUInteger timesReturnedToStep;


- (id)initCleanStepWithBoard:(FFBoard *)board;

- (id)initWithMove:(FFMove *)move byPlayer1:(BOOL)byPlayer1 andPreviousStep:(FFHistoryStep *)step;

- (void)returnedToStep;

- (id)initWithStep:(FFHistoryStep *)step;

- (void)DEBUG_replaceBoardWith:(FFBoard *)board;

@end
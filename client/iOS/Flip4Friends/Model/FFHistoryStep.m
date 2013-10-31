//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 10/2/13.
//


#import "FFHistoryStep.h"
#import "FFBoard.h"
#import "FFMove.h"
#import "FFPattern.h"
#import "FFPlayer.h"


@interface FFHistoryStep ()
@property (nonatomic, readwrite) FFHistoryStepType type;
@property (strong, nonatomic, readwrite) FFBoard *board;

@property (strong, nonatomic, readwrite) NSArray *flippedTiles;
@property (strong, nonatomic, readwrite) NSArray *affectedPatternIDs;

@property (strong, nonatomic, readwrite) NSDictionary *doneMovesPlayer1;
@property (strong, nonatomic, readwrite) NSDictionary *doneMovesPlayer2;

@property (nonatomic, readwrite) NSUInteger timesReturnedToStep;
@end

@implementation FFHistoryStep {

}
- (id)initCleanStepWithBoard:(FFBoard *)board {
    self = [super init];
    
    if (self){
        [self basicInit];
        self.type = kFFHistoryStepClear;
        self.board = [[FFBoard alloc] initWithBoard:board];
        self.flippedTiles = @[];
    }
    
    return self;
}

static int nextId;

- (id)initWithMove:(FFMove *)move byPlayer1:(BOOL)player1 andPreviousStep:(FFHistoryStep *)step {
    self = [super init];
    if (self){
        [self basicInit];
        self.type = kFFHistoryStepMove;
        self.board = [[FFBoard alloc] initWithBoard:step.board];
        self.doneMovesPlayer1 = [NSMutableDictionary dictionaryWithDictionary:step.doneMovesPlayer1];
        self.doneMovesPlayer2 = [NSMutableDictionary dictionaryWithDictionary:step.doneMovesPlayer2];
        self.activePlayerId = step.activePlayerId;
        self.affectedPatternIDs = [NSArray arrayWithArray:step.affectedPatternIDs];

        if (player1) [(NSMutableDictionary *) self.doneMovesPlayer1 setObject:move forKey:move.Pattern.Id];
        else [(NSMutableDictionary *) self.doneMovesPlayer2 setObject:move forKey:move.Pattern.Id];

        NSArray *flippedCoords = [self.board doMoveWithCoords:[move buildToFlipCoords]];
        move.FlippedCoords = flippedCoords;
        self.flippedTiles = flippedCoords;
    }

    return self;
}

- (void)returnedToStep {
    self.timesReturnedToStep++;
}


- (void)basicInit {
    _id = [NSString stringWithFormat:@"hStep_%i", nextId++];
}

- (void)DEBUG_replaceBoardWith:(FFBoard *)board {
    self.board = board;
}
@end
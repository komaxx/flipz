//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 10/2/13.
//


#import "FFHistoryStep.h"
#import "FFBoard.h"
#import "FFMove.h"
#import "FFPattern.h"


@interface FFHistoryStep ()
@property (nonatomic, readwrite) FFHistoryStepType type;
@property (strong, nonatomic, readwrite) FFBoard *board;
@property (strong, nonatomic, readwrite) NSArray *flippedTiles;
@property (strong, nonatomic, readwrite) NSArray *affectedPatternIDs;
@property (strong, nonatomic, readwrite) NSDictionary *doneMoveIds;
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

- (id)initWithMove:(FFMove *)move andBoard:(FFBoard *)board andDoneMoves:(NSDictionary *)doneMoveIds{
    self = [super init];

    if (self){
        [self basicInit];
        self.type = kFFHistoryStepMove;
        self.board = [[FFBoard alloc] initWithBoard:board];
        self.flippedTiles = [NSArray arrayWithArray:move.FlippedCoords];
        self.doneMoveIds = [NSDictionary dictionaryWithDictionary:doneMoveIds];
        self.affectedPatternIDs = @[ move.Pattern.Id ];
    }

    return self;
}

static int nextId;

- (id)initUndoStepFromStep:(FFHistoryStep *)step {
    self = [super init];

    if (self){
        [self basicInit];
        self.type = kFFHistoryStepBack;
        self.board = [[FFBoard alloc] initWithBoard:step.board];
        self.flippedTiles = [NSArray arrayWithArray:step.flippedTiles];
        self.doneMoveIds = [NSDictionary dictionaryWithDictionary:step.doneMoveIds];
        self.affectedPatternIDs = step.affectedPatternIDs;
    }

    return self;
}

- (void)basicInit {
    _id = [NSString stringWithFormat:@"backStep_%i", nextId++];
}
@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 9/23/13.
//


#import "FFCreateChallengeSession.h"
#import "FFBoard.h"
#import "FFGame.h"
#import "FFGamesCore.h"


@interface FFCreateChallengeSession ()

@property (strong, nonatomic) NSMutableArray *boardStack;
@property (strong, nonatomic) FFBoard *tmpMoveBoard;

@end

@implementation FFCreateChallengeSession {
}

- (id)initAndReset {
    self = [super init];
    if (self){
        [self reset];
    }
    return self;
}

- (void)reset {
    self.moves = [[NSMutableArray alloc] initWithCapacity:10];
    self.boardStack = [[NSMutableArray alloc] initWithCapacity:10];

    FFBoard *firstBoard = [[FFBoard alloc] initWithSize:8];
    firstBoard.BoardType = kFFBoardType_multiStated_clamped;

    [self.boardStack addObject:firstBoard];
}

- (void)updatePaintBoardWith:(FFBoard *)board {
    [self.boardStack replaceObjectAtIndex:0 withObject:board];
}

- (void)buildAndStoreTmpGame {
    FFGame* testGame = [[FFGame alloc] initTestChallengeWithId:@"tmpChallenge" andBoard:self.paintedBoard];

    NSMutableArray *patterns = [[NSMutableArray alloc] initWithCapacity:10];
    for (FFMove *move in self.moves) {
        [patterns addObject:move.Pattern];
    }

    testGame.player1.playablePatterns = patterns;

    [[FFGamesCore instance] registerGame:testGame];
}

- (void)resetMoveBoard {
    self.tmpMoveBoard = [[FFBoard alloc] initWithBoard:[self paintedBoard]];
}

- (FFBoard *)paintedBoard {
    return [self.boardStack lastObject];
}

- (FFBoard *)moveTmpBoard {
    return self.tmpMoveBoard;
}

// /////////////////////////////////////////////////////////////////////////
// Instance

static FFCreateChallengeSession *theInstance;
+ (FFCreateChallengeSession *)instance {
    if (!theInstance){
        theInstance = [[FFCreateChallengeSession alloc] initAndReset];
    }
    return theInstance;
}

+ (NSString *)tmpGameId {
    return @"tmpChallenge";
}

- (id)init {
    self = [super init];
    NSLog(@"SINGLETON! DO NOT ALLOC/INIT DIRECTLY!");
    return self;
}
@end
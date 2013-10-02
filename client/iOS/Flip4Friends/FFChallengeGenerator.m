//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 9/16/13.
//


#import "FFChallengeGenerator.h"
#import "FFBoard.h"
#import "FFGame.h"
#import "FFPattern.h"
#import "FFAutoSolver.h"


@implementation FFChallengeGenerator {

}
@synthesize numberOfChallenges = _numberOfChallenges;

static NSArray *levelDefinitions;
static NSUInteger creationId;

- (id)init {
    self = [super init];
    if (self) {
        [self loadLevelDefinitionsIfNecessary];
    }

    return self;
}

- (void)loadLevelDefinitionsIfNecessary {
    if (levelDefinitions) return;

    NSError * error;
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"challenges" ofType:@"txt"]];
    levelDefinitions = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    self.numberOfChallenges = levelDefinitions.count;
}


- (FFGame*) generateRandomForLevel:(NSUInteger)level {
    NSLog(@"Challenges: %i", levelDefinitions.count);

    NSDictionary *definition = [levelDefinitions objectAtIndex:level];

    // //////////////////////////////////////////////////////////////////////////////////////////
    // basic, non-random stuff
    FFGame *challenge = [[FFGame alloc] initWithId:[NSString stringWithFormat:@"challenge%i_%i", level, creationId++]
                                              Type:kFFGameTypeSingleChallenge
                                      andBoardSize:[(NSNumber*)[definition objectForKey:@"boardsize"] intValue]];
    challenge.Board.lockMoves = [(NSNumber *)[definition objectForKey:@"lockmoves"] intValue];
    challenge.Board.BoardType = (FFBoardType) [(NSNumber *)[definition objectForKey:@"boardtype"] intValue];


    // //////////////////////////////////////////////////////////////////////////////////////////
    // Make random patterns.
    NSArray *patternDefs = [definition objectForKey:@"patterns"];
    NSMutableArray *patterns = [[NSMutableArray alloc] initWithCapacity:patternDefs.count];

    for (NSDictionary *patternDef in patternDefs) {
        FFPattern *pattern = [[FFPattern alloc] initWithRandomCoords:(NSUInteger) [(NSNumber *)[patternDef objectForKey:@"tiles"] intValue]
                                                     andMaxDistance:(NSUInteger) [(NSNumber *)[patternDef objectForKey:@"distance"] intValue]
                                                   andAllowRotating:[(NSNumber *)[patternDef objectForKey:@"rotating"] boolValue]];
        [patterns addObject:pattern];
    }

    // //////////////////////////////////////////////////////////////////////////////////////////
    // Do some random moves from these random patterns

    BOOL difficultyIsOk = NO;
    while (!difficultyIsOk){
        for (FFPattern *pattern in patterns) {
            FFMove *move = [self makeRandomMoveWithPattern:pattern forGame:challenge];
            [challenge.Board buildGameByFlippingCoords:[move buildToFlipCoords]];
        }
        [challenge.player1 resetWithPatterns:patterns];
        [challenge.Board unlock];

//        FFAutoSolver *solver = [[FFAutoSolver alloc] initWithGame:challenge];
//        [solver solveSynchronously];

        // TODO: estimate difficulty

        difficultyIsOk = YES;
    }

    return challenge;
}

- (FFMove *)makeRandomMoveWithPattern:(FFPattern *)pattern forGame:(FFGame *)game {
    NSUInteger maxX = game.Board.BoardSize - pattern.SizeX;
    NSUInteger maxY = game.Board.BoardSize - pattern.SizeY;

    FFCoord *movePos = [[FFCoord alloc] initWithX:(ushort)(arc4random()%(maxX+1)) andY:(ushort)(arc4random()%(maxY+1))];

//    TODO
//    FFOrientation orientation = (FFOrientation) (game.ruleAllowPatternRotation ? arc4random()%4 : 0);
    FFOrientation orientation = kFFOrientation_0_degrees;

    FFMove *move = [[FFMove alloc] initWithPattern:pattern atPosition:movePos andOrientation:orientation];

    return move;
}


- (FFGame *)generateWithBoardSize:(int)boardSize
                   andOverLapping:(BOOL)lapping
                      andRotation:(BOOL)rotation
                     andLockTurns:(int)lockTurns {
    static int generatedChallenge = 0;

    // //////////////////////////////////////////////////////////////////////////////////////////
    // basic, non-random stuff
    FFGame *challenge = [[FFGame alloc] initWithId:[NSString stringWithFormat:@"generated_challenge_%i", generatedChallenge++]
                                              Type:kFFGameTypeSingleChallenge andBoardSize:boardSize];

    challenge.Board.lockMoves = lockTurns;
    challenge.Board.BoardType = kFFBoardType_multiStated_rollover;


    // //////////////////////////////////////////////////////////////////////////////////////////
    // Make random patterns.
    NSMutableArray *patterns = [[NSMutableArray alloc] initWithCapacity:5];

    NSArray *patternDefs = @[
            @[[NSNumber numberWithInt:2], [NSNumber numberWithInt:2]],
            @[[NSNumber numberWithInt:2], [NSNumber numberWithInt:2]],
            @[[NSNumber numberWithInt:3], [NSNumber numberWithInt:2]],
            @[[NSNumber numberWithInt:3], [NSNumber numberWithInt:3]],
            @[[NSNumber numberWithInt:4], [NSNumber numberWithInt:3]],
            @[[NSNumber numberWithInt:4], [NSNumber numberWithInt:3]],
            @[[NSNumber numberWithInt:4], [NSNumber numberWithInt:4]],
    ];

    for (NSArray *def in patternDefs) {
        FFPattern *pattern = [[FFPattern alloc] initWithRandomCoords:(NSUInteger) [(NSNumber *)[def objectAtIndex:0] intValue]
                                                      andMaxDistance:(NSUInteger) [(NSNumber *)[def objectAtIndex:1] intValue]
                                                    andAllowRotating:YES];
        [patterns addObject:pattern];
    }

    // //////////////////////////////////////////////////////////////////////////////////////////
    // Do some random moves from these random patterns

    BOOL difficultyIsOk = NO;
    while (!difficultyIsOk){
        for (FFPattern *pattern in patterns) {
            FFMove *move = [self makeRandomMoveWithPattern:pattern forGame:challenge];
            [challenge.Board buildGameByFlippingCoords:[move buildToFlipCoords]];
        }
        [challenge.player1 resetWithPatterns:patterns];
        [challenge.Board unlock];

//        FFAutoSolver *solver = [[FFAutoSolver alloc] initWithGame:challenge];
//        [solver solveSynchronously];

        // TODO: estimate difficulty
        difficultyIsOk = YES;
    }

    return challenge;
}
@end
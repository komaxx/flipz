//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 9/16/13.
//


#import "FFChallengeGenerator.h"
#import "FFBoard.h"
#import "FFGame.h"
#import "FFPattern.h"
#import "FFAutoSolver.h"
#import "FFUtil.h"


@implementation FFChallengeGenerator {
}

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
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"random_challenges" ofType:@"txt"]];
    levelDefinitions = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
}


- (NSUInteger)levelCount {
    [self loadLevelDefinitionsIfNecessary];
    return levelDefinitions.count;
}

- (FFGame*)generateChallengeForLevel:(NSUInteger)level {
    NSDictionary *def = [levelDefinitions objectAtIndex:CLAMP(level,0,levelDefinitions.count-1)];

    NSUInteger boardSize = (NSUInteger) CLAMP( [[def objectForKey:@"boardsize"] intValue], 1, 20);
    NSUInteger lockMoves = (NSUInteger) CLAMP( [[def objectForKey:@"lockmoves"] intValue], 0, 99);
    FFBoardType boardType = (FFBoardType) [[def objectForKey:@"boardtype"] intValue];
    BOOL overlap = [[def objectForKey:@"overlap"] boolValue];

    FFBoard *board = [[FFBoard alloc] initWithSize:boardSize];
    board.lockMoves = lockMoves;
    board.BoardType = boardType;

    NSArray *patternDefs = [def objectForKey:@"patterns"];
    NSMutableArray *patterns = [[NSMutableArray alloc] initWithCapacity:patternDefs.count];
    BOOL solutionFound = YES;
    for (NSDictionary *patternDef in patternDefs) {
        NSUInteger maxSquareSize = (NSUInteger) MAX([[patternDef objectForKey:@"max_square_size"] intValue], 1);
        NSUInteger coords = CLAMP([[patternDef objectForKey:@"coords"] intValue], 1, maxSquareSize*maxSquareSize);
        BOOL rotating = [(NSNumber *)[patternDef objectForKey:@"rotating"] boolValue];

        BOOL fittingPositionFound = NO;
        for (int i = 0; i < 10 && !fittingPositionFound; i++){
            FFPattern *nowRandomPattern = [self makeRandomPatternWithMaxSize:maxSquareSize andCoords:coords andRotating:rotating];
            fittingPositionFound |= [self fitPattern:nowRandomPattern ontoBoard:board andAllowOverlap:overlap];
            if (fittingPositionFound) [patterns addObject:nowRandomPattern];
        }
        if (!fittingPositionFound){
            solutionFound = NO;
            break;
        }
    }

    if (!solutionFound){
        // DAMN! Try again.
        return [self generateChallengeForLevel:level];
    }

    [board unlock];
    NSString *id = [NSString stringWithFormat:@"generated_level%i_%i", level, creationId++];
    FFGame *generatedChallenge = [[FFGame alloc] initGeneratedChallengeWithId:id
                                                                     andBoard:board
                                                                  andPatterns:patterns];

    return generatedChallenge;
}

- (BOOL)fitPattern:(FFPattern *)pattern ontoBoard:(FFBoard *)board andAllowOverlap:(BOOL)overlap {
    // first: try some random positions

    FFMove *move;

    BOOL foundValidTarget = NO;
    for (int i = 0; i < 10 && !foundValidTarget; i++){
        FFBoard *tmpBoard = [[FFBoard alloc] initWithBoard:board];
        move = [self makeRandomMoveWithPattern:pattern onBoard:board];

        NSArray *toFlipCoords = [move buildToFlipCoords];
        [tmpBoard buildGameByFlippingCoords:toFlipCoords];

        if (!overlap){
            // check if all flipped coords were not flipped again
            BOOL overlapFound = NO;
            for (FFCoord *c in toFlipCoords){
                if ([tmpBoard tileAtX:c.x andY:c.y].color % 2 != 1){
                    overlapFound = YES;
                    break;
                }
            }
            if (!overlapFound) foundValidTarget = YES;
        } else {
            // overlapping is allowed, so this should always work
            foundValidTarget = YES;
        }
    }

    if (foundValidTarget){
        // execute the move!
        [board buildGameByFlippingCoords:[move buildToFlipCoords]];
    } else {
        // a more ordered approach: Find by cycling through the possible fields
        // TODO

    }

    return foundValidTarget;
}

- (FFMove *)makeRandomMoveWithPattern:(FFPattern *)pattern onBoard:(FFBoard *)board {
    FFOrientation orientation = (FFOrientation) (arc4random() % pattern.differingOrientations);
    int maxX = board.BoardSize - orientation%2==0 ? pattern.SizeX : pattern.SizeY;
    int maxY = board.BoardSize - orientation%2==0 ? pattern.SizeY : pattern.SizeX;
    return [[FFMove alloc] initWithPattern:pattern
                                        atPosition:[[FFCoord alloc] initWithX:(ushort) (arc4random() % (maxX+1))
                                                                         andY:(ushort) (arc4random() % (maxY+1))]
                                    andOrientation:orientation];
}

- (FFPattern *)makeRandomPatternWithMaxSize:(NSUInteger)size andCoords:(NSUInteger)coordCount andRotating:(BOOL)rotating {
    NSMutableArray *coords = [[NSMutableArray alloc] initWithCapacity:coordCount];

    int lastCoordPos = -1;
    for (int i = 0; i < coordCount; i++){
        int proceed = arc4random() % (size*size - lastCoordPos - (coordCount-i) - 1) + 1;
        lastCoordPos += proceed;
        [coords addObject:[[FFCoord alloc] initWithX:(ushort) (lastCoordPos % size) andY:(ushort) (lastCoordPos / size)]];
    }

    return [[FFPattern alloc] initWithCoords:coords andAllowRotation:rotating];
}

@end
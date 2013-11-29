//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 9/16/13.
//


#import "FFChallengeGenerator.h"
#import "FFBoard.h"
#import "FFGame.h"
#import "FFPattern.h"
#import "FFUtil.h"
#import "FFPuzzleLoader.h"


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
            FFPattern *nowRandomPattern =
                    [[FFPattern alloc] initWithRandomCoords:coords andMaxDistance:maxSquareSize andAllowRotating:rotating];
            fittingPositionFound |= [self fitPattern:nowRandomPattern ontoBoard:board andAllowOverlap:overlap];
            if (fittingPositionFound){
                if (rotating){
                    // pre-rotate randomly
                    nowRandomPattern = [nowRandomPattern
                            copyForOrientation:(FFOrientation) (arc4random() % [nowRandomPattern differingOrientations])];
                }
                [patterns addObject:nowRandomPattern];
            }
        }
        if (!fittingPositionFound){
            solutionFound = NO;
            break;
        }
    }

    if (!solutionFound){
        NSLog(@"Failed to generate a challenge. Retrying...");
        // DAMN! Try again.
        return [self generateChallengeForLevel:level];
    }

    // mix up the pattern to further obstruct the creating order
    [FFUtil shuffle:patterns];

    [board unlock];
    NSUInteger maxUndos = (NSUInteger) CLAMP( [[def objectForKey:@"maxundos"] intValue], 0, 99);
    NSString *id = [NSString stringWithFormat:@"generated_level%i_%i", level, creationId++];
    FFGame *generatedChallenge = [[FFGame alloc] initGeneratedChallengeWithId:id
                                                                     andBoard:board
                                                                  andPatterns:patterns
                                                                  andMaxUndos:maxUndos];
    generatedChallenge.challengeIndex = @(level);

    NSString *json = [FFPuzzleLoader encodeGameAsJson:generatedChallenge];
    NSLog(@"%@", json);

    return generatedChallenge;
}

- (BOOL)fitPattern:(FFPattern *)pattern ontoBoard:(FFBoard *)board andAllowOverlap:(BOOL)overlap {
    // first: try some random positions
    FFMove *move;

    BOOL foundValidTarget = NO;
    // first: try some random stuff to keep it interesting
    for (int i = 0; i < 15 && !foundValidTarget; i++){
        FFBoard *tmpBoard = [[FFBoard alloc] initWithBoard:board];
        move = [self makeRandomMoveWithPattern:pattern onBoard:tmpBoard];
        foundValidTarget = [self checkMove:move onBoard:tmpBoard withOverlapping:overlap];
    }

    if (!foundValidTarget){
        // now, a more ordered approach: Find by cycling through the possible fields
        for (int o = 0; o < [pattern differingOrientations] && !foundValidTarget; o++){
            int maxX = board.BoardSize - (o%2==0 ? pattern.SizeX : pattern.SizeY);
            int maxY = board.BoardSize - (o%2==0 ? pattern.SizeY : pattern.SizeX) ;

            for (int y = 0; y <= maxY && !foundValidTarget; y++){
                for (int x = 0; x <= maxX && !foundValidTarget; x++){
                    FFBoard *tmpBoard = [[FFBoard alloc] initWithBoard:board];
                    move = [[FFMove alloc] initWithPattern:pattern
                                                        atPosition:[[FFCoord alloc] initWithX:(ushort)x andY:(ushort)y]
                                                    andOrientation:(FFOrientation) o];
                    foundValidTarget = [self checkMove:move onBoard:tmpBoard withOverlapping:overlap];
                }
            }
        }
    }

    if (foundValidTarget){
        // execute the move!
        [board buildGameByFlippingCoords:[move buildToFlipCoords]];
    }

    return foundValidTarget;
}

- (BOOL)checkMove:(FFMove *)move onBoard:(FFBoard *)board withOverlapping:(BOOL)overlap {
    NSArray *toFlipCoords = [move buildToFlipCoords];
    if (![board buildGameByFlippingCoords:toFlipCoords]){
        NSLog(@"Shufuq.");
        return NO;
    }

    if (!overlap){
        // check if all flipped coords were not flipped again
        BOOL overlapFound = NO;
        for (FFCoord *c in toFlipCoords){
            if ([board tileAtX:c.x andY:c.y].color % 2 != 1){
                overlapFound = YES;
                break;
            }
        }
        return !overlapFound;
    } else {
        // overlapping is allowed, so this should always work
        return YES;
    }
}

- (FFMove *)makeRandomMoveWithPattern:(FFPattern *)pattern onBoard:(FFBoard *)board {
    FFOrientation orientation = (FFOrientation) (arc4random() % pattern.differingOrientations);
    int maxX = board.BoardSize - ((orientation%2)==0 ? pattern.SizeX : pattern.SizeY);
    int maxY = board.BoardSize - ((orientation%2)==0 ? pattern.SizeY : pattern.SizeX);

    ushort x = (ushort) (arc4random() % (maxX+1));
    ushort y = (ushort) (arc4random() % (maxY+1));

    FFMove *ret = [[FFMove alloc] initWithPattern:pattern
                                        atPosition:[[FFCoord alloc] initWithX:x andY:y]
                                    andOrientation:orientation];
    return ret;
}

@end
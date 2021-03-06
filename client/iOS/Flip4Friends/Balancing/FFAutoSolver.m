//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 9/11/13.
//

#define MAX_HINTS 4

#import "FFAutoSolver.h"
#import "FFGamesCore.h"
#import "FFPattern.h"
#import "FFToast.h"

// ///////////////////////////////////////
// simple little helper class

@interface FFMoveWithPossibilities : NSObject

@property (strong) FFMove* move;
@property NSUInteger alternatives;

- (id)initWithMove:(FFMove *)move andAlternatives:(NSUInteger)alternatives;

@end

@implementation FFMoveWithPossibilities
- (id)initWithMove:(FFMove *)m andAlternatives:(NSUInteger)alts {
    self = [super init];
    _move = m;
    _alternatives = alts;
    return self;
}
@end
// simple little helper class
// ///////////////////////////////////////


@interface FFAutoSolver ()
@property (strong, nonatomic) FFGame *setGame;
@property (nonatomic) NSMutableArray *foundSolutions;
@end


@implementation FFAutoSolver {
    NSUInteger _recursions;
}

- (id)initWithGameId:(NSString *)gameId {
    self = [super init];
    if (self) {
        _setGame = [[FFGamesCore instance] gameWithId:gameId];
        _foundSolutions = [[NSMutableArray alloc] initWithCapacity:20];
    }

    return self;
}

- (id)initWithGame:(FFGame *)game {
    self = [super init];
    if (self) {
        _setGame = game;
        _foundSolutions = [[NSMutableArray alloc] initWithCapacity:20];
    }

    return self;
}

- (void)solveAsynchronouslyAndAbortWhenFirstFound:(BOOL)abortWhenFirstFound {
    FFGame *game = self.setGame;

    NSMutableArray *restPatterns = [[NSMutableArray alloc] initWithCapacity:game.player1.playablePatterns.count];
    for (FFPattern *pattern in game.player1.playablePatterns) {
        if ([[game doneMovesForPlayer:game.player1] objectForKey:pattern.Id]) continue;
        [restPatterns addObject:pattern];
    }

    [self performSelectorInBackground:@selector(solve:)
                           withObject:@[restPatterns, game.Board, @(abortWhenFirstFound)]];
}

- (void)solveSynchronouslyAndAbortWhenFirstFound:(BOOL)abortWhenFirstFound {
    FFGame *game = self.setGame;

    NSMutableArray *restPatterns = [[NSMutableArray alloc] initWithCapacity:game.player1.playablePatterns.count];
    for (FFPattern *pattern in game.player1.playablePatterns) {
        if ([[game doneMovesForPlayer:game.player1] objectForKey:pattern.Id]) continue;
        [restPatterns addObject:pattern];
    }

    [self solve:@[restPatterns, game.Board, @(abortWhenFirstFound)]];
}


- (BOOL)solve:(NSArray*)data {
    BOOL ret;
    if (self.setGame.Board.lockMoves < 1){
        ret = [self solveWithoutOrderWithData:data];
        [self printHintsOrdered:true];
    } else {
        ret = [self solveWithOrderAndData:data];
        [self printHintsOrdered:false];
    }

    if (self.toastResult){
        [self performSelectorOnMainThread:@selector(showResultToast) withObject:nil waitUntilDone:NO];
    }

    return ret;
}

- (void)printHintsOrdered:(bool)ordered {
    NSString *ret = @"";

    if (self.foundSolutions.count > 0){
        NSArray *solution = [self.foundSolutions objectAtIndex:0];
        int hintCount = MIN(MAX_HINTS, solution.count);
        for (NSUInteger i = 0; i < hintCount; i++){
            NSString *coordsString = [self printCoordsForMove:[solution objectAtIndex:i]];
            ret = [NSString stringWithFormat:@"%@[%@]",ret,coordsString];
            if (i+1<hintCount) ret = [ret stringByAppendingString:@","];
        }
    }

    NSLog(@",\"hints\":[%@]", ret);
}

- (NSString*)printCoordsForMove:(FFMove*)move {
    NSString *ret = @"";
    NSArray *toFlipCoords = move.buildToFlipCoords;
    for (NSUInteger i = 0; i < toFlipCoords.count; i++){
        FFCoord *c = [toFlipCoords objectAtIndex:i];
        ret = [NSString stringWithFormat:@"%@[%i,%i]", ret, c.x, c.y];
        if (i+1<toFlipCoords.count) ret = [ret stringByAppendingString:@","];
    }
    return ret;
}

- (void)showResultToast {
    [[FFToast make:[NSString stringWithFormat:@"Solution found: %@", self.foundSolutions.count > 0 ? @"YES" : @"NO"]] show];
}

// ////////////////////////////////////////////////////////////////////////////
// solving without order -> cheaper

- (BOOL) solveWithoutOrderWithData:(NSArray *)patternsAndBoard {
    NSUInteger patternsCount = ((NSArray *)[patternsAndBoard objectAtIndex:0]).count;

    _recursions = 0;
    BOOL solved = [self solveUnorderedWithRestPatterns:[patternsAndBoard objectAtIndex:0]
                              andBoard:[patternsAndBoard objectAtIndex:1]
                      andPreviousMoves:[[NSMutableArray alloc] initWithCapacity:patternsCount]
                    andAbortWhenSolved:[[patternsAndBoard objectAtIndex:2] boolValue]];

    NSLog(@" -- done, %i solutions for unordered case", self.foundSolutions.count);

    // now, let's take a look at the results:
    [self sortFoundSolutions];
    [self removeDuplicatesFromFoundSolutions];
    NSLog(@" -- ... reduced to %i", self.foundSolutions.count);

    [self findEasiestUnorderedSolutionOnBoard:[patternsAndBoard objectAtIndex:1]];

    return solved;
}

- (void)findEasiestUnorderedSolutionOnBoard:(FFBoard*)board {
    for (NSArray *solution in self.foundSolutions) {
        NSArray *estimatedSolution = [self buildEstimatedSolutionWithUnorderedSolution:solution onBoard:board];
        [self printEstimatedSolutionToLog:estimatedSolution];
    }
}

- (NSArray *)buildEstimatedSolutionWithUnorderedSolution:(NSArray *)solution onBoard:(FFBoard *)board {
    NSMutableArray *restSolution = [NSMutableArray arrayWithArray:solution];
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:restSolution.count];
    FFBoard *testBoard = [[FFBoard alloc] initWithBoard:board];

    NSUInteger overallRestPatternTiles = 0;
    for (FFMove *move in solution) {
        overallRestPatternTiles += move.Pattern.Coords.count;
    }
    
    while (restSolution.count > 0){
        // find the easiest (least possibilities)
        NSUInteger minPossibilities = [self findPossibleAlternativesForMove:[restSolution objectAtIndex:0]
                                                                    onBoard:testBoard
                                                       withRestPatternTiles:overallRestPatternTiles];
        FFMove *easiestMove = [restSolution objectAtIndex:0];

        for (NSUInteger i = 1; i < restSolution.count; i++){
            FFMove * move = [restSolution objectAtIndex:i];
            NSUInteger possibilities = [self findPossibleAlternativesForMove:move
                                                                     onBoard:testBoard
                                                        withRestPatternTiles:overallRestPatternTiles];
            if (possibilities < minPossibilities){
                minPossibilities = possibilities;
                easiestMove = move;
            }
        }

        [ret addObject:[[FFMoveWithPossibilities alloc] initWithMove:easiestMove andAlternatives:(minPossibilities-1)]];
        [testBoard doMoveWithCoords:[easiestMove buildToFlipCoords]];
        [restSolution removeObject:easiestMove];
        overallRestPatternTiles -= easiestMove.Pattern.Coords.count;
    }

    return ret;
}

- (NSUInteger)findPossibleAlternativesForMove:(FFMove *)move onBoard:(FFBoard *)board withRestPatternTiles:(NSUInteger)restPatternTiles {
    NSUInteger possibilities = 0;

    FFBoard *resultBoard = [[FFBoard alloc] initWithBoard:board];
    restPatternTiles -= move.Pattern.Coords.count;

    for (int orientation = 0; orientation < [move.Pattern differingOrientations]; orientation++){
        int xSize = orientation%2==0 ? move.Pattern.SizeX : move.Pattern.SizeY;
        int ySize = orientation%2==0 ? move.Pattern.SizeY : move.Pattern.SizeX;

        // each position
        int maxX = board.BoardSize - xSize;
        int maxY = board.BoardSize - ySize;

        for (ushort y = 0; y <= maxY; y++){
            @autoreleasepool {
                for (ushort x = 0; x <= maxX; x++){
                    FFMove *tstMove = [[FFMove alloc] initWithPattern:move.Pattern
                                                           atPosition:[[FFCoord alloc] initWithX:x andY:y]
                                                       andOrientation:(FFOrientation) orientation];
                    [resultBoard duplicateStateFrom:board];
                    NSArray *flipped = [resultBoard doMoveWithCoords:[tstMove buildToFlipCoords]];

                    // simple check whether this move makes sense
                    if (![self checkWhetherSensibleMove:flipped
                                                onBoard:resultBoard
                           withRestPlayablePatternTiles:restPatternTiles]){
                        continue;
                    }
                    possibilities++;
                }
            }
        }
    }

    return possibilities;
}

- (void)removeDuplicatesFromFoundSolutions {
    NSMutableArray *reducedSolutionSet = [[NSMutableArray alloc] initWithCapacity:5];

    for (NSUInteger i = 0; i < self.foundSolutions.count; i++){
        NSArray *solutionA = [self.foundSolutions objectAtIndex:i];
        BOOL matchFound = NO;
        for (NSUInteger j = i+1; j < self.foundSolutions.count; j++){
            if ([self solutionA:solutionA equalsB:[self.foundSolutions objectAtIndex:j]]){
                matchFound = YES;
                break;
            }

        }
        if (!matchFound) [reducedSolutionSet addObject:solutionA];
    }
    self.foundSolutions = reducedSolutionSet;
}

- (void)sortFoundSolutions {
    for (NSMutableArray *solution in self.foundSolutions) {
        [solution sortUsingComparator:^NSComparisonResult(FFMove *a, FFMove *b){
            // compute a distinct move sum
            NSInteger aSum = a.moveSum;
            NSInteger bSum = b.moveSum;

            if (aSum == bSum) return NSOrderedSame;
            return (aSum>bSum? NSOrderedDescending : NSOrderedAscending);
        }];
    }
}

- (BOOL)solutionA:(NSArray *)a equalsB:(NSArray*)b {
    if (!a || !b || a.count != b.count) return NO;

    for (NSUInteger i = 0; i < a.count; i++){
        if (((FFMove *)[a objectAtIndex:i]).moveSum != ((FFMove *)[b objectAtIndex:i]).moveSum) return NO;
    }

    return YES;
}

- (BOOL)solveUnorderedWithRestPatterns:(NSArray *)patterns
                              andBoard:(FFBoard*)board
                      andPreviousMoves:(NSMutableArray *)moves
                    andAbortWhenSolved:(BOOL)abortAfterFirstSolution {
    _recursions++;

    if ([board isInTargetState]){
        [self.foundSolutions addObject:[[NSMutableArray alloc] initWithArray:moves]];
        return YES;
    }

    if (patterns.count < 1){
        return NO;
    }

    NSMutableArray *nextLevelPatterns = [[NSMutableArray alloc] initWithArray:patterns];
    FFPattern *myPattern = [nextLevelPatterns objectAtIndex:0];
    [nextLevelPatterns removeObject:myPattern];
    FFBoard *nextLevelBoard = [[FFBoard alloc] initWithBoard:board];

    BOOL solved = NO;

    for (int orientation = 0; orientation < [myPattern differingOrientations]; orientation++){
        int xSize = orientation%2==0 ? myPattern.SizeX : myPattern.SizeY;
        int ySize = orientation%2==0 ? myPattern.SizeY : myPattern.SizeX;

        // each position
        int maxX = board.BoardSize - xSize;
        int maxY = board.BoardSize - ySize;

        for (ushort y = 0; y <= maxY; y++){
            @autoreleasepool {
            for (ushort x = 0; x <= maxX; x++){
                FFMove *tstMove = [[FFMove alloc] initWithPattern:myPattern
                                                       atPosition:[[FFCoord alloc] initWithX:x andY:y]
                                                   andOrientation:(FFOrientation) orientation];
                [nextLevelBoard duplicateStateFrom:board];
                if (self.visualize){
                    [self performSelectorOnMainThread:@selector(showCurrentState:)
                                           withObject:[[FFBoard alloc] initWithBoard:nextLevelBoard]
                                        waitUntilDone:NO];
                    [NSThread sleepForTimeInterval:0.3];
                } // else: nothing to see

                NSArray *flipped = [nextLevelBoard doMoveWithCoords:[tstMove buildToFlipCoords]];
                tstMove.FlippedCoords = flipped;

                // simple check whether this move makes sense
                if (![self checkWhetherSensibleMove:flipped
                                            onBoard:nextLevelBoard
                                   withRestPatterns:nextLevelPatterns]){
                    continue;
                }

                if (self.visualize && flipped && flipped.count > 0){
                    [self performSelectorOnMainThread:@selector(showCurrentState:)
                                           withObject:[[FFBoard alloc] initWithBoard:nextLevelBoard]
                                        waitUntilDone:NO];
                    [NSThread sleepForTimeInterval:0.3];
                } // else: nothing to see

                [moves addObject:tstMove];
                solved |= [self solveUnorderedWithRestPatterns:nextLevelPatterns
                                                         andBoard:nextLevelBoard
                                                 andPreviousMoves:moves
                                               andAbortWhenSolved:abortAfterFirstSolution];

                if (abortAfterFirstSolution && solved){
                    return YES;
                }

                [moves removeObject:tstMove];
            }}
        }
    }
    return solved;
}

// ////////////////////////////////////////////////////////////////////////////
// solving with order (more costly)

- (BOOL) solveWithOrderAndData:(NSArray *)data {
    NSUInteger patternsCount = ((NSArray *)[data objectAtIndex:0]).count;

    _recursions = 0;
    BOOL solved = [self solveOrderedWithRestPatterns:[data objectAtIndex:0]
                              andBoard:[data objectAtIndex:1]
                      andPreviousMoves:[[NSMutableArray alloc] initWithCapacity:patternsCount]
                    andAbortWhenSolved:[[data objectAtIndex:2] boolValue]];
    NSLog(@" -- done, %i solutions, checked %i recursions -- ", self.foundSolutions.count,  _recursions);

    // now, let's take a look at the results:
    // which are just permutations?
    [self removeDuplicatesFromFoundSolutions];
    NSLog(@" -- ... reduced to %i", self.foundSolutions.count);

    [self findEasiestOrderedSolutionOnBoard:[data objectAtIndex:1]];

    return solved;
}

- (void)findEasiestOrderedSolutionOnBoard:(FFBoard*)board {
    for (NSArray *solution in self.foundSolutions) {
        NSArray *estimatedSolution = [self buildEstimatedSolutionWithOrderedSolution:solution onBoard:board];
        [self printEstimatedSolutionToLog:estimatedSolution];
    }
}

- (NSArray *)buildEstimatedSolutionWithOrderedSolution:(NSArray *)solution onBoard:(FFBoard *)board {
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:solution.count];
    FFBoard *testBoard = [[FFBoard alloc] initWithBoard:board];

    NSUInteger overallRestPatternTiles = 0;
    for (FFMove *move in solution) overallRestPatternTiles += move.Pattern.Coords.count;

    for (FFMove *move in solution) {
        // other positions for this pattern?
        NSUInteger possibilities = [self findPossibleAlternativesForMove:move
                                                                 onBoard:testBoard
                                                    withRestPatternTiles:overallRestPatternTiles];

        // TODO possible positions of other patterns!

        [ret addObject:[[FFMoveWithPossibilities alloc] initWithMove:move andAlternatives:(possibilities-1)]];
        [testBoard doMoveWithCoords:[move buildToFlipCoords]];
        overallRestPatternTiles -= move.Pattern.Coords.count;
    }

    return ret;
}

- (BOOL)solveOrderedWithRestPatterns:(NSMutableArray *)patterns
                            andBoard:(FFBoard *)board
                    andPreviousMoves:(NSMutableArray *)moves
                  andAbortWhenSolved:(BOOL)abortAfterFirstSolution{
    _recursions++;

    if ([board isInTargetState]){
        [self.foundSolutions addObject:[[NSMutableArray alloc] initWithArray:moves]];
        return YES;
    }

    if (patterns.count < 1){
        return NO;
    }

    NSMutableArray *nextLevelPatterns = [[NSMutableArray alloc] initWithArray:patterns];
    FFBoard *nextLevelBoard = [[FFBoard alloc] initWithBoard:board];

    BOOL solved = NO;

    for (FFPattern *pattern in patterns) {
        [nextLevelPatterns removeObject:pattern];

        // cut symmetrical patterns to just the basic orientation
        for (int orientation = 0; orientation < [pattern differingOrientations]; orientation++){
            int xSize = orientation%2==0 ? pattern.SizeX : pattern.SizeY;
            int ySize = orientation%2==0 ? pattern.SizeY : pattern.SizeX;

            // each position
            int maxX = board.BoardSize - xSize;
            int maxY = board.BoardSize - ySize;

            for (ushort y = 0; y <= maxY; y++){
                @autoreleasepool {
                for (ushort x = 0; x <= maxX; x++){
                    FFMove *tstMove = [[FFMove alloc] initWithPattern:pattern
                                                           atPosition:[[FFCoord alloc] initWithX:x andY:y]
                                                       andOrientation:(FFOrientation) orientation];
                    [nextLevelBoard duplicateStateFrom:board];
                    if (self.visualize){
                        [self performSelectorOnMainThread:@selector(showCurrentState:)
                                               withObject:[[FFBoard alloc] initWithBoard:nextLevelBoard]
                                            waitUntilDone:NO];
                        [NSThread sleepForTimeInterval:0.3];
                    } // else: nothing to see

                    NSArray *flipped = [nextLevelBoard doMoveWithCoords:[tstMove buildToFlipCoords]];

                    // simple check whether this move makes sense
                    if (![self checkWhetherSensibleMove:flipped
                                                onBoard:nextLevelBoard
                                       withRestPatterns:nextLevelPatterns]){
                        continue;
                    }

                    if (self.visualize && flipped && flipped.count > 0){
                        [self performSelectorOnMainThread:@selector(showCurrentState:)
                                               withObject:[[FFBoard alloc] initWithBoard:nextLevelBoard]
                                            waitUntilDone:NO];
                        [NSThread sleepForTimeInterval:0.3];
                    } // else: nothing to see

                    [moves addObject:tstMove];
                    solved |= [self solveOrderedWithRestPatterns:nextLevelPatterns
                                                        andBoard:nextLevelBoard
                                                andPreviousMoves:moves
                                              andAbortWhenSolved:abortAfterFirstSolution];

                    if (abortAfterFirstSolution && solved){
                        return YES;
                    }

                    [moves removeObject:tstMove];
                }}
            }
        }

        [nextLevelPatterns addObject:pattern];
    }

    return solved;
}

- (BOOL)checkWhetherSensibleMove:(NSArray *)flippedCoords
                         onBoard:(FFBoard *)board
                withRestPatterns:(NSMutableArray *)restPatterns {

    // anything awry already?
    for (FFCoord *coord in flippedCoords) {
        if ([board tileAtX:coord.x andY:coord.y].color > 20){
//            NSLog(@"aborted. flipped to unsolvable tile.");
            return NO;
        }
    }

    // can we still solve this?
    NSUInteger minRestFlips = [board computeMinimumRestFlips];
    NSUInteger flipsLeft = 0;
    for (FFPattern *pattern in restPatterns) flipsLeft += pattern.Coords.count;

    return flipsLeft >= minRestFlips;
}

- (BOOL)checkWhetherSensibleMove:(NSArray *)flippedCoords
                         onBoard:(FFBoard *)board
    withRestPlayablePatternTiles:(NSUInteger)restPatternTiles {

    // anything awry already?
    for (FFCoord *coord in flippedCoords) {
        if ([board tileAtX:coord.x andY:coord.y].color > 30){
//            NSLog(@"aborted. flipped to unsolvable tile.");
            return NO;
        }
    }

    // can we still solve this?
    NSUInteger minRestFlips = [board computeMinimumRestFlips];

    return restPatternTiles >= minRestFlips;
}

// /////////////////////////////////////////////////////////////////////////
// simpler fire-once stuff

- (int) findValidPositionsForPattern:(FFPattern *)pattern onBoard:(FFBoard *)board {

    // how many POSSIBLE positions?

    // how many PLAUSIBLE positions?


    /*

    new difficulty estimation algorithm
    - find the number of plausible other positions for each pattern in a solution path
    - add up all those numbers
    = the path with lowest overall score is a valid estimate!


     */

    NSLog(@"FIND VALID POSITIONS!!");

    return 123;
}


// /////////////////////////////////////////////////////////////////////////////////////////
// util

- (int)possiblePositionsForPattern:(FFPattern *)pattern onBoard:(FFBoard *)board {
    return MAX(1, (board.BoardSize - pattern.SizeX + 1) * (board.BoardSize - pattern.SizeY + 1) * pattern.differingOrientations);
}

- (void)showCurrentState:(FFBoard *)board{
    [self.setGame DEBUG_replaceBoardWith:board];
}

- (void)printEstimatedSolutionToLog:(NSArray *)estimatedSolution {
    CGFloat averageAlternatives = 0;
    for (FFMoveWithPossibilities *m in estimatedSolution) {
        averageAlternatives += m.alternatives;
    }
    averageAlternatives = averageAlternatives / MAX(1,(CGFloat)estimatedSolution.count);

    NSString *string = [NSString stringWithFormat:@"ESTIMATION with average %f: ", averageAlternatives];
    for (FFMoveWithPossibilities *m in estimatedSolution) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%i, ", m.alternatives]];
    }
    
    NSLog(@"%@", string);
}

@end
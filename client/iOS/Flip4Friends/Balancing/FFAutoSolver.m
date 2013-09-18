//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 9/11/13.
//


#import "FFAutoSolver.h"
#import "FFGamesCore.h"
#import "FFPattern.h"

@interface FFAutoSolver ()

@property (strong, nonatomic) FFGame *setGame;

@property (nonatomic) NSMutableArray *foundSolutions;

@end


@implementation FFAutoSolver {
    NSUInteger _orientations;
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


- (void)solveAsynchronously {
    FFGame *game = self.setGame;
    _orientations = game.ruleAllowPatternRotation ? 4 : 1;

    NSMutableArray *restPatterns = [[NSMutableArray alloc] initWithCapacity:game.player1.playablePatterns.count];
    for (FFPattern *pattern in game.player1.playablePatterns) {
        if ([game.player1.doneMoves objectForKey:pattern.Id]) continue;
        [restPatterns addObject:pattern];
    }

    [self performSelectorInBackground:@selector(solve:) withObject:@[restPatterns, game.Board]];
}

- (void)solveSynchronously {
    FFGame *game = self.setGame;
    _orientations = game.ruleAllowPatternRotation ? 4 : 1;

    NSMutableArray *restPatterns = [[NSMutableArray alloc] initWithCapacity:game.player1.playablePatterns.count];
    for (FFPattern *pattern in game.player1.playablePatterns) {
        if ([game.player1.doneMoves objectForKey:pattern.Id]) continue;
        [restPatterns addObject:pattern];
    }

    [self solve:@[restPatterns, game.Board]];
}


- (void)solve:(NSArray*)data {
    if (self.setGame.Board.lockMoves < 1){
        [self solveWithoutOrderWithData:data];
    } else {
        [self solveWithOrderAndData:data];
    }
}

// ////////////////////////////////////////////////////////////////////////////
// solving without order -> cheaper

- (void)solveWithoutOrderWithData:(NSArray *)patternsAndBoard {
    NSUInteger patternsCount = ((NSArray *)[patternsAndBoard objectAtIndex:0]).count;

    NSUInteger possibilities = 1;
    for (int i = patternsCount-1; i >= 0; i--){
        possibilities *=
                _orientations
                * [self possiblePositionsForPattern:[((NSArray *) [patternsAndBoard objectAtIndex:0]) objectAtIndex:(NSUInteger)i]
                                            onBoard:[patternsAndBoard objectAtIndex:1]];
    }

    NSLog(@"Starting unordered. %i possibilities", possibilities);

    _recursions = 0;
    [self solveUnorderedWithRestPatterns:[patternsAndBoard objectAtIndex:0]
                              andBoard:[patternsAndBoard objectAtIndex:1]
                      andPreviousMoves:[[NSMutableArray alloc] initWithCapacity:patternsCount]];

    // now, let's take a look at the results:
    // which are just permutations?

    // TODO

    NSLog(@" -- done, %i solutions for unordered case, checked %i recursions -- ", self.foundSolutions.count,  _recursions);
}

- (void)solveUnorderedWithRestPatterns:(NSArray *)patterns andBoard:(FFBoard*)board andPreviousMoves:(NSMutableArray *)moves {
    _recursions++;

    if ([board isInTargetState]){
        NSLog(@"SOLVED!");
        [self.foundSolutions addObject:[[NSMutableArray alloc] initWithArray:moves]];
        return;
    }

    if (patterns.count < 1){
//        NSLog(@"DONE but not solved.");
        return;
    }

    NSMutableArray *nextLevelPatterns = [[NSMutableArray alloc] initWithArray:patterns];
    FFPattern *myPattern = [nextLevelPatterns objectAtIndex:0];
    [nextLevelPatterns removeObject:myPattern];
    FFBoard *nextLevelBoard = [[FFBoard alloc] initWithBoard:board];

    // TODO cut symmetrical patterns to just the basic orientation
    for (int orientation = 0; orientation < _orientations; orientation++){
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
                [self solveUnorderedWithRestPatterns:nextLevelPatterns andBoard:nextLevelBoard andPreviousMoves:moves];
                [moves removeObject:tstMove];
            }}
        }
    }
}

// ////////////////////////////////////////////////////////////////////////////
// solving with order (more costly)

- (void)solveWithOrderAndData:(NSArray *)data {
    NSUInteger patternsCount = ((NSArray *)[data objectAtIndex:0]).count;

    NSUInteger possibilities = 1;
    for (int i = patternsCount; i > 0; i--){
        possibilities = possibilities
                * i
                * _orientations
                * [self possiblePositionsForPattern:[((NSArray *) [data objectAtIndex:0]) objectAtIndex:(NSUInteger) (i - 1)]
                                            onBoard:[data objectAtIndex:1]];
    }

    NSLog(@"Starting. %i possibilities", possibilities);

    _recursions = 0;
    [self solveOrderedWithRestPatterns:[data objectAtIndex:0]
                              andBoard:[data objectAtIndex:1]
                      andPreviousMoves:[[NSMutableArray alloc] initWithCapacity:patternsCount]];

    // now, let' take a look at the results:
    // which are just permutations?

    // TODO

    NSLog(@" -- done, %i solutions, checked %i recursions -- ", self.foundSolutions.count,  _recursions);
}

- (void)solveOrderedWithRestPatterns:(NSMutableArray *)patterns
                            andBoard:(FFBoard *)board
                    andPreviousMoves:(NSMutableArray *)moves {
    _recursions++;

    if ([board isInTargetState]){
        NSLog(@"SOLVED!");
        [self.foundSolutions addObject:[[NSMutableArray alloc] initWithArray:moves]];
        return;
    }

    if (patterns.count < 1){
//        NSLog(@"DONE but not solved.");
        return;
    }

    NSMutableArray *nextLevelPatterns = [[NSMutableArray alloc] initWithArray:patterns];
    FFBoard *nextLevelBoard = [[FFBoard alloc] initWithBoard:board];

    for (FFPattern *pattern in patterns) {
        [nextLevelPatterns removeObject:pattern];

        // cut symmetrical patterns to just the basic orientation
        for (int orientation = 0; orientation < _orientations; orientation++){
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
                    [self solveOrderedWithRestPatterns:nextLevelPatterns andBoard:nextLevelBoard andPreviousMoves:moves];
                    [moves removeObject:tstMove];
                }}
            }
        }

        [nextLevelPatterns addObject:pattern];
    }
}

- (BOOL)checkWhetherSensibleMove:(NSArray *)flippedCoords
                         onBoard:(FFBoard *)board
                withRestPatterns:(NSMutableArray *)restPatterns {

    // anything awry already?
    for (FFCoord *coord in flippedCoords) {
        if ([board tileAtX:coord.x andY:coord.y].color > 30) return NO;
    }

    // can we still solve this?
    NSUInteger minRestFlips = [board computeMinimumRestFlips];
    NSUInteger flipsLeft = 0;
    for (FFPattern *pattern in restPatterns) flipsLeft += pattern.Coords.count;

    return flipsLeft >= minRestFlips;
}

// /////////////////////////////////////////////////////////////////////////////////////////
// util

- (int)possiblePositionsForPattern:(FFPattern *)pattern onBoard:(FFBoard *)board {
    return MAX(1, (board.BoardSize - pattern.SizeX + 1) * (board.BoardSize - pattern.SizeY + 1));
}

- (void)showCurrentState:(FFBoard *)board{
    [self.setGame DEBUG_replaceBoardWith:board];
}


@end
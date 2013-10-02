//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 9/11/13.
//


#import <Foundation/Foundation.h>
@class FFGame;
@class FFPattern;
@class FFBoard;

/**
* Brute-force solves every challenge. Analyzes the difficulty along the way.
*/
@interface FFAutoSolver : NSObject

@property (nonatomic) BOOL visualize;

- (id)initWithGameId:(NSString *)gameId;

- (id)initWithGame:(FFGame *)game;

/**
* Tries to solve the challenge *from the current state*!
*/
- (void)solveAsynchronously;

- (void)solveSynchronously;


- (int) findValidPositionsForPattern:(FFPattern *)pattern onBoard:(FFBoard *)board;
@end
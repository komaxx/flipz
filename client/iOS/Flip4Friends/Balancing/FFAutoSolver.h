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
@property (atomic) BOOL toastResult;

- (id)initWithGameId:(NSString *)gameId;

- (id)initWithGame:(FFGame *)game;

- (void)solveAsynchronouslyAndAbortWhenFirstFound:(BOOL)abortWhenFirstFound;

- (void)solveSynchronouslyAndAbortWhenFirstFound:(BOOL)abortWhenFirstFound;

- (int) findValidPositionsForPattern:(FFPattern *)pattern onBoard:(FFBoard *)board;
@end
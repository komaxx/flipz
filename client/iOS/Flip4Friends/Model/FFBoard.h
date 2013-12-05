//
//  FFBoard.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFTile.h"

typedef enum {
    /**
    * flips just let a tile alternate between black and white
    */
    kFFBoardType_twoStated=0,
    kFFBoardType_multiStated_clamped=1,
    kFFBoardType_multiStated_rollover=2,
} FFBoardType;

/**
* Represents the boardView, i.e., it contains all the tiles that make up the gaming boardView.
*/
@interface FFBoard : NSObject

/**
* All boards are squares, thus only one value.
*/
@property (nonatomic, readonly) NSUInteger BoardSize;

/**
* How the tiles will behave.
*/
@property (nonatomic) FFBoardType BoardType;

/**
* How long after a tile was flipped it stays unflippable.
*/
@property (nonatomic) NSInteger lockMoves;

/**
* Mandatory initializer. Others just don't count.
*/
- (id)initWithSize:(NSUInteger)boardSize;

- (id)initWithBoard:(FFBoard *)board;


/**
* Delivers a tile at the given coordinate (coordinate system is computed from
* the upper left corner).
*/
- (FFTile *)tileAtX:(NSUInteger)x andY:(NSUInteger) y;

- (void)shuffle;

/**
* Delivers the coords that were actually flipped.
*/
- (NSArray *)doMoveWithCoords:(NSArray *)coords;

- (BOOL)isSingleChromatic;

- (void)cleanMonochromaticTo:(NSUInteger)cleanColor;

- (void)checker;

- (NSUInteger)scoreForColor:(int)color;

- (NSUInteger)scoreStraightWithLength:(int)length;

- (NSUInteger)countTilesWithColor:(int)color;

- (NSUInteger)computeMaxClusterSizeForColor:(int)i;

- (void)unlock;

- (void)duplicateStateFrom:(FFBoard *)board;

- (void)flipTile:(FFTile *)tile;

- (BOOL)buildGameByFlippingCoords:(NSArray *)array;

- (BOOL)isInTargetState;

- (NSUInteger)computeMinimumRestFlips;

- (void)colorTile:(NSUInteger)i withColor:(NSNumber *)color;

- (NSString *)makeColorsString;

- (void)printColorsToLog;

- (void)clampTiles;

- (void)addColorsToArray:(NSMutableArray *)array;

- (NSString*)makeAsciiBoard;
@end

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
    kFFBoardType_twoStated,
    kFFBoardType_multiStated
} FFBoardType;

/**
* Represents the board, i.e., it contains all the tiles that make up the gaming board.
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
* Mandatory initializer. Others just don't count.
*/
- (id)initWithSize:(NSUInteger)boardSize;

/**
* Delivers a tile at the given coordinate (coordinate system is computed from
* the upper left corner).
*/
- (FFTile *)tileAtX:(NSUInteger)x andY:(NSUInteger) y;

- (void)shuffle;

/**
* Delivers the coords that were actually flipped.
*/
- (NSArray *)flipCoords:(NSArray *)array countingUp:(BOOL)up andLock:(BOOL)lock;

- (BOOL)isSingleChromatic;

- (void)cleanMonochromaticTo:(NSUInteger)cleanColor;

- (void)checker;

- (NSUInteger)scoreForColor:(int)color;

- (NSUInteger)countTilesWithColor:(int)color;

- (NSUInteger)computeMaxClusterSizeForColor:(int)i;

- (void)unlock;

- (void)duplicateStateFrom:(FFBoard *)board;
@end

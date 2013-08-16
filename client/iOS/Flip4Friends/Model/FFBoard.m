//
//  FFBoard.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFBoard.h"
#import "FFCoord.h"

@interface FFBoard ()
/**
* one dimensional array. Represents the square gaming board row-first:
*     _____
*    |1|2|3|
*    |-|-|-|
*    |4|5|6|
*     ~~~~~
*/
@property (strong, nonatomic) NSArray *tiles;

@property(nonatomic, readwrite) NSUInteger BoardSize;

@end

@implementation FFBoard

- (id)initWithSize:(NSUInteger)boardSize {
    self = [super init];
    if (self) {
        self.BoardSize = boardSize;

        NSUInteger tileCount = boardSize*boardSize;
        self.tiles = [[NSMutableArray alloc] initWithCapacity:tileCount];
        for (NSUInteger i = 0; i < tileCount; i++){
            [(NSMutableArray *) self.tiles addObject:[[FFTile alloc] init]];
        }
    }

    return self;
}

- (FFTile *)tileAtX:(NSUInteger)x andY:(NSUInteger)y {
    return [self.tiles objectAtIndex:(y*self.BoardSize + x)];
}

- (void)cleanMonochromaticTo:(NSUInteger)cleanColor {
    for (FFTile *tile in self.tiles) {
        tile.color = cleanColor;
        tile.locked = NO;
    }
}

- (void)shuffle {
    for (FFTile *tile in self.tiles) {
        tile.color = arc4random() % 2 == 0 ? 0 : 99;
    }
}

- (void)checker {
    for (int y = 0; y < self.BoardSize; y++){
        for (int x = 0; x < self.BoardSize; x++){
            [self tileAtX:x andY:y].color = (x+y) % 2;
        }
    }
}


- (NSArray *)flipCoords:(NSArray *)coords countingUp:(BOOL)up andLock:(BOOL)lock {
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:coords.count];

    for (FFTile *tile in self.tiles) tile.marked = tile.locked ? 1 : 0;

    for (FFCoord* c in coords) {
        FFTile *tile = [self tileAtX:c.x andY:c.y];
        if (tile.locked) continue;

        [ret addObject:c];

        if (self.BoardType == kFFBoardType_twoStated){
            tile.color = (tile.color+1)%2;
        } else {
            [tile flipCountingUp:up];
        }

        tile.marked+=2;
    }

    for (FFTile *tile in self.tiles){
        tile.locked = tile.marked>1 ? YES : NO;
    }

    return ret;
}

- (BOOL)isSingleChromatic {
    NSInteger firstColor =[(FFTile *) [self.tiles objectAtIndex:0] color];
    for (FFTile *tile in self.tiles) {
        if (tile.color != firstColor) return NO;
    }
    return YES;
}

- (NSUInteger) scoreForColor:(int)color {
    return [self countTilesWithColor:color];
//    return [self computeMaxClusterSizeForColor:color];
}

- (NSUInteger)countTilesWithColor:(int)color {
    NSUInteger ret = 0;
    for (FFTile *tile in self.tiles) {
        if (tile.color == color) ret++;
    }
    return ret;
}

- (NSUInteger)computeMaxClusterSizeForColor:(int)color {
    NSUInteger bestResult = 0;

    for (FFTile *tile in self.tiles) tile.marked = NO;

    for (NSUInteger y = 0; y < _BoardSize; y++){
        for (NSUInteger x = 0; x < _BoardSize; x++){
            NSUInteger nowResult = [self fillClusterFromX:x andY:y forColor:color];
            if (nowResult > bestResult) bestResult = nowResult;
        }
    }

    return bestResult;
}

- (NSUInteger)fillClusterFromX:(NSUInteger)x andY:(NSUInteger)y forColor:(int)color{
    FFTile *tile = [self tileAtX:x andY:y];
    if (tile.color != color || tile.marked) return 0;

    tile.marked = YES;

    NSUInteger ret = 1;
    if (x > 0) ret += [self fillClusterFromX:x-1 andY:y forColor:color];
    if (y > 0) ret += [self fillClusterFromX:x andY:y-1 forColor:color];
    if (x < _BoardSize-1) ret += [self fillClusterFromX:x+1 andY:y forColor:color];
    if (y < _BoardSize-1) ret += [self fillClusterFromX:x andY:y+1 forColor:color];

    return ret;
}

- (void)unlock {
    for (FFTile *tile in self.tiles) {
        tile.locked = NO;
    }
}

- (void)duplicateStateFrom:(FFBoard *)board {
    for (NSUInteger i = 0; i < self.tiles.count; i++){
        [(FFTile *)[self.tiles objectAtIndex:i] duplicateStateFrom:[board.tiles objectAtIndex:i]];
    }
}
@end

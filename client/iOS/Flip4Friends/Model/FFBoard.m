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

- (void)shuffle {
    for (FFTile *tile in self.tiles) {
        tile.color = arc4random() % 2;
    }
}

- (void)flipCoords:(NSArray *)coords {
    for (FFCoord* c in coords) {
        [[self tileAtX:c.x andY:c.y] flip];
    }
}
@end

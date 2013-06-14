//
//  FFBoard.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFBoard.h"
#import "FFTile.h"

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

@end

@implementation FFBoard
- (id)initWithSize:(NSInteger)boardSize {
    self = [super init];
    if (self) {
        _BoardSize = boardSize;
    }

    return self;
}



- (FFTile *)tileAtX:(NSUInteger)x andY:(NSUInteger)y {
    return nil;
}


@end

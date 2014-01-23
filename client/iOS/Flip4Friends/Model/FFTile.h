//
//  FFTile.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFTile : NSObject

@property (nonatomic) NSInteger color;

/**
* When a tile is locked, it can not be changed in the next move.
*/
@property (nonatomic) NSInteger unlockTime;

/**
* Only to be set by the boardView!
*/
@property (nonatomic) BOOL nowLocked;

/**
* Only to be set by the boardView!
*/
@property (nonatomic) BOOL doubleLocked;

/**
* For core internal use (e.g., cluster finding). Not to be used by any other thing but
* the FFBoard.
*/
@property (nonatomic) NSInteger marked;

- (void)duplicateStateFrom:(id)o;

@end

//
//  FFTile.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFTile.h"

@interface FFTile ()
@end

@implementation FFTile

- (void)duplicateStateFrom:(FFTile *)source {
    self.marked = source.marked;
    self.nowLocked = source.nowLocked;
    self.doubleLocked = source.doubleLocked;
    self.unlockTime = source.unlockTime;
    self.color = source.color;
}
@end

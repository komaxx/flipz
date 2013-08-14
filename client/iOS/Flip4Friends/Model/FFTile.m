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

/**
* Only to be called by the Board. Never manipulate directly!
*/
- (void)flipCountingUp:(BOOL)up {
    if (up) _color++;
//    else if (self.color > 0) _color--;
    else _color--;
}
@end

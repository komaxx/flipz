//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import <Foundation/Foundation.h>

/**
* The simplest class I can think of. Guess what it does.
*/
@interface FFCoord : NSObject
    @property ushort x;
    @property ushort y;

- (id)initWithX:(ushort)i andY:(ushort)y;

- (void)moveByX:(int)i andY:(int)y;

- (id)copyTranslatedBy:(FFCoord *)coord;
@end
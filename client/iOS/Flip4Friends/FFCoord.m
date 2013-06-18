//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import "FFCoord.h"


@implementation FFCoord

- (id)initWithX:(ushort)x andY:(ushort)y {
    self = [super init];
    if (self){
        self.x = x;
        self.y = y;
    }
    return self;
}

- (void)moveByX:(int)x andY:(int)y {
    self.x += x;
    self.y += y;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) return NO;

    return self.x == ((FFCoord*)object).x && self.y == ((FFCoord*)object).y;
}

- (id)copyTranslatedBy:(FFCoord *)t {
    return [[FFCoord alloc] initWithX:(self.x+t.x) andY:(self.y+t.y)];
}
@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import "FFPlayer.h"
#import "FFMove.h"
#import "FFPattern.h"


@implementation FFPlayer {
}

- (id)init {
    self = [super init];
    if (self) {
        self.playablePatterns = [[NSArray alloc] initWithObjects:nil];
        self.doneMoves = [[NSMutableDictionary alloc] initWithCapacity:5];
    }

    return self;
}

- (void)setDoneMove:(FFMove *)move {
    [((NSMutableDictionary *) self.doneMoves) setObject:move forKey:move.Pattern.Id];
}

- (void)undoMove:(FFMove *)move {
    [((NSMutableDictionary *) self.doneMoves) removeObjectForKey:move.Pattern.Id];
}

- (void)resetWithPatterns:(NSArray *)array {
    [(NSMutableDictionary *) self.doneMoves removeAllObjects];
    self.playablePatterns = array;
}

- (BOOL)allPatternsPlayed {
    return self.playablePatterns.count == self.doneMoves.count;
}

- (void)clearDoneMoves {
    [(NSMutableDictionary *)self.doneMoves removeAllObjects];
}
@end
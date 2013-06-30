//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import "FFPlayer.h"


@implementation FFPlayer {

}

- (id)init {
    self = [super init];
    if (self) {
        self.playablePatterns = [[NSArray alloc] initWithObjects:nil];
        self.alreadyPlayedPatternIds = [[NSMutableDictionary alloc] initWithCapacity:5];
    }

    return self;
}


@end
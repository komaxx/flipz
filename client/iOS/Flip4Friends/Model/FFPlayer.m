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
    }

    return self;
}

- (void)resetWithPatterns:(NSArray *)array {
    self.playablePatterns = array;
}

@end
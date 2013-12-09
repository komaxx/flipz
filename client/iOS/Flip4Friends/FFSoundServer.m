//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/19/13.
//


#import <AudioToolbox/AudioToolbox.h>
#import "FFSoundServer.h"
#import "FFStorageUtil.h"

@interface FFSoundServer ()
@property CFURLRef flipUrl;
@property SystemSoundID flipId;
@end


@implementation FFSoundServer {
}

- (id)init {
    self = [super init];
    if (self) {
        self.flipUrl = (__bridge CFURLRef) [[NSBundle mainBundle] URLForResource: @"flip" withExtension: @"aiff"];

        AudioServicesCreateSystemSoundID ( self.flipUrl, &_flipId);
    }

    return self;
}

- (void)playFlipSound {
    if (![FFStorageUtil isSoundDisabled]) AudioServicesPlaySystemSound (self.flipId);
}

// //////////////////////////////////////////////////////////////////////
// Singleton

static FFSoundServer *singleton;
+ (FFSoundServer *)instance {
    if (!singleton){
        singleton = [[FFSoundServer alloc] init];
    }
    return singleton;
}


@end
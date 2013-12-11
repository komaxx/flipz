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

@property CFURLRef ticUrl;
@property SystemSoundID ticId;

@end


@implementation FFSoundServer {
}

- (id)init {
    self = [super init];
    if (self) {
        self.flipUrl = (__bridge CFURLRef) [[NSBundle mainBundle] URLForResource: @"flip" withExtension: @"aiff"];
        self.ticUrl = (__bridge CFURLRef) [[NSBundle mainBundle] URLForResource: @"tic" withExtension: @"aiff"];

        AudioServicesCreateSystemSoundID ( self.flipUrl, &_flipId);
        AudioServicesCreateSystemSoundID ( self.ticUrl, &_ticId);
    }

    return self;
}

- (void)playFlipSound {
    if (![FFStorageUtil isSoundDisabled]) AudioServicesPlaySystemSound (self.flipId);
}

- (void)playTicSound {
    if (![FFStorageUtil isSoundDisabled]) AudioServicesPlaySystemSound (self.ticId);
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
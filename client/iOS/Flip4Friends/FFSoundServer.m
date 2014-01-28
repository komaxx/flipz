//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/19/13.
//


#import <AVFoundation/AVFoundation.h>
#import "FFSoundServer.h"
#import "FFStorageUtil.h"

@interface FFSoundServer ()

@property (strong, nonatomic) NSDictionary *players;

@end


@implementation FFSoundServer {
}

- (id)init {
    self = [super init];
    if (self) {
        NSMutableDictionary *p = [[NSMutableDictionary alloc] initWithCapacity:4];

        [self addPlayer:@"flip" to:p];
        [self addPlayer:@"tic" to:p];
        [self addPlayer:@"won" to:p];
        [self addPlayer:@"lost" to:p];

        self.players = p;
    }

    return self;
}

- (void)addPlayer:(NSString *)soundFileName to:(NSMutableDictionary *)playersDict {
    NSString *path =[[NSBundle mainBundle] pathForResource:soundFileName ofType:@"aiff"];
    NSURL *url = [NSURL fileURLWithPath:path];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    [player setVolume:1.0];

    [playersDict setObject:player forKey:soundFileName];
}


- (void)playFlipSound {
    [self play:@"flip"];
}

- (void)playTicSound {
    [self play:@"tic"];
}

- (void)playWonSound {
    [self play:@"won"];
}

- (void)playLostSound {
    [self play:@"lost"];
}


- (void)play:(NSString *)soundFileName {
    if ([FFStorageUtil isSoundDisabled]) return;

    AVAudioPlayer *player = [self.players objectForKey:soundFileName];
    [player play];
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
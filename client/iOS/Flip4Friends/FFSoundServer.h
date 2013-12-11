//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/19/13.
//


#import <Foundation/Foundation.h>


@interface FFSoundServer : NSObject
+ (FFSoundServer *)instance;

- (void)playFlipSound;

- (void)playTicSound;
@end
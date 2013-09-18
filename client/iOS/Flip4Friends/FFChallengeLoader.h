//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 9/18/13.
//


#import <Foundation/Foundation.h>

@class FFGame;


@interface FFChallengeLoader : NSObject

- (FFGame *)loadLevel:(NSUInteger)level;

- (NSUInteger)numberOfChallenges;

@end
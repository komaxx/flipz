//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 9/18/13.
//


#import <Foundation/Foundation.h>

@class FFGame;


@interface FFPuzzleLoader : NSObject

+ (NSString *)encodeGameAsJson:(FFGame *)game;

- (FFGame *)loadLevel:(NSUInteger)level;

- (NSUInteger)numberOfChallenges;

@end
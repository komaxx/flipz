//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 9/16/13.
//


#import <Foundation/Foundation.h>

@class FFGame;

@interface FFChallengeGenerator : NSObject

- (NSUInteger)levelCount;

- (FFGame*)generateChallengeForLevel:(NSUInteger)level;
@end
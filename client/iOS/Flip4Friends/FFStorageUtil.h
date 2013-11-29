//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 10/9/13.
//


#import <Foundation/Foundation.h>


@interface FFStorageUtil : NSObject

+ (NSUInteger) firstUnsolvedPuzzleIndex;

+ (void) setFirstUnsolvedPuzzleIndex:(NSUInteger)nuIndex;

+ (NSUInteger)getTimesPlayedForChallengeLevel:(NSUInteger)level;

+ (void)setTimesPlayed:(NSUInteger)timesPlayed forChallengeLevel:(NSUInteger)level;

+ (NSUInteger)getTimesWonForChallengeLevel:(NSUInteger)value;

+ (void)setTimesWon:(NSUInteger)timesWon forChallengeLevel:(NSUInteger)level;
@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 10/9/13.
//


#import <Foundation/Foundation.h>


@interface FFStorageUtil : NSObject

+ (NSInteger)firstUnsolvedPuzzleIndex;

+ (void) setFirstUnsolvedPuzzleIndex:(NSUInteger)nuIndex;

+ (NSUInteger)getTimesPlayedForChallengeLevel:(NSUInteger)level;

+ (void)setTimesPlayed:(NSUInteger)timesPlayed forChallengeLevel:(NSUInteger)level;

+ (NSUInteger)getTimesWonForChallengeLevel:(NSUInteger)value;

+ (void)setTimesWon:(NSUInteger)timesWon forChallengeLevel:(NSUInteger)level;

+ (void)setSoundDisabled:(BOOL)b;

+ (BOOL)isSoundDisabled;

+ (double)getLastAppBackgroundTime;
+ (void)setLastAppBackgroundTime:(double)lastTime;

+ (int)getAppTimesOpened;
+ (void)setTimesAppOpened:(int)nuTimesOpened;

+ (BOOL)rateRequestDialogFinished;
+ (void)setRateRequestDialogFinished;

+ (NSTimeInterval)getLastSkipTime;
@end
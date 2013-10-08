//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 10/9/13.
//


#import "FFStorageUtil.h"

#define FIRST_UNSOLVED_CHALLENGE_INDEX_KEY @"firstUnsolvedChallenge"

@implementation FFStorageUtil {
}

static NSUInteger _firstUnsolvedChallengeIndex;;

+ (NSUInteger)firstUnsolvedChallengeIndex {
    if (_firstUnsolvedChallengeIndex < 1){
        _firstUnsolvedChallengeIndex = MAX(1,
            (NSUInteger) [[NSUserDefaults standardUserDefaults] integerForKey:FIRST_UNSOLVED_CHALLENGE_INDEX_KEY]);

        #ifdef DEBUG_ALL_ACCESS
        _firstUnsolvedChallenge = 9999;
        #endif
    }

    return _firstUnsolvedChallengeIndex;
}


+ (void)setFirstUnsolvedChallengeIndex:(NSUInteger)nuIndex {
    if (nuIndex <= _firstUnsolvedChallengeIndex) return;    // can only be increased!

    _firstUnsolvedChallengeIndex = nuIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:_firstUnsolvedChallengeIndex
                                               forKey:FIRST_UNSOLVED_CHALLENGE_INDEX_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
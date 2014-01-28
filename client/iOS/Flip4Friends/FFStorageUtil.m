//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 10/9/13.
//


#import "FFStorageUtil.h"
#import "FFGamesCore.h"

#define UNLOCKED_KEY @"unlocked"
#define FIRST_UNSOLVED_CHALLENGE_INDEX_KEY @"firstUnsolvedChallenge"
#define CHALLENGE_TIMES_PLAYED_KEY @"challengeTimesPlayed_%i"
#define CHALLENGE_TIMES_WON_KEY @"challengeTimesWon_%i"
#define SOUND_DISABLED_KEY @"sound_disabled"
#define LAST_APP_BACKGROUND_KEY @"last_background"
#define TIMES_APP_OPENED_KEY @"times_app_opened"
#define RATING_DIALOG_FINISHED @"rating_dialog_finished"
#define LAST_SKIP_TIME_KEY @"last_skip_time"

//#define DEBUG_ALL_ACCESS 1
//#define DEBUG_UNLOCK


@implementation FFStorageUtil {
}

static NSUInteger _firstUnsolvedChallengeIndex;
static NSMutableDictionary *_challengeTimesPlayed;
static NSMutableDictionary *_challengeTimesWon;
static NSNumber *unlocked;

static BOOL soundIsDisabled;


+ (BOOL)isUnlocked {
    #ifdef DEBUG_UNLOCK
    return YES;
    #endif

    if (!unlocked){
        unlocked = @([[NSUserDefaults standardUserDefaults] boolForKey:UNLOCKED_KEY]);
    }
    return [unlocked boolValue];
}

+ (void)unlockThisAwesomeFantasmagon {
    unlocked = @(YES);
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:UNLOCKED_KEY];
}

//////////////////////////////////////////////////////////////////
// challenge times played.

+ (NSUInteger)firstUnsolvedPuzzleIndex {
    if (_firstUnsolvedChallengeIndex < 1){
        _firstUnsolvedChallengeIndex = MAX(1,
            (NSUInteger) [[NSUserDefaults standardUserDefaults] integerForKey:FIRST_UNSOLVED_CHALLENGE_INDEX_KEY]);

        #ifdef DEBUG_ALL_ACCESS
        _firstUnsolvedChallengeIndex = 100;
        #endif
    }

    return _firstUnsolvedChallengeIndex;
}

+ (void)setFirstUnsolvedPuzzleIndex:(NSUInteger)nuIndex {
    if (nuIndex <= _firstUnsolvedChallengeIndex) return;    // can only be increased!

    _firstUnsolvedChallengeIndex = nuIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:_firstUnsolvedChallengeIndex
                                               forKey:FIRST_UNSOLVED_CHALLENGE_INDEX_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//////////////////////////////////////////////////////////////////
// challenge times played.

+ (void)initTimesPlayedDictionary {
    _challengeTimesPlayed = [[NSMutableDictionary alloc] initWithCapacity:5];
    NSUInteger challengesCount =[[FFGamesCore instance] autoGeneratedLevelCount];
    for (NSUInteger i = 0; i < challengesCount; i++){
        NSString *key = [NSString stringWithFormat:CHALLENGE_TIMES_PLAYED_KEY, i];
        if (![[NSUserDefaults standardUserDefaults] objectForKey:key]) continue;

        NSInteger timesPlayed = [[NSUserDefaults standardUserDefaults] integerForKey:key];
        [_challengeTimesPlayed setObject:@(timesPlayed) forKey:@(i)];
    }
}

+ (NSUInteger)getTimesPlayedForChallengeLevel:(NSUInteger)level {
    if (!_challengeTimesPlayed) [FFStorageUtil initTimesPlayedDictionary];
    return [[_challengeTimesPlayed objectForKey:@(level)] unsignedIntegerValue];
}

+ (void)setTimesPlayed:(NSUInteger)timesPlayed forChallengeLevel:(NSUInteger)level {
    if (!_challengeTimesPlayed) [FFStorageUtil initTimesPlayedDictionary];
    [_challengeTimesPlayed setObject:@(timesPlayed) forKey:@(level)];

    // store it
    NSUInteger challengesCount =[[FFGamesCore instance] autoGeneratedLevelCount];
    for (NSUInteger i = 0; i < challengesCount; i++){
        [[NSUserDefaults standardUserDefaults]
                setInteger:[[_challengeTimesPlayed objectForKey:@(i)] integerValue]
                    forKey:[NSString stringWithFormat:CHALLENGE_TIMES_PLAYED_KEY, i]];
    }
}

//////////////////////////////////////////////////////////////////
// challenge levels won.

+ (void)initTimesWonDictionary {
    _challengeTimesWon = [[NSMutableDictionary alloc] initWithCapacity:5];
    NSUInteger challengesCount =[[FFGamesCore instance] autoGeneratedLevelCount];
    for (NSUInteger i = 0; i < challengesCount; i++){
        NSString *key = [NSString stringWithFormat:CHALLENGE_TIMES_WON_KEY, i];
        if (![[NSUserDefaults standardUserDefaults] objectForKey:key]) continue;

        NSInteger timesWon = [[NSUserDefaults standardUserDefaults] integerForKey:key];
        [_challengeTimesWon setObject:@(timesWon) forKey:@(i)];
    }
}

+ (NSUInteger)getTimesWonForChallengeLevel:(NSUInteger)level {
    if (!_challengeTimesWon) [FFStorageUtil initTimesWonDictionary];
    return [[_challengeTimesWon objectForKey:@(level)] unsignedIntegerValue];
}

+ (void)setTimesWon:(NSUInteger)timesWon forChallengeLevel:(NSUInteger)level {
    if (!_challengeTimesWon) [FFStorageUtil initTimesWonDictionary];
    [_challengeTimesWon setObject:@(timesWon) forKey:@(level)];

    // store it
    NSUInteger challengesCount =[[FFGamesCore instance] autoGeneratedLevelCount];
    for (NSUInteger i = 0; i < challengesCount; i++){
        [[NSUserDefaults standardUserDefaults]
                setInteger:[[_challengeTimesWon objectForKey:@(i)] integerValue]
                    forKey:[NSString stringWithFormat:CHALLENGE_TIMES_WON_KEY, i]];
    }
}

//////////////////////////////////////////////////////////////////
// sound on or off

+ (void)setSoundDisabled:(BOOL)b {
    soundIsDisabled = b;
    [[NSUserDefaults standardUserDefaults] setBool:b forKey:SOUND_DISABLED_KEY];
}

static BOOL readSoundDisabledFromDisk;
+ (BOOL)isSoundDisabled {
    if (!readSoundDisabledFromDisk){
        soundIsDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:SOUND_DISABLED_KEY];
        readSoundDisabledFromDisk = YES;
    }
    return soundIsDisabled;
}

//////////////////////////////////////////////////////////////////
// request rating dialog

+ (double)getLastAppBackgroundTime {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:LAST_APP_BACKGROUND_KEY];
}

+ (void)setLastAppBackgroundTime:(double)time {
    [[NSUserDefaults standardUserDefaults] setDouble:time forKey:LAST_APP_BACKGROUND_KEY];
}

+ (int)getAppTimesOpened {
    return [[NSUserDefaults standardUserDefaults] integerForKey:TIMES_APP_OPENED_KEY];
}

+ (void)setTimesAppOpened:(int)nuTimesOpened {
    [[NSUserDefaults standardUserDefaults] setInteger:nuTimesOpened forKey:TIMES_APP_OPENED_KEY];
}

+ (BOOL)rateRequestDialogFinished {
    return [[NSUserDefaults standardUserDefaults] boolForKey:RATING_DIALOG_FINISHED];
}

+ (void)setRateRequestDialogFinished {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:RATING_DIALOG_FINISHED];
}

+ (double)getLastSkipTime {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:LAST_SKIP_TIME_KEY];
}

@end

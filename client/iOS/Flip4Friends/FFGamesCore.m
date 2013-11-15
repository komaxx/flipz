//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/14/13.
//


#import "FFGamesCore.h"
#import "FFGame.h"
#import "FFChallengeGenerator.h"
#import "FFChallengeLoader.h"

@interface FFGamesCore ()
@property (strong, nonatomic) NSMutableDictionary *gamesById;
@property (strong, nonatomic) NSMutableDictionary *challengeByNumber;


@property(strong, nonatomic) FFChallengeLoader *loader;
@property(strong, nonatomic) FFChallengeGenerator *generator;

@end

@implementation FFGamesCore {
}

// ////////////////////////////////////////////////////////////////////////
// StartUp


- (id)init {
    self = [super init];
    if (self) {
        self.gamesById = [[NSMutableDictionary alloc] initWithCapacity:10];
        self.challengeByNumber = [[NSMutableDictionary alloc] initWithCapacity:10];

        self.loader = [[FFChallengeLoader alloc] init];
        self.generator = [[FFChallengeGenerator alloc] init];
    }
    return self;
}

- (FFGame *)autoGeneratedChallenge:(NSUInteger)level {
    FFGame* generated = [self.generator generateChallengeForLevel:level];
    [self registerGame:generated];

    return generated;
}



- (NSUInteger)challengesCount {
    return [self.loader numberOfChallenges];
}

- (NSUInteger)autoGeneratedLevelCount {
    return [self.generator levelCount];
}

- (FFGame *)challenge:(NSUInteger)i {
    FFGame *challenge = [self.challengeByNumber objectForKey:[NSNumber numberWithUnsignedInteger:i]];
    if (!challenge){
        challenge = [self.loader loadLevel:i];
        [self.gamesById setObject:challenge forKey:challenge.Id];
    }

    return challenge;
}

// StartUp
// ////////////////////////////////////////////////////////////////////////

- (void)registerGame:(FFGame *)game {
    [self.gamesById setObject:game forKey:game.Id];
}

- (FFGame *)generateNewHotSeatGame {
    FFGame *nuHotSeat = [[FFGame alloc] initHotSeat];
    [self registerGame:nuHotSeat];

    return nuHotSeat;
}

- (FFGame *)gameWithId:(NSString *)string {
    return [self.gamesById objectForKey:string];
}

// ////////////////////////////////////////////////////////////////////////
// Singleton

+ (FFGamesCore *)instance {
    static FFGamesCore *singleInstance;
    if (!singleInstance) {
        singleInstance = [[FFGamesCore alloc] init];
    }
    return singleInstance;
}

@end
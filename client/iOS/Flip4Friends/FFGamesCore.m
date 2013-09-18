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
    }
    return self;
}

- (FFGame *)generateNewChallenge {
    FFChallengeGenerator *generator = [[FFChallengeGenerator alloc] init];

    FFGame *nuChallenge = [generator
            generateWithBoardSize:10
                   andOverLapping:YES
                      andRotation:NO
                     andLockTurns:0];

    [self.gamesById setObject:nuChallenge forKey:nuChallenge.Id];

    return nuChallenge;
}

- (NSUInteger)challengesCount {
    return [self.loader numberOfChallenges];
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


- (FFGame *)generateNewHotSeatGame {
    FFGame *nuHotSeat = [[FFGame alloc] initHotSeat];
    [self.gamesById setObject:nuHotSeat forKey:nuHotSeat.Id];

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
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/14/13.
//


#import "FFGamesCore.h"
#import "FFGame.h"

@interface FFGamesCore ()
@property (strong, nonatomic) NSMutableDictionary *gamesById;
@property(strong, nonatomic, readwrite) NSArray *challenges;

@end

@implementation FFGamesCore {
}

- (id)init {
    self = [super init];
    if (self) {
        self.gamesById = [[NSMutableDictionary alloc] initWithCapacity:10];

        [self loadOrBuildChallenges];
    }
    return self;
}

- (void)loadOrBuildChallenges {
    self.challenges = [[NSMutableArray alloc] initWithCapacity:20];

    // TODO loading

    for (int i = 0; i < 20; i++){
        FFGame *challenge = [[FFGame alloc] initChallengeWithDifficulty:i];

        [(NSMutableArray*)self.challenges addObject:challenge];
        [self.gamesById setObject:challenge forKey:challenge.Id];
    }
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

- (FFGame *)gameWithId:(NSString *)string {
    return [self.gamesById objectForKey:string];
}

@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/14/13.
//


#import "FFGamesCore.h"
#import "FFGame.h"

NSString *const kFFNotificationGameChanged = @"ffGameChanged";
NSString *const kFFNotificationGameChanged_gameId = @"gameId";

@interface FFGamesCore ()
@property (strong, nonatomic) NSMutableDictionary *gamesById;
@end

@implementation FFGamesCore {
}

- (id)init {
    self = [super init];
    if (self) {
        self.gamesById = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return self;
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
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/14/13.
//


#import "FFGamesControl.h"
#import "FFGame.h"

NSString *const kFFNotificationGameChanged = @"ffGameChanged";
NSString *const kFFNotificationGameChanged_gameId = @"gameId";

@interface FFGamesControl ()
@property (strong, nonatomic) NSMutableDictionary *gamesById;
@end

@implementation FFGamesControl {
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

+ (FFGamesControl *)instance {
    static FFGamesControl *singleInstance;
    if (!singleInstance) {
        singleInstance = [[FFGamesControl alloc] init];
    }
    return singleInstance;
}

- (FFGame *)gameWithId:(NSString *)string {
    return [self.gamesById objectForKey:string];
}

@end
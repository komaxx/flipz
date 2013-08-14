//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/14/13.
//


#import <Foundation/Foundation.h>
#import "FFGame.h"


/**
* Class that is concerned with loading/saving gamesById and handling communication
* with servers.
*/
@interface FFGamesCore : NSObject

/**
* Singleton instance. Each access should happen through this call. Do
* not initialize your own.
*/
+(FFGamesCore *) instance;

@property (strong, nonatomic, readonly) NSArray *activeGames;

/**
* All challenges.
*/
@property (strong, nonatomic, readonly) NSArray *challenges;

- (FFGame *)gameWithId:(NSString *)string;

- (FFGame *)generateNewHotSeatGame;
@end
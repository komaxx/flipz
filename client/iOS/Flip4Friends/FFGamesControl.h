//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/14/13.
//


#import <Foundation/Foundation.h>

/**
* Name of the notification whenever a game changes somehow. Will contain the id of the FFGame
* that was changed in the userData under key 'kFFNotificationGameChanged_gameId'
*/
extern NSString *const kFFNotificationGameChanged;
/**
* Key for the game_id that is delivered in the 'game changed' notification
*/
extern NSString *const kFFNotificationGameChanged_gameId;


/**
* Class that is concerned with loading/saving gamesById and handling communication
* with servers.
*/
@interface FFGamesControl : NSObject

/**
* Singleton instance. Each access of the gamesById control should happen through this call. Do
* not initialize your own.
*/
+(FFGamesControl *) instance;

- (FFGame *)gameWithId:(NSString *)string;
@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 8/16/13.
//


#import <Foundation/Foundation.h>


@interface FFAutoPlayer : NSObject
- (id)initWithGameId:(NSString *)gameId andPlayerId:(NSString *)playerId;

- (void)startPlaying;

- (void)endPlaying;

@end
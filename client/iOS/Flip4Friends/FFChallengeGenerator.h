//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 9/16/13.
//


#import <Foundation/Foundation.h>

@class FFGame;

@interface FFChallengeGenerator : NSObject

@property(nonatomic) NSUInteger numberOfChallenges;

- (void) generateForLevel:(NSUInteger)level andCallback:(void (^)(FFGame *, NSUInteger))callbackBlock;

- (FFGame *)generateWithBoardSize:(int)i andOverLapping:(BOOL)lapping andRotation:(BOOL)rotation andLockTurns:(int)lockTurns;
@end
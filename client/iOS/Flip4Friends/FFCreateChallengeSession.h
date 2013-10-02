//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 9/23/13.
//


#import <Foundation/Foundation.h>

@class FFBoard;


@interface FFCreateChallengeSession : NSObject
@property (strong, nonatomic) NSMutableArray *moves;

+ (FFCreateChallengeSession *) instance;

- (FFBoard *) paintedBoard;

- (FFBoard *)moveTmpBoard;

+ (NSString *)tmpGameId;

- (void)updatePaintBoardWith:(FFBoard *)board;

- (void)buildAndStoreTmpGame;

- (void)resetMoveBoard;
@end
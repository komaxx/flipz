//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 8/16/13.
//


#import "FFAutoPlayer.h"
#import "FFGame.h"
#import "FFGamesCore.h"
#import "FFPattern.h"

@interface FFAutoPlayer ()
@property (copy, nonatomic) NSString *gameId;
@property (copy, nonatomic) NSString *myPlayerId;

@property (strong, nonatomic) FFBoard *tmpBoard;
@end

@implementation FFAutoPlayer {
}

- (id)initWithGameId:(NSString *)gameId andPlayerId:(NSString *)playerId {
    self = [super init];
    if (self) {
        _myPlayerId = playerId;
        _gameId = gameId;
    }

    return self;
}

- (void)startPlaying {
    [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(checkIfMyTurnWithNotification:) name:kFFNotificationGameChanged object:nil];
    [self checkIfMyTurn];
}

- (void)endPlaying {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkIfMyTurnWithNotification:(NSNotification *)notification {
    NSString *changedGameID = [notification.userInfo objectForKey:kFFNotificationGameChanged_gameId];
    if (![changedGameID isEqualToString:self.gameId]) return;
    [self checkIfMyTurn];
}

- (void)checkIfMyTurn {
//    NSLog(@"Update!");

    FFGame *game = [[FFGamesCore instance] gameWithId:self.gameId];
    if (![game.activePlayer.id isEqualToString:self.myPlayerId]){
        return;    // not my turn
    }

    if (game.gameState == kFFGameState_Finished){
        return;     // we're done.
    }

    [self move];
}

- (void)move {
    FFGame *game = [[FFGamesCore instance] gameWithId:self.gameId];

    if (!self.tmpBoard || self.tmpBoard.BoardSize != game.Board.BoardSize){
        self.tmpBoard = [[FFBoard alloc] initWithSize:game.Board.BoardSize];
    }

    int myColor = [game.player1.id isEqualToString:self.myPlayerId] ? 0 : 1;
    int otherColor = myColor==0 ? 1 : 0;

    FFMove *bestMove = nil;
    NSInteger bestScore = -1000;

    FFPlayer *player = game.activePlayer;
    for (FFPattern *pattern in player.playablePatterns) {
        if ([player.doneMoves objectForKey:pattern.Id]) continue;       // already played.

        // each orientation
        for (int orientation = 0; orientation < 4; orientation++){
            int xSize = orientation%2==0 ? pattern.SizeX : pattern.SizeY;
            int ySize = orientation%2==0 ? pattern.SizeY : pattern.SizeX;

            // each position
            int maxX = self.tmpBoard.BoardSize - xSize;
            int maxY = self.tmpBoard.BoardSize - ySize;

            for (ushort y = 0; y < maxY; y++){
                @autoreleasepool {
                    for (ushort x = 0; x < maxX; x++){
                        [self.tmpBoard duplicateStateFrom:game.Board];

                        FFMove *tstMove = [[FFMove alloc] initWithPattern:pattern
                                                               atPosition:[[FFCoord alloc] initWithX:x andY:y]
                                                           andOrientation:(FFOrientation) orientation];
                        [self.tmpBoard flipCoords:[tstMove buildToFlipCoords] countingUp:NO andLock:YES];

                        NSInteger nowScore =
                                [self.tmpBoard scoreForColor:myColor] - [self.tmpBoard scoreForColor:otherColor];
                        if (nowScore >= bestScore){
                            bestMove = tstMove;
                            bestScore = nowScore;
                        }
                    }
                }
            }
        }
    }

    // and do it!
    if (bestMove){
//        [self executeMove:@[bestMove,player]];
//        [self performSelector:@selector(executeMove:) withObject:@[bestMove,player] afterDelay:0];
        [self performSelector:@selector(executeMove:) withObject:@[bestMove,player]];
    } else {
        NSLog(@"ERROR!! no move found!");
    }
}

- (void)executeMove:(NSArray *)moveAndPlayer {
    [[[FFGamesCore instance] gameWithId:self.gameId]
            executeMove:[moveAndPlayer objectAtIndex:0] byPlayer:[moveAndPlayer objectAtIndex:1]];
}


@end
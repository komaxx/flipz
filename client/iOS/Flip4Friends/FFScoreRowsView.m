//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/20/13.
//


#import "FFScoreRowsView.h"
#import "FFBoardView.h"
#import "FFGame.h"
#import "FFGamesCore.h"
#import "UIColor+FFColors.h"

@interface FFScoreRowsView ()

@property (weak, nonatomic) CAShapeLayer *whiteScoresLayer;
@property (weak, nonatomic) CAShapeLayer *blackScoresLayer;

@property (copy, nonatomic) NSString *activeGameId;
@property (copy, nonatomic) NSString *lastActivePlayerId;

@end

@implementation FFScoreRowsView {
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.userInteractionEnabled = NO;

        CAShapeLayer *blackLayer = [[CAShapeLayer alloc] init];
        blackLayer.strokeColor = [[UIColor movePattern2Back] CGColor];
        blackLayer.lineCap = @"round";
        [self.layer addSublayer:blackLayer];
        self.blackScoresLayer = blackLayer;

        CAShapeLayer *whiteLayer = [[CAShapeLayer alloc] init];
        whiteLayer.strokeColor = [[UIColor movePatternBack] CGColor];
        whiteLayer.lineCap = @"round";
        [self.layer addSublayer:whiteLayer];
        self.whiteScoresLayer = whiteLayer;

        self.whiteScoresLayer.lineWidth = 8;
        self.blackScoresLayer.lineWidth = 8;
    }

    return self;
}


- (void)didAppear {
    [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(gameChanged:) name:kFFNotificationGameChanged object:nil];
}

- (void)setActiveGame:(FFGame *)game {
    self.hidden = YES;
    if (!game || game.Type != kFFGameTypeHotSeat){
        self.activeGameId = nil;
        return;
    }

    self.activeGameId = game.Id;
}

- (void)gameChanged:(NSNotification *)notification {
    if (!self.activeGameId) return;

    NSString *changedGameID = [notification.userInfo objectForKey:kFFNotificationGameChanged_gameId];
    if (![changedGameID isEqualToString:self.activeGameId]) {
        return;  // ignore. Update for the wrong game (not the active one).
    }

    FFGame *game = [[FFGamesCore instance] gameWithId:changedGameID];
    if (![game.ActivePlayer.id isEqualToString:self.lastActivePlayerId]){
        self.lastActivePlayerId = game.ActivePlayer.id;
        [self showScoringForGame:game];
    }

}

- (void)showScoringForGame:(FFGame *)game {
    CGMutablePathRef whitePath = CGPathCreateMutable();
    CGMutablePathRef blackPath = CGPathCreateMutable();

    [self addSoringViewsForColor:0 inGame:game toPath:whitePath];
    [self addSoringViewsForColor:1 inGame:game toPath:blackPath];

    self.whiteScoresLayer.path = whitePath;
    self.blackScoresLayer.path = blackPath;

    CGPathRelease(whitePath);
    CGPathRelease(blackPath);
    self.hidden = NO;
}

- (void)addSoringViewsForColor:(int)color inGame:(FFGame *)game toPath:(CGMutablePathRef )path {
    FFBoard *board = game.Board;

    FFCoord *startCoord;
    // horizontal straights
    for (NSUInteger y = 0; y < board.BoardSize; y++){
        startCoord = nil;
        for (NSUInteger x = 0; x < board.BoardSize; x++){
            if ([board tileAtX:x andY:y].color == color){
                // yay, one more :)
                if (!startCoord) startCoord = [[FFCoord alloc] initWithX:(ushort)x andY:(ushort) y];
            } else if (startCoord){ // the straight ended. Score it!
                int length = x - startCoord.x;

                if ([board scoreStraightWithLength:length] > 0){
                    [self addScoringFrom:startCoord
                                 toCoord:[[FFCoord alloc] initWithX:(x - 1) andY:y]
                                forColor:color
                                  toPath:path];
                }
                startCoord = nil;
            }
        }
        if (startCoord && [board scoreStraightWithLength:board.BoardSize-startCoord.x] > 0){
            [self addScoringFrom:startCoord
                         toCoord:[[FFCoord alloc] initWithX:board.BoardSize - 1 andY:y]
                        forColor:color
                          toPath:path ];
        }
    }

    // vertical straights
    for (NSUInteger x = 0; x < board.BoardSize; x++){
        startCoord = nil;
        for (NSUInteger y = 0; y < board.BoardSize; y++){
            if ([board tileAtX:x andY:y].color == color){
                // yay, one more :)
                if (!startCoord) startCoord = [[FFCoord alloc] initWithX:(ushort) x andY:(ushort) y];
            } else if (startCoord){ // the straight ended. Score it!
                int length = y - startCoord.y;

                if ([board scoreStraightWithLength:length] > 0){
                    [self addScoringFrom:startCoord
                                 toCoord:[[FFCoord alloc] initWithX:x andY:y - 1]
                                forColor:color
                                  toPath:path ];
                }
                startCoord = nil;
            }
        }
        if (startCoord && [board scoreStraightWithLength:board.BoardSize-startCoord.y] > 0){
            [self addScoringFrom:startCoord
                         toCoord:[[FFCoord alloc] initWithX:x andY:board.BoardSize - 1]
                        forColor:color
                          toPath:path ];
        }
    }
}

- (void)addScoringFrom:(FFCoord *)fromCoord
               toCoord:(FFCoord *)toCoord
              forColor:(int)color toPath:(CGMutablePathRef )path {
    CGPoint offset = self.boardView.frame.origin;

    CGPoint start = [self.boardView computeTileCenterOfCoord:fromCoord];
    CGPoint end = [self.boardView computeTileCenterOfCoord:toCoord];

    CGPathMoveToPoint(path, &CGAffineTransformIdentity, start.x + offset.x, start.y + offset.y);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, end.x + offset.x, end.y + offset.y);

//    if (ABS(toCoord.x - fromCoord.x) + ABS(toCoord.y - fromCoord.y) > 3){
//        CGPathMoveToPoint(path, &CGAffineTransformIdentity, start.x + offset.x + 4, start.y + offset.y);
//        CGPathAddLineToPoint(path, &CGAffineTransformIdentity, end.x + offset.x + 4, end.y + offset.y);
//    }
}

- (void)didDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
//
//  FFBoardView.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFBoardView.h"
#import "FFGamesCore.h"
#import "FFPattern.h"
#import "FFTileViewMultiStated.h"
#import "FFPatternGenerator.h"

@interface FFBoardView()
/**
* One-dimensional array of tile-views, constructed when a game is set.
*/
@property (strong, nonatomic) NSMutableArray* tileViews;

@property (copy, nonatomic) NSString *activeGameId;

@property (strong, nonatomic) NSMutableDictionary * historyTileSets;
@property (strong, nonatomic) NSMutableDictionary * removeCollector;

@property FFBoard *introBoard;

@end

#define MAX_HISTORY_MOVES 1

@implementation FFBoardView {
    BOOL _introFlipping;
    CGFloat _tileSize;
    NSUInteger _shownBoardSize;

    BOOL _visible;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.tileViews = [[NSMutableArray alloc] initWithCapacity:(8*8)];

    self.historyTileSets = [[NSMutableDictionary alloc] initWithCapacity:10];
    self.removeCollector = [[NSMutableDictionary alloc] initWithCapacity:10];
}

- (void)didAppear {
    _visible = YES;
    if (!_activeGameId){
        [self startIntroFlipping];
    }

    [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(gameChanged:) name:kFFNotificationGameChanged object:nil];
}

- (void)didDisappear {
    _visible = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)gameChanged:(NSNotification *)notification {
    NSString *changedGameID = [notification.userInfo objectForKey:kFFNotificationGameChanged_gameId];
    if ([changedGameID isEqualToString:self.activeGameId]) {
        FFGame *game = [[FFGamesCore instance] gameWithId:changedGameID];
        if (game) [self setActiveGame:game];
    }
}

- (void)setActiveGame:(FFGame *)game {
    if (!game){
        self.activeGameId = nil;
        [self startIntroFlipping];
        return;
    }

    FFBoard *board = game.Board;

    if (![game.Id isEqualToString:self.activeGameId] || game.Board.BoardSize != _shownBoardSize){
        self.activeGameId = game.Id;
        [self updateTileCountFromBoard:board];
    }

    if (game.Type == kFFGameTypeSingleChallenge){
        for (FFTileViewMultiStated *view in self.tileViews) view.tileType = game.Board.BoardType;
    } else if (game.Type == kFFGameTypeHotSeat){
        for (FFTileViewMultiStated *view in self.tileViews) view.tileType = kFFBoardType_twoStated;
    }

    [self updateTilesFromBoard:board];
}

- (void)updateTilesFromBoard:(FFBoard *)board {
    NSUInteger size = board.BoardSize;
    for (NSUInteger y = 0; y < size; y++){
        for (NSUInteger x = 0; x < size; x++){
            [[self getTileAtX:x andY:y] updateFromTile:[board tileAtX:x andY:y]];
        }
    }
}

- (NSInteger)boardSize {
    return _shownBoardSize;
}

- (CGFloat)computeTileSize {
    return _tileSize;
}

- (void) showHistoryStartingFromStepsBack:(NSUInteger)startStepsBack {
    [self.removeCollector removeAllObjects];
    [self.removeCollector addEntriesFromDictionary:self.historyTileSets];

    NSArray *moves = [[FFGamesCore instance] gameWithId:self.activeGameId].moveHistory;

    int startMoveIndex = moves.count-startStepsBack-1;
    int endMoveIndex = MAX(-1, startMoveIndex - MAX_HISTORY_MOVES);
    int backStep = 0;
    for (NSInteger i = startMoveIndex; i > endMoveIndex; i--){
        FFMove *nowMove = [moves objectAtIndex:(NSUInteger) i];
        [self.removeCollector removeObjectForKey:nowMove.Pattern.Id];

        NSArray *tiles = [self.historyTileSets objectForKey:nowMove.Pattern.Id];
        if (!tiles){
            // make
            NSArray *flipCoords = nowMove.FlippedCoords;
            tiles = [[NSMutableArray alloc] initWithCapacity:flipCoords.count];
            for (FFCoord *coord in flipCoords) {
                UIView *tileView = [[UIView alloc] initWithFrame:[self getTileAtX:coord.x andY:coord.y].frame];
                [(NSMutableArray *) tiles addObject:tileView];
                [self addSubview:tileView];
            }
            [self.historyTileSets setObject:tiles forKey:nowMove.Pattern.Id];
        }
        for (UIView *tileView in tiles) {
            tileView.backgroundColor =
                    [UIColor colorWithPatternImage:[FFPatternGenerator createHistoryMoveOverlayPatternForStep:backStep]];
        }

        backStep++;
    }

    // remove invisibles
    for (NSString *key in self.removeCollector) {
        NSArray *tileSetToRemove = [self.removeCollector objectForKey:key];
        for (UIView *toRemove in tileSetToRemove) {
            [toRemove removeFromSuperview];
        }
        [self.historyTileSets removeObjectForKey:key];
    }
    [self.removeCollector removeAllObjects];
}

- (void)hideHistory {
    [self showHistoryStartingFromStepsBack:1000];
}

/**
* Checks, whether the board shows the right count of tiles. Will update the view if not.
*/
- (void)updateTileCountFromBoard:(FFBoard *)board {
    NSUInteger nuBoardSize = board.BoardSize;
    NSUInteger nuTileCount = nuBoardSize * nuBoardSize;

    if (nuTileCount > self.tileViews.count){
        // add some tiles!
        CGRect centerFrame = CGRectMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), 1, 1);
        for (int i = self.tileViews.count; i < nuTileCount; i++){
            UIView<FFTileView> *nuTileView = [[FFTileViewMultiStated alloc] initWithFrame:centerFrame];
            [self.tileViews addObject:nuTileView];
            [self addSubview:nuTileView];
        }
    } else if (nuTileCount < self.tileViews.count){
        // remove some views
        for (NSUInteger i = self.tileViews.count-1; i >= nuTileCount; i--){
            [(UIView<FFTileView>*)[self.tileViews objectAtIndex:i] removeYourself];
            [self.tileViews removeObjectAtIndex:i];
        }
    } else {
        // nothing changed. Do nothing.
        return;
    }
    _shownBoardSize = nuBoardSize;

    // reposition tiles
    _tileSize = self.bounds.size.width / nuBoardSize;

    for (NSUInteger y = 0; y < nuBoardSize; y++){
        for (NSUInteger x = 0; x < nuBoardSize; x++){
            [[self getTileAtX:x andY:y] positionAt:CGRectMake(x*_tileSize, y*_tileSize, _tileSize, _tileSize)];
        }
    }
}

- (UIView<FFTileView> *)getTileAtX:(NSUInteger)x andY:(NSUInteger)y {
    return [self.tileViews objectAtIndex:(y*_shownBoardSize + x)];
}


// //////////////////////////////////////////////////////////////////////////
// intro / no game selected stuff

- (void)startIntroFlipping {
    if (_introFlipping) return;
    _introFlipping = YES;

    self.introBoard = [[FFBoard alloc] initWithSize:6];
    [self.introBoard shuffle];

    for (FFTileViewMultiStated *view in self.tileViews) view.tileType = kFFBoardType_twoStated;

    [self updateTileCountFromBoard:self.introBoard];
    [self updateTilesFromBoard:self.introBoard];

    [self performSelector:@selector(doRandomIntroMove) withObject:nil afterDelay:1 inModes:@[NSRunLoopCommonModes]];
}

- (void)doRandomIntroMove {
    if (self.activeGameId || !_visible){
        _introFlipping = NO;
        return;
    }

    if (arc4random()%3 == 0){
        self.introBoard = [[FFBoard alloc] initWithSize:(2 + arc4random()%3)];
        [self updateTileCountFromBoard:self.introBoard];
    }
    [self.introBoard shuffle];
    [self updateTilesFromBoard:self.introBoard];

    [self performSelector:@selector(doRandomIntroMove) withObject:nil afterDelay:1 inModes:@[NSRunLoopCommonModes]];
}

- (CGPoint)computeTileCenterOfCoord:(FFCoord *)coord {
    return CGPointMake(_tileSize/2 + coord.x*_tileSize, _tileSize/2 + coord.y*_tileSize);
}
@end

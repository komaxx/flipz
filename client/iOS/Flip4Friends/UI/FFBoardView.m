//
//  FFBoardView.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFBoardView.h"
#import "FFGamesCore.h"
#import "FFTileView.h"
#import "FFGame.h"
#import "FFBoard.h"
#import "FFPattern.h"

@interface FFBoardView()
/**
* One-dimensional array of tile-views, constructed when a game is set.
*/
@property (strong, nonatomic) NSMutableArray* tileViews;

@property (copy, nonatomic) NSString *activeGameId;

@property FFBoard *introBoard;

@end

@implementation FFBoardView {
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
        if (game) [self updateWithGame:game];
    }
}

- (void)updateWithGame:(FFGame *)game {
    if (!game) return;

    FFBoard *board = game.Board;

    if (![game.Id isEqualToString:self.activeGameId]){
        self.activeGameId = game.Id;
        [self updateTileCountFromBoard:board];
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
            FFTileView *nuTileView = [[FFTileView alloc] initWithFrame:centerFrame];
            [self.tileViews addObject:nuTileView];
            [self addSubview:nuTileView];
        }
    } else if (nuTileCount < self.tileViews.count){
        // remove some views
        for (NSUInteger i = self.tileViews.count-1; i >= nuTileCount; i--){
            [(FFTileView *)[self.tileViews objectAtIndex:i] removeYourself];
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

- (FFTileView *)getTileAtX:(NSUInteger)x andY:(NSUInteger)y {
    return [self.tileViews objectAtIndex:(y*_shownBoardSize + x)];
}


// //////////////////////////////////////////////////////////////////////////
// intro / no game selected stuff

- (void)startIntroFlipping {
    self.introBoard = [[FFBoard alloc] initWithSize:7];
    [self.introBoard shuffle];

    [self updateTileCountFromBoard:self.introBoard];
    [self updateTilesFromBoard:self.introBoard];

    [self performSelector:@selector(doRandomIntroMove) withObject:nil afterDelay:1 inModes:@[NSRunLoopCommonModes]];
}

- (void)doRandomIntroMove {
    if (self.activeGameId || !_visible) return;

    if (arc4random()%3 == 0){
        self.introBoard = [[FFBoard alloc] initWithSize:(2 + arc4random()%6)];
        [self updateTileCountFromBoard:self.introBoard];
    }
    [self.introBoard shuffle];
    [self updateTilesFromBoard:self.introBoard];

    [self performSelector:@selector(doRandomIntroMove) withObject:nil afterDelay:1 inModes:@[NSRunLoopCommonModes]];
}

@end

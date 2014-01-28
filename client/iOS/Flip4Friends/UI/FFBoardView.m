//
//  FFBoardView.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFBoardView.h"
#import "FFGamesCore.h"
#import "FFTileViewMultiStated.h"
#import "FFPatternGenerator.h"
#import "FFHistorySlider.h"
#import "FFHistoryStep.h"
#import "FFSoundServer.h"
#import "FFHint.h"

@interface FFBoardView()
/**
* One-dimensional array of tile-views, constructed when a game is set.
*/
@property (strong, nonatomic) NSMutableArray* tileViews;
@property (copy, nonatomic) NSString *activeGameId;
@property (strong, nonatomic) NSMutableArray *hintTiles;
@property FFBoard *introBoard;

@end


@implementation FFBoardView {
    BOOL _introFlipping;
    CGFloat _tileSize;
    NSUInteger _shownBoardSize;

    BOOL _enableAudio;

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
    self.hintTiles = [[NSMutableArray alloc] initWithCapacity:12];
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
        [self removeAllHintTiles];
        self.activeGameId = game.Id;
        [self updateTileCountFromBoard:board];
    }

    if (game.Type == kFFGameTypeSingleChallenge){
        for (FFTileViewMultiStated *view in self.tileViews) view.tileType = game.Board.BoardType;
    } else if (game.Type == kFFGameTypeHotSeat){
        for (FFTileViewMultiStated *view in self.tileViews) view.tileType = kFFBoardType_twoStated;
    }

    [self updateTilesFromBoard:board];
    [self updateHintsFromGame:game];
    _enableAudio = YES;
}

- (void)updateTilesFromBoard:(FFBoard *)board {
    NSUInteger size = board.BoardSize;

    if (size != _shownBoardSize) [self updateTileCountFromBoard:board];
    if ([(FFTileViewMultiStated *)[self.tileViews objectAtIndex:0] tileType] != board.BoardType){
        for (FFTileViewMultiStated *view in self.tileViews) view.tileType = board.BoardType;
    }

    BOOL actuallyFlipped = NO;
    for (NSUInteger y = 0; y < size; y++){
        for (NSUInteger x = 0; x < size; x++){
            actuallyFlipped |= [[self getTileAtX:x andY:y] updateFromTile:[board tileAtX:x andY:y]];
        }
    }

    if (actuallyFlipped){
        [self playFlipSound];
    }
}

- (void)playFlipSound {
    if (_enableAudio) [[FFSoundServer instance] playFlipSound];
}

- (NSInteger)boardSize {
    return _shownBoardSize;
}

- (CGFloat)computeTileSize {
    return _tileSize;
}

- (void)updateHintsFromGame:(FFGame *)game {
    int hintIndex = 0;
    for (FFHint* hint in game.hints){
        if (!hint.active) continue;
        for (FFCoord* coord in hint.coords){
            CGRect frame = [self getTileAtX:coord.x andY:coord.y].frame;
            frame.size.width *= 0.4f;
            frame.size.height *= 0.4f;

            if (hintIndex%2==1) frame.origin.x += 2*frame.size.width;
            if (hintIndex > 3) frame.origin.y += frame.size.height;
            else if (hintIndex>1) frame.origin.y +=  2*frame.size.height;

            UILabel *tileView = [[UILabel alloc] initWithFrame:frame];
            tileView.text = [NSString stringWithFormat:@"%i", (hintIndex+1)];
            tileView.textAlignment = NSTextAlignmentCenter;
            tileView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:12];
            tileView.shadowColor = [UIColor whiteColor];
            tileView.shadowOffset = CGSizeMake(1, 2);
            tileView.backgroundColor =
                    [UIColor colorWithPatternImage:[FFPatternGenerator createHistoryMoveOverlayPatternForStep:hintIndex]];
            tileView.layer.zPosition = 1000;
            [self.hintTiles addObject:tileView];
            [self addSubview:tileView];
        }
        hintIndex++;
    }
}

- (void)removeAllHintTiles {
    for (UIView *hintTile in self.hintTiles) {
        [hintTile removeFromSuperview];
    }
    [self.hintTiles removeAllObjects];
}

/**
* Checks, whether the boardView shows the right count of tiles. Will update the view if not.
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

    // set right type to tiles
    for (FFTileViewMultiStated *view in self.tileViews) view.tileType = board.BoardType;

    // reposition tiles
    _tileSize = self.bounds.size.width / nuBoardSize;

    for (NSUInteger y = 0; y < nuBoardSize; y++){
        for (NSUInteger x = 0; x < nuBoardSize; x++){
            UIView <FFTileView> *tileView = [self getTileAtX:x andY:y];
            [tileView positionAt:CGRectMake(x*_tileSize, y*_tileSize, _tileSize, _tileSize)];
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
    _enableAudio = NO;

    self.introBoard = [[FFBoard alloc] initWithSize:6];
    [self.introBoard shuffle];

    [self removeAllHintTiles];

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

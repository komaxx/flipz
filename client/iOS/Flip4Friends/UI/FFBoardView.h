//
//  FFBoardView.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFCoord.h"

@class FFGame;
@class FFTile;
@class FFBoard;


@protocol FFTileView <NSObject>
- (BOOL)updateFromTile:(FFTile *)tile;
- (void)removeYourself;
- (void)positionAt:(CGRect)rect;
@end


/**
* This is the basic class that manages the Board, i.e. it knows all the
* the individual flip tiles and controls them.
*/
@interface FFBoardView : UIView

- (void)didAppear;

/**
* To be called whenever the game changes. The boardView will itself listen for changes
* to the game that was last given with this call (and only to that one).
*/
- (void)setActiveGame:(FFGame *)game;

- (void)didDisappear;

- (CGFloat)computeTileSize;

/**
* Should only be called during creation of a new challenge, NEVER for
 * a running game!
*/
- (void)updateTilesFromBoard:(FFBoard *)board;

- (NSInteger)boardSize;

- (CGPoint)computeTileCenterOfCoord:(FFCoord *)coord;
@end

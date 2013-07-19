//
//  FFBoardView.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFGame;

/**
* This is the basic class that manages the Board, i.e. it knows all the
* the individual flip tiles and controls them.
*/
@interface FFBoardView : UIView

- (void)didAppear;

/**
* To be called whenever the game changes. The board will itself listen for changes
* to the game that was last given with this call (and only to that one).
*/
- (void)updateWithGame:(FFGame *)game;

- (void)didDisappear;

- (CGFloat)computeTileSize;

- (NSInteger)boardSize;
@end

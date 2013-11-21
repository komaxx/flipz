//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/20/13.
//


#import <UIKit/UIKit.h>

@class FFBoardView;
@class FFGame;


@interface FFScoreRowsView : UIView
@property(nonatomic, weak) FFBoardView *boardView;

- (void)didAppear;

- (void)didDisappear;

- (void)setActiveGame:(FFGame *)game;
@end
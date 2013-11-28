//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/27/13.
//


#import <UIKit/UIKit.h>

@class FFGame;


@interface FFRestMovesView : UIView

- (void)didAppear;

- (void)didDisappear;

- (void)setActiveGame:(FFGame *)game;

@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/14/13.
//


#import <UIKit/UIKit.h>

@interface FFTileView : UIView

- (void)updateFromTile:(FFTile *)tile;

- (void)removeYourself;

- (void)positionAt:(CGRect)rect;
@end
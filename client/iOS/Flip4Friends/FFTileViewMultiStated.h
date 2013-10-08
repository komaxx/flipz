//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/14/13.
//


#import <UIKit/UIKit.h>
#import "FFTile.h"
#import "FFBoard.h"

@interface FFTileViewMultiStated : UIView <FFTileView>

@property (nonatomic) FFBoardType tileType;

@property (nonatomic) CGFloat turnSpeed;

@end
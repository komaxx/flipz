//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/30/13.
//


#import <UIKit/UIKit.h>
#import "FFPattern.h"


typedef enum {
    kFFPatternViewStateNormal,
    kFFPatternViewStateActive,
    kFFPatternViewStateAlreadyPlayed,
} FFPatternViewState;

@interface FFPatternView : UIButton

@property (strong, nonatomic) FFPattern* pattern;
@property (nonatomic) FFPatternViewState viewState;

- (void)removeYourself;
- (void)positionAtX:(CGFloat)x andY:(CGFloat)y;

@end
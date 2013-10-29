//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/1/13.
//


#import <Foundation/Foundation.h>

@class FFGameViewController;
@class FFPattern;

@protocol FFPatternsViewControlDelegate
    - (void)cancelMoveWithPattern:(FFPattern*)pattern;
    - (void)setPatternSelectedForMove:(FFPattern*)pattern fromView:(UIView *)view;
@end


/**
* Responsible for displaying the currently available patterns
*/
@interface FFPatternsViewControl : NSObject

@property (copy, nonatomic) NSString *activeGameId;
@property (weak, nonatomic) id<FFPatternsViewControlDelegate> delegate;

@property(nonatomic) BOOL secondPlayer;

- (id)initWithScrollView:(UIScrollView *)scrollView;

- (void)didAppear;
- (void)didDisappear;

- (void)cancelMove;

- (CGPoint)computeCenterOfPatternViewForId:(NSString *)string;

- (UIScrollView *)scrollView;

- (void)activatePatternWithId:(NSString *)patternId;

@end
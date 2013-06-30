//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/1/13.
//


#import <Foundation/Foundation.h>

/**
* Responsible for displaying the currently available patterns
*/
@interface FFPatternsViewControl : NSObject

@property (strong, nonatomic) UIScrollView *scrollView;


- (id)initWithScrollView:(UIScrollView *)scrollView;


- (void)didAppear;

- (void)didDisappear;
@end
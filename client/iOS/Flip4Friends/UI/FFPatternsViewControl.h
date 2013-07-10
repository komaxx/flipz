//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/1/13.
//


#import <Foundation/Foundation.h>

/**
* Responsible for displaying the currently available patterns
*/
@interface FFPatternsViewControl : NSObject
@property (copy, nonatomic) NSString *activeGameId;

- (id)initWithScrollView:(UIScrollView *)scrollView;

- (void)didAppear;
- (void)didDisappear;


@end
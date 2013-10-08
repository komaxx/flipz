//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 8/20/13.
//


#import <UIKit/UIKit.h>

@class FFMenuViewController;

@interface FFChallengeSidebar : UIView

@property(nonatomic, weak) FFMenuViewController *delegate;

-(void) didAppear;
-(void) didDisappear;

- (void)setActiveGameWithId:(NSString *)id;
@end
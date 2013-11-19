//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/18/13.
//

#import <UIKit/UIKit.h>

@class FFMenuViewController;

@interface FFHotSeatSidebar : UIView

@property (nonatomic, weak) FFMenuViewController *delegate;

-(void) didAppear;
-(void) didDisappear;

- (void)setActiveGameWithId:(NSString *)id;
@end




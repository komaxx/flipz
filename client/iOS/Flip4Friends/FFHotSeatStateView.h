//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/18/13.
//


#import <UIKit/UIKit.h>


@interface FFHotSeatStateView : UIControl

@property(nonatomic, copy) NSString *activeGameId;

- (void)didAppear;
- (void)didDisappear;

@end
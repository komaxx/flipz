//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/18/13.
//


#import "FFHotSeatSidebar.h"
#import "FFMenuViewController.h"
#import "FFHotSeatStateView.h"

@interface FFHotSeatSidebar()
@property (weak, nonatomic) FFHotSeatStateView* winningView;
@end


@implementation FFHotSeatSidebar


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [(UIButton *) [self viewWithTag:451] addTarget:self action:@selector(pauseTapped) forControlEvents:UIControlEventTouchUpInside];
        self.winningView = (FFHotSeatStateView *) [self viewWithTag:452];
    }

    return self;
}

- (void)didAppear {
    [self.winningView didAppear];
}

- (void)setActiveGameWithId:(NSString *)id {
    self.winningView.activeGameId = id;
}

- (void)didDisappear {
    [self.winningView didDisappear];
}

- (void)pauseTapped {
    [self.delegate pauseTapped];
}


@end
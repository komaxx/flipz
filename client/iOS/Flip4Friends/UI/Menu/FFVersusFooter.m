//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 8/20/13.
//


#import "FFVersusFooter.h"
#import "FFMenuViewController.h"


@implementation FFVersusFooter {
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [(UIButton *) [self viewWithTag:411] addTarget:self action:@selector(pauseTapped) forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

- (void)pauseTapped {
    [self.delegate pauseTapped];
}

@end
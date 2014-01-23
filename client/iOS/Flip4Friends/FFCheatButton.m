//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 12/30/13.
//


#import "FFCheatButton.h"


#define TRIGGER_TOUCHES 5

@interface FFCheatButton ()
@property (nonatomic, weak) id target;
@property (nonatomic) SEL action;
@end

@implementation FFCheatButton {
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        tapGestureRecognizer.numberOfTapsRequired = TRIGGER_TOUCHES;

        [self addGestureRecognizer:tapGestureRecognizer];
    }

    return self;
}

- (void)tapped {
    id o = self.target;
    if (o && [o respondsToSelector:self.action]){
        [o performSelector:self.action];
    }
}

- (void)addTarget:(id)target andAction:(SEL)action {
    self.target = target;
    self.action = action;
}


@end
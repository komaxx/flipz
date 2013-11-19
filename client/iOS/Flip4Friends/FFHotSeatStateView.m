//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/18/13.
//


#import "FFHotSeatStateView.h"
#import "FFGame.h"


@implementation FFHotSeatStateView {

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }

    return self;
}

- (void)setActiveGameId:(NSString *)activeGameId {
    _activeGameId = [activeGameId mutableCopy];
    // TODO
}

- (void)didAppear {
    [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(gameChanged) name:kFFNotificationGameChanged object:nil];
}

- (void)didDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)gameChanged {
    // TODO
}

@end
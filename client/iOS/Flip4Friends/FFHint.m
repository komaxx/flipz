//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 1/24/14.
//


#import "FFHint.h"


@implementation FFHint {

}

- (id)initWithCoords:(NSMutableArray *)coords {
    self = [super init];

    if (self){
        self.coords = coords;
        self.active = NO;
    }

    return self;
}
@end
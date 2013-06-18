//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import "FFMove.h"
#import "FFPattern.h"
#import "FFCoord.h"


@interface FFMove ()
@property (strong, nonatomic, readwrite) FFPattern *Pattern;
@property (strong, nonatomic, readwrite) FFCoord *Position;
@property (nonatomic, readwrite) FFOrientation Orientation;

@end

@implementation FFMove {

}

- (id)initWithPattern:(FFPattern *)pattern atPosition:(FFCoord *)position andOrientation:(FFOrientation)orientation {
    self = [super init];

    if (self){
        self.Pattern = pattern;
        self.Position = position;
        self.Orientation = orientation;
    }

    return self;
}

- (BOOL)isLegalOnBoardWithSize:(NSUInteger)boardSize {
    FFPattern *rotatedPattern = [self.Pattern copyForOrientation:self.Orientation];

    return     self.Position.x + rotatedPattern.SizeX <= boardSize
            && self.Position.y + rotatedPattern.SizeY <= boardSize;
}

- (NSArray*)buildCoordsToFlip {
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:self.Pattern.Coords.count];

    FFPattern *rotatedPattern = [self.Pattern copyForOrientation:self.Orientation];
    for (FFCoord *coord in rotatedPattern.Coords) {
        [ret addObject:[coord copyTranslatedBy:self.Position]];
    }
    return ret;
}
@end
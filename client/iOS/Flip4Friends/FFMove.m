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
    BOOL _moveSumComputed;
    NSInteger _moveSum;
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

- (NSArray*)buildToFlipCoords {
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:self.Pattern.Coords.count];

    FFPattern *rotatedPattern = [self.Pattern copyForOrientation:self.Orientation];
    for (FFCoord *coord in rotatedPattern.Coords) {
        [ret addObject:[coord copyTranslatedBy:self.Position]];
    }
    return ret;
}

/**
* Computes the specific hash sum of the move - disregarding the actual effect
* as the move is applied to a board.
*/
- (NSInteger)moveSum {
    if (!_moveSumComputed){
        _moveSum = 0;

        NSArray *flipCoords = [self buildToFlipCoords];

        for (FFCoord* coord in flipCoords) {
            _moveSum += (coord.x + self.Position.x) * 64;     // WARNING: Assumption here is that boards are never bigger than 64 tiles (reasonable now...)
            _moveSum += coord.y + self.Position.y;
        }

        _moveSumComputed = YES;
    }

    return _moveSum;
}

@end
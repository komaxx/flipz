//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import "FFPattern.h"


@interface FFPattern ()

@property(strong, nonatomic, readwrite) NSArray *Coords;
@property(nonatomic, readwrite) NSUInteger SizeX;
@property(nonatomic, readwrite) NSUInteger SizeY;

@property (nonatomic) BOOL rotating;

@property (nonatomic) int orientations;

@end


@implementation FFPattern
@synthesize Id = _Id;


- (id)initWithCoords:(NSArray *)coords andAllowRotation:(BOOL)rotating {
    self = [super init];

    if (self){
        self.Coords = coords;
        [self trim];
        [self makeId];
        _rotating = rotating;
    }

    return self;
}


- (id)initAsMirroredCloneFrom:(FFPattern *)pattern {
    self = [super init];

    if (self){
        self.Coords = [[NSMutableArray alloc] initWithCapacity:pattern.Coords.count];
        for (FFCoord *coord in pattern.Coords) {
            [(NSMutableArray *) self.Coords addObject:[[FFCoord alloc] initWithX:(ushort)(pattern.SizeX - coord.x - 1) andY:coord.y]];
        }
        self.rotating = pattern.rotating;
        [self trim];
        [self makeId];
    }

    return self;
}


- (id)initWithRandomCoords:(NSUInteger)count andMaxDistance:(NSUInteger)maxDistance andAllowRotating:(BOOL)rotating{
    self = [super init];
    if (self){
        if (count < 1) count = 1;
        self.Coords = [[NSMutableArray alloc] initWithCapacity:count];
        self.rotating = rotating;

        int lastCoordPos = -1;
        for (int i = 0; i < count; i++){
            int mod = (maxDistance*maxDistance - lastCoordPos - (count-i) - 1);
            int proceed = mod>0 ? ( arc4random() % mod + 1) : 1;
            lastCoordPos += proceed;
            [(NSMutableArray *)self.Coords
                    addObject:[[FFCoord alloc] initWithX:(ushort) (lastCoordPos % maxDistance) andY:(ushort) (lastCoordPos / maxDistance)]];
        }
        [self trim];
        [self makeId];
    }
    return self;
}

/**
* Moves the pattern up/left if the first rows/columns are unused.
* Re-computes the Size.
*/
- (void)trim {
    ushort minX = 999;
    ushort minY = 999;
    for (FFCoord *coord in self.Coords) {
        if (coord.x < minX) minX = coord.x;
        if (coord.y < minY) minY = coord.y;
    }

    for (FFCoord *coord in self.Coords) {
        [coord moveByX:(-minX) andY:(-minY)];
    }

    self.SizeX = 0;
    self.SizeY = 0;
    for (FFCoord *coord in self.Coords) {
        if (coord.x > self.SizeX) self.SizeX = coord.x;
        if (coord.y > self.SizeY) self.SizeY = coord.y;
    }
    self.SizeX += 1;
    self.SizeY += 1;
}

- (void)makeId {
    static NSInteger stId = 1234;
    stId++;
    self.Id = [NSString stringWithFormat:@"p%i", stId];
}

- (FFPattern *)copyForOrientation:(FFOrientation)orientation {
    NSMutableArray *rotCoords = [[NSMutableArray alloc] initWithCapacity:self.Coords.count];

    switch (orientation) {
        case kFFOrientation_90_degrees:
            for (FFCoord *coord in self.Coords){
                [rotCoords addObject:[[FFCoord alloc] initWithX:(ushort) (self.SizeY - coord.y - 1)
                                                           andY:coord.x]];
            }
            break;
        case kFFOrientation_180_degrees:
            for (FFCoord *coord in self.Coords){
                [rotCoords addObject:[[FFCoord alloc] initWithX:(ushort) (self.SizeX - coord.x - 1)
                                                           andY:(ushort) (self.SizeY - coord.y - 1)]];
            }
            break;
        case kFFOrientation_270degrees:
            for (FFCoord *coord in self.Coords){
                [rotCoords addObject:[[FFCoord alloc] initWithX:coord.y
                                                           andY:(ushort) (self.SizeX - coord.x - 1)]];
            }
            break;
        case kFFOrientation_0_degrees:
        default:
            // just copy it
            for (FFCoord *coord in self.Coords){
                [rotCoords addObject:[[FFCoord alloc] initWithX:coord.x andY:coord.y]];
            }
            break;
    }

    return [[FFPattern alloc] initWithCoords:rotCoords andAllowRotation:self.rotating];
}

- (BOOL)isEqualPattern:(id)other {
    if (other == self) return YES;
    if (!other || ![[other class] isEqual:[self class]]) return NO;

    FFPattern *o = other;
    if (self.Coords.count != o.Coords.count || self.SizeX!=o.SizeX || self.SizeY!=o.SizeY) return NO;

    for (FFCoord *sCo in self.Coords) {
        BOOL found = NO;
        for (FFCoord *oCo in o.Coords) {
            if (sCo.x == oCo.x && sCo.y == oCo.y){
                found = YES;
                break;
            }
        }
        if (!found) return NO;
    }

    return YES;
}


- (int)differingOrientations {
    if (self.orientations == 0){
        if (!self.rotating){
            self.orientations = 1;
        } else {
            FFPattern *rotPattern1 = [self copyForOrientation:kFFOrientation_90_degrees];
            if ([rotPattern1 isEqualPattern:self]){
                self.orientations = 1;
            } else {
                FFPattern *rotPattern2 = [self copyForOrientation:kFFOrientation_180_degrees];
                if ([rotPattern2 isEqualPattern:self]){
                    self.orientations = 2;
                } else {
                    self.orientations = 4;
                }
            }
        }
    }
    return self.orientations;
}
@end
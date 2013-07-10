//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import "FFPattern.h"
#import "FFCoord.h"
#import "FFMove.h"


@interface FFPattern ()

@property(strong, nonatomic, readwrite) NSArray *Coords;
@property(nonatomic, readwrite) NSUInteger SizeX;
@property(nonatomic, readwrite) NSUInteger SizeY;
@end


@implementation FFPattern
@synthesize Id = _Id;


- (id)initWithCoords:(NSArray *)coords {
    self = [super init];

    if (self){
        self.Coords = coords;
        [self trim];

        // TODO add ID!
    }

    return self;
}

- (id)initWithRandomCoords:(NSUInteger)count andMaxDistance:(NSUInteger)maxDistance{
    self = [super init];
    if (self){
        if (count < 1) count = 1;
        self.Coords = [[NSMutableArray alloc] initWithCapacity:count];

        NSUInteger patternArea = (maxDistance+1) * (maxDistance+1);

        if (count > patternArea){
            NSLog(@"ERROR: Random Pattern can not contain more coords than it's max size! Fallback to smaller maxCount.");
            count = patternArea;
        }

        // TODO CAVEAT: This might take quite long the more the maxDistance square is filled
        // Solution: If more than half of the square is filled, remove coords instead of filling.
        // Also: Bit-Mask checks could speed this up enormously.
        NSUInteger setCount = 0;
        while (setCount < count){
            FFCoord *toAdd = [[FFCoord alloc] initWithX:(ushort) (rand()%maxDistance) andY:(ushort) (rand()%maxDistance)];

            BOOL alreadyPartOfThePattern = NO;
            for (NSUInteger i = 0; i < setCount; i++){
                if ([[self.Coords objectAtIndex:i] isEqual:toAdd]){
                    alreadyPartOfThePattern = YES;
                    break;
                }
            }

            if (!alreadyPartOfThePattern){
                [(NSMutableArray *) self.Coords addObject:toAdd];
                setCount++;
            }
        }

        [self trim];

        static NSInteger stId = 0;
        stId++;
        self.Id = [NSString stringWithFormat:@"%i", stId];
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

- (FFPattern *)copyForOrientation:(FFOrientation)orientation {
    NSArray *rotCoords = [[NSArray alloc] initWithArray:self.Coords];

    // TODO implement the rotation!

    return [[FFPattern alloc] initWithCoords:rotCoords];
}
@end
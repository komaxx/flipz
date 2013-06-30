//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import <Foundation/Foundation.h>
#import "FFMove.h"

/**
* A FFPattern describes a row of (unsigned int) coordinates in its own coordinate
* system with the origin analogous to the graphics system in the upper left corner.
*
* A pattern together with a position and a rotation makes a "FFMove"
*/
@interface FFPattern : NSObject

/**
* An array of FFCoord objects
*/
@property (strong, nonatomic, readonly) NSArray *Coords;
@property (nonatomic) NSUInteger SizeX;
@property (nonatomic) NSUInteger SizeY;

@property(nonatomic, copy) NSString *Id;

- (id)initWithRandomCoords:(NSUInteger)count andMaxDistance:(NSUInteger)maxDistance;

- (FFPattern *)copyForOrientation:(FFOrientation)orientation;

- (id)initWithCoords:(NSArray *)array;
@end
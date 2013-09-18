//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import <Foundation/Foundation.h>
#import "FFCoord.h"

@class FFPattern;


typedef enum {
    kFFOrientation_0_degrees = 0,
    kFFOrientation_90_degrees = 1,
    kFFOrientation_180_degrees = 2,
    kFFOrientation_270degrees = 3
} FFOrientation;

/**
* Something a player does. Consists of a pattern, a position and an orientation.
*/
@interface FFMove : NSObject

@property (strong, nonatomic, readonly) FFPattern* Pattern;
@property (strong, nonatomic, readonly) FFCoord* Position;
@property (strong, nonatomic) NSArray* FlippedCoords;
@property (nonatomic, readonly) FFOrientation Orientation;

- (id)initWithPattern:(FFPattern *)pattern atPosition:(FFCoord *)position andOrientation:(FFOrientation)orientation;

- (BOOL)isLegalOnBoardWithSize:(NSUInteger)i;

/**
 * Computes all coords that are to be flipped by this move. No guarantees about the order
 * of these coords.
 */
- (NSArray*)buildToFlipCoords;
@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import <Foundation/Foundation.h>
#import "FFCoord.h"

@class FFPattern;


typedef enum {
    kFFOrientation_0_degrees, kFFOrientation_90_degrees, kFFOrientation_180_degrees, kFFOrientation_270degrees
} FFOrientation;

/**
* Something a player does. Consists of a pattern, a position and an orientation.
*/
@interface FFMove : NSObject

/**
* All moves in a game are sorted along this number. The higher the number, the later in the game
* was the move executed.
*/
@property (nonatomic) NSUInteger ordinal;

@property (strong, nonatomic, readonly) FFPattern* Pattern;
@property (strong, nonatomic, readonly) FFCoord* Position;
@property (nonatomic, readonly) FFOrientation Orientation;

- (id)initWithPattern:(FFPattern *)pattern atPosition:(FFCoord *)position andOrientation:(FFOrientation)orientation;

- (BOOL)isLegalOnBoardWithSize:(NSUInteger)i;

/**
 * Computes all coords that are to be flipped by this move. No guarantees about the order
 * of these coords.
 */
- (NSArray*)buildCoordsToFlip;
@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 1/24/14.
//


#import <Foundation/Foundation.h>


@interface FFHint : NSObject

@property (nonatomic) BOOL active;
@property (strong, nonatomic) NSArray *coords;

- (id)initWithCoords:(NSMutableArray *)array;
@end
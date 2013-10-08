//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 10/9/13.
//


#import <Foundation/Foundation.h>


@interface FFStorageUtil : NSObject

+ (NSUInteger) firstUnsolvedChallengeIndex;
+ (void) setFirstUnsolvedChallengeIndex:(NSUInteger)nuIndex;

@end
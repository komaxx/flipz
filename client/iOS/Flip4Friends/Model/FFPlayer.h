//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import <Foundation/Foundation.h>


@interface FFPlayer : NSObject

@property (strong, nonatomic) NSString *id;

@property (nonatomic) BOOL local;
@property (strong, nonatomic) NSString *name;

@property (strong, nonatomic) NSArray *playablePatterns;
@property (strong, nonatomic) NSDictionary *alreadyPlayedPatternIds;

@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/17/13.
//


#import <Foundation/Foundation.h>

@class FFMove;


@interface FFPlayer : NSObject

@property (strong, nonatomic) NSString *id;

@property (nonatomic) BOOL local;
@property (strong, nonatomic) NSString *name;

/**
* Contains all patterns, even if they have been already played. Check in doneMoves
* whether a move was already executed or not.
*/
@property (strong, nonatomic) NSArray *playablePatterns;
@property (strong, nonatomic) NSDictionary *doneMoves;

- (void)setDoneMove:(FFMove *)move;

- (void)undoMove:(FFMove *)move;

- (void)resetWithPatterns:(NSArray *)array;

- (BOOL)allPatternsPlayed;

- (void)clearDoneMoves;
@end
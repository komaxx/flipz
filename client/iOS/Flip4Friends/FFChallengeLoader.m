//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 9/18/13.
//


#import "FFChallengeLoader.h"
#import "FFGame.h"
#import "FFPattern.h"


@implementation FFChallengeLoader {

}

static NSArray *levelDefinitions;
static NSUInteger creationId;

- (id)init {
    self = [super init];
    if (self) {
        [self loadLevelDefinitionsIfNecessary];
    }

    return self;
}

- (void)loadLevelDefinitionsIfNecessary {
    if (levelDefinitions) return;

    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"challenges" ofType:@"txt"]];
    levelDefinitions = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    if (error){
        NSLog(@"Error when loading challenge definitions: %@", error);
    }
}

- (FFGame *)loadLevel:(NSUInteger)level __unused {
    NSDictionary *definition = [levelDefinitions objectAtIndex:level];

    FFGame *challenge = [[FFGame alloc] initWithId:[NSString stringWithFormat:@"challenge%i_%i", level, creationId++]
                                              Type:kFFGameTypeSingleChallenge
                                      andBoardSize:[(NSNumber*)[definition objectForKey:@"boardsize"] intValue]];
    challenge.ruleAllowPatternRotation = [(NSNumber *)[definition objectForKey:@"rotate_patterns"] boolValue];
    challenge.Board.lockMoves = [(NSNumber *)[definition objectForKey:@"lockmoves"] intValue];
    challenge.Board.BoardType = (FFBoardType) [(NSNumber *)[definition objectForKey:@"boardtype"] intValue];

    // //////////////////////////////////////////////////////////////////////////////////////////
    // load board
    NSArray *colors = [definition objectForKey:@"boardcolors"];
    for (NSUInteger i = 0; i < colors.count; i++){
        [challenge.Board colorTile:i withColor:(NSNumber *)[colors objectAtIndex:i]];
    }

    // //////////////////////////////////////////////////////////////////////////////////////////
    // load patterns
    NSArray *patternDefs = [definition objectForKey:@"patterns"];
    NSMutableArray *patterns = [[NSMutableArray alloc] initWithCapacity:patternDefs.count];

    for (NSArray *patternDef in patternDefs) {
        NSMutableArray *coords = [[NSMutableArray alloc] initWithCapacity:patternDef.count];

        for (NSArray *coord in patternDef) {
            [coords addObject:
                    [[FFCoord alloc] initWithX:(ushort) [(NSNumber *) [coord objectAtIndex:0] integerValue]
                                          andY:(ushort) [(NSNumber *) [coord objectAtIndex:1] integerValue]]
            ];
        }

        [patterns addObject:[[FFPattern alloc] initWithCoords:coords]];
    }
    [challenge.player1 resetWithPatterns:patterns];

    return challenge;
}

- (NSUInteger)numberOfChallenges {
    return levelDefinitions.count;
}
@end
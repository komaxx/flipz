//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 9/18/13.
//


#import "FFPuzzleLoader.h"
#import "FFGame.h"
#import "FFPattern.h"
#import "FFUtil.h"


@implementation FFPuzzleLoader {

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

+ (NSString *)encodeGameAsJson:(FFGame*)game {
     NSMutableDictionary *toJson = [[NSMutableDictionary alloc] initWithCapacity:10];

    [toJson setObject:[NSNumber numberWithInt:game.Board.lockMoves] forKey:@"lockmoves"];
    [toJson setObject:[NSNumber numberWithInt:game.Board.BoardType] forKey:@"boardtype"];
    [toJson setObject:[NSNumber numberWithInt:game.Board.BoardSize] forKey:@"boardsize"];


    NSMutableArray *colors = [[NSMutableArray alloc] initWithCapacity:game.Board.BoardSize*game.Board.BoardSize];
    [game.Board addColorsToArray:colors];
    [toJson setObject:colors forKey:@"boardcolors"];

    // and: patterns
    NSMutableArray *patterns = [[NSMutableArray alloc] initWithCapacity:game.player1.playablePatterns.count];
    [FFUtil shuffle:patterns];
    for (FFPattern *pat in game.player1.playablePatterns) {
        NSMutableDictionary *patDic = [[NSMutableDictionary alloc] initWithCapacity:2];
        [patDic setObject:[NSNumber numberWithBool:(pat.differingOrientations>1)] forKey:@"rotating"];

        NSMutableArray *coords = [[NSMutableArray alloc] initWithCapacity:pat.Coords.count];
        for (FFCoord *coord in pat.Coords) {
            [coords addObject:@[[NSNumber numberWithInt:coord.x], [NSNumber numberWithInt:coord.y]]];
        }
        [patDic setObject:coords forKey:@"coords"];

        [patterns addObject:patDic];
    }

    [toJson setObject:patterns forKey:@"patterns"];

    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:toJson options:0 error:&error];
    if (error){
        NSLog(@"ERROR when writing game: %@", error);
    }
    NSString* jsonString =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (FFGame *)loadLevel:(NSUInteger)level {
    NSDictionary *definition = [levelDefinitions objectAtIndex:level];

    FFGame *challenge = [[FFGame alloc] initWithId:[NSString stringWithFormat:@"challenge%i_%i", level, creationId++]
                                              Type:kFFGameTypeSingleChallenge
                                      andBoardSize:[(NSNumber*)[definition objectForKey:@"boardsize"] intValue]];
    challenge.Board.lockMoves = [(NSNumber *)[definition objectForKey:@"lockmoves"] intValue];
    challenge.Board.BoardType = (FFBoardType) [(NSNumber *)[definition objectForKey:@"boardtype"] intValue];

    challenge.tutorialId = [definition objectForKey:@"tutorial"];

    // //////////////////////////////////////////////////////////////////////////////////////////
    // load boardView
    NSArray *colors = [definition objectForKey:@"boardcolors"];
    for (NSUInteger i = 0; i < colors.count; i++){
        [challenge.Board colorTile:i withColor:(NSNumber *)[colors objectAtIndex:i]];
    }

    // //////////////////////////////////////////////////////////////////////////////////////////
    // load patterns
    NSArray *patternDefs = [definition objectForKey:@"patterns"];
    NSMutableArray *patterns = [[NSMutableArray alloc] initWithCapacity:patternDefs.count];

    for (NSDictionary *patternDef in patternDefs) {
        NSArray *coordDefs = [patternDef objectForKey:@"coords"];
        NSMutableArray *coords = [[NSMutableArray alloc] initWithCapacity:coordDefs.count];

        for (NSArray *coord in coordDefs) {
            [coords addObject:
                    [[FFCoord alloc] initWithX:(ushort) [(NSNumber *) [coord objectAtIndex:0] integerValue]
                                          andY:(ushort) [(NSNumber *) [coord objectAtIndex:1] integerValue]]
            ];
        }

        BOOL rotating = [(NSNumber *)[patternDef objectForKey:@"rotating"] boolValue];

        FFPattern *loadedPattern = [[FFPattern alloc] initWithCoords:coords andAllowRotation:rotating];
        [patterns addObject:loadedPattern];
    }
    [challenge.player1 resetWithPatterns:patterns];

    return challenge;
}

- (NSUInteger)numberOfChallenges {
    return levelDefinitions.count;
}
@end
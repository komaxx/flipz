//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/1/13.
//


#import "FFPatternsViewControl.h"
#import "FFGame.h"
#import "FFGamesCore.h"
#import "FFPatternView.h"


@interface FFPatternsViewControl ()

@property (copy, nonatomic) NSString *shownActivePlayerId;
@property (copy, nonatomic) NSString *activeGameId;

@property (strong, nonatomic) NSMutableDictionary *patternViewsById;

@property (strong, nonatomic) NSMutableDictionary *tmpRemovedCollector;

@end

@implementation FFPatternsViewControl {
}

- (id)initWithScrollView:(UIScrollView *)scrollView {
    self = [super init];
    if (self) {
        _scrollView = scrollView;

        self.patternViewsById = [[NSMutableDictionary alloc] initWithCapacity:20];

        self.tmpRemovedCollector = [[NSMutableDictionary alloc] initWithCapacity:20];
    }

    return self;
}

- (void)didAppear {
    [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(gameChanged:) name:kFFNotificationGameChanged object:nil];
}
- (void)didDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setActiveGameId:(NSString *)activeGameId {
    if (_activeGameId != activeGameId) {
        _activeGameId = activeGameId;
        self.shownActivePlayerId = nil;
        [self checkUpdateForGameId:activeGameId];
    }
}

- (void)gameChanged:(NSNotification *)notification {
    NSString *changedGameID = [notification.userInfo objectForKey:kFFNotificationGameChanged_gameId];
    [self checkUpdateForGameId:changedGameID];
}

- (void)checkUpdateForGameId:(NSString *)changedGameID {
    if (![changedGameID isEqualToString:self.activeGameId]) {
        // ignore. Update for the wrong game (not the active one).
        return;
    }

    FFGame *game = [[FFGamesCore instance] gameWithId:changedGameID];
    if (![game.activePlayer.id isEqualToString:self.shownActivePlayerId]){
        [self replacePatternsForPlayer:game.activePlayer];
    }
}

- (void)replacePatternsForPlayer:(FFPlayer *)player {
    if (![player.id isEqualToString:self.shownActivePlayerId]){
        // remove ALL
        for (NSString *key in self.patternViewsById) {
            FFPatternView* view = [self.patternViewsById objectForKey:key];
            [view removeYourself];
        }
        [self.patternViewsById removeAllObjects];
        self.shownActivePlayerId = player.id;
    }

    // first: build sorted list of patterns
    NSMutableArray *patterns = [[NSMutableArray alloc] initWithArray:player.playablePatterns];
    [self sortPatterns:patterns];

    // collect no longer seen patterns in here
    [self.tmpRemovedCollector removeAllObjects];
    [self.tmpRemovedCollector addEntriesFromDictionary:self.patternViewsById];

    
    for (FFPattern *pattern in patterns) {
        NSString *patternId = pattern.Id;
        [self.tmpRemovedCollector removeObjectForKey:patternId];

        FFPatternView *view = [self.patternViewsById objectForKey:patternId];
        if (!view){
            FFPatternView *view = [[FFPatternView alloc] initWithFrame:CGRectMake(-100, 5,
                    PATTERN_VIEW_SIZE, PATTERN_VIEW_SIZE)];
            view.pattern = pattern;
            [self.patternViewsById setObject:view forKey:patternId];
        }

        [view positionAtX: andY:];
    }

    // remove all no longer used patterns
    for (NSString *key in self.tmpRemovedCollector) {
        FFPatternView* view = [self.tmpRemovedCollector objectForKey:key];
        [view removeYourself];
        [self.patternViewsById removeObjectForKey:key];
    }
    [self.tmpRemovedCollector removeAllObjects];
}

- (void)sortPatterns:(NSMutableArray *)patterns {
    [patterns sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSUInteger o1 = ((FFPattern *)obj1).Coords.count;
        NSUInteger o2 = ((FFPattern *)obj2).Coords.count;

        return o1>o2 ? NSOrderedDescending :
                (o2>o1 ? NSOrderedAscending : NSOrderedSame);
    }];
}

@end
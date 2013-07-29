//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/1/13.
//


#import "FFPatternsViewControl.h"
#import "FFGame.h"
#import "FFGamesCore.h"
#import "FFPatternView.h"
#import "FFGameViewController.h"

#define PATTERN_VIEW_SIZE 54

@interface FFPatternsViewControl ()

@property (weak, nonatomic) UIScrollView *scrollView;
@property (copy, nonatomic) NSString *shownActivePlayerId;

@property (strong, nonatomic) NSMutableDictionary *patternViewsById;
@property (strong, nonatomic) NSMutableDictionary *tmpRemovedCollector;

@property (weak, nonatomic) FFPatternView *nowActivePatternView;

@end

@implementation FFPatternsViewControl {
}
@synthesize delegate = _delegate;


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

- (void)cancelMove {
    [self cancelSelection];
}

- (void)setActiveGameId:(NSString *)activeGameId {
    _activeGameId = activeGameId;
    self.shownActivePlayerId = nil;

    FFGame *game = [[FFGamesCore instance] gameWithId:activeGameId];
    [self replacePatternsForPlayer:game.activePlayer];
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
    } else {
        [self updatePatternStatesWithPlayer:game.activePlayer];
    }
}

- (void)updatePatternStatesWithPlayer:(FFPlayer *)player {
    for (NSString *key in self.patternViewsById) {
        FFPatternView *view = (FFPatternView *) [self.patternViewsById objectForKey:key];
        if (view == self.nowActivePatternView) continue;
        view.viewState = [player.doneMoves objectForKey:key]== nil ?
                kFFPatternViewStateNormal : kFFPatternViewStateAlreadyPlayed;
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

    NSInteger xCount = (NSInteger) (self.scrollView.bounds.size.width / PATTERN_VIEW_SIZE);
    CGFloat xPadding = (NSInteger)( (self.scrollView.bounds.size.width - (xCount*PATTERN_VIEW_SIZE)) / xCount );
    CGFloat yPadding = 5;

    CGFloat x = (NSInteger)(xPadding / 2.0);
    CGFloat y = 3;

    for (FFPattern *pattern in patterns) {
        NSString *patternId = pattern.Id;
        [self.tmpRemovedCollector removeObjectForKey:patternId];

        FFPatternView *view = [self.patternViewsById objectForKey:patternId];
        if (!view){
            view = [[FFPatternView alloc] initWithFrame:CGRectMake(-100, 5,
                    PATTERN_VIEW_SIZE, PATTERN_VIEW_SIZE)];
            view.pattern = pattern;
            [view addTarget:self action:@selector(patternTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:view];
            [self.patternViewsById setObject:view forKey:patternId];
        }

        [view positionAtX:x andY:y];

        x += (PATTERN_VIEW_SIZE + xPadding);
        if (x+PATTERN_VIEW_SIZE > self.scrollView.bounds.size.width){
            x = (NSInteger)(xPadding / 2.0);
            y += PATTERN_VIEW_SIZE + yPadding;
        }
    }

    // remove all no longer used patterns
    for (NSString *key in self.tmpRemovedCollector) {
        FFPatternView* view = [self.tmpRemovedCollector objectForKey:key];
        [view removeYourself];
        [self.patternViewsById removeObjectForKey:key];
    }
    [self.tmpRemovedCollector removeAllObjects];

    self.scrollView.contentSize = CGSizeMake(0, y + PATTERN_VIEW_SIZE);
}

- (void)patternTapped:(FFPatternView *)view {
    [self cancelSelection];

    if (self.nowActivePatternView == view){
        self.nowActivePatternView = nil;
        return;
    }

    self.nowActivePatternView = view;
    [view setViewState:kFFPatternViewStateActive];

    [self.delegate setPatternSelectedForMove:view.pattern fromView:view];
}

- (void)cancelSelection {
    FFPlayer *activePlayer = [[FFGamesCore instance] gameWithId:self.activeGameId].activePlayer;
    [self.nowActivePatternView setViewState:
            [activePlayer.doneMoves objectForKey:self.nowActivePatternView.pattern.Id] == nil ?
                    kFFPatternViewStateNormal : kFFPatternViewStateAlreadyPlayed];
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
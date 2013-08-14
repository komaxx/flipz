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

@property (strong, nonatomic) NSMutableDictionary *patternViewsById;
@property (strong, nonatomic) NSMutableDictionary *tmpRemovedCollector;

@property (weak, nonatomic) FFPatternView *nowActivePatternView;

@property (weak, nonatomic) NSString* lastShownPlayerId;

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

    if (self.secondPlayer) _scrollView.transform = CGAffineTransformMakeRotation((CGFloat) M_PI);
}
- (void)didDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)cancelMove {
    [self cancelSelection];
}

- (void)setActiveGameId:(NSString *)activeGameId {
    _activeGameId = activeGameId;
    [self replacePatternsForPlayer:[self shownPlayer]];
}

- (FFPlayer *)shownPlayer {
    FFGame *game = [[FFGamesCore instance] gameWithId:self.activeGameId];
    return self.secondPlayer ? game.player2 : game.player1;
}

- (void)gameChanged:(NSNotification *)notification {
    NSString *changedGameID = [notification.userInfo objectForKey:kFFNotificationGameChanged_gameId];
    if (![changedGameID isEqualToString:self.activeGameId]) {
        // ignore. Update for the wrong game (not the active one).
        return;
    }

    [self updatePatternStatesWithPlayer:[self shownPlayer]];
}

- (void)updatePatternStatesWithPlayer:(FFPlayer *)player {
    for (NSString *key in self.patternViewsById) {
        FFPatternView *view = (FFPatternView *) [self.patternViewsById objectForKey:key];
        if (view == self.nowActivePatternView) continue;
        view.viewState = [player.doneMoves objectForKey:key]== nil ?
                kFFPatternViewStateNormal : kFFPatternViewStateAlreadyPlayed;
    }
}

- (CGPoint)computeCenterOfPatternViewForId:(NSString *)patternId {
    return [(FFPatternView *) [self.patternViewsById objectForKey:patternId] center];
}

- (void)replacePatternsForPlayer:(FFPlayer *)player {
    if (![player.id isEqualToString:([self shownPlayer].id)]){
        // remove ALL
        for (NSString *key in self.patternViewsById) {
            FFPatternView* view = [self.patternViewsById objectForKey:key];
            [view removeYourself];
        }
        [self.patternViewsById removeAllObjects];
    }

    // first: build sorted list of patterns
    NSMutableArray *patterns = [[NSMutableArray alloc] initWithArray:player.playablePatterns];
    [self sortPatterns:patterns];

    // collect no longer seen patterns in here
    [self.tmpRemovedCollector removeAllObjects];
    [self.tmpRemovedCollector addEntriesFromDictionary:self.patternViewsById];

    NSInteger xCount = (NSInteger) (self.scrollView.bounds.size.width / PATTERN_VIEW_SIZE);
    CGFloat xPadding = (NSInteger)( (self.scrollView.bounds.size.width - (xCount*PATTERN_VIEW_SIZE)) / (xCount-1) );
    CGFloat yPadding = 5;

    CGFloat x = 0;//(NSInteger)(xPadding / 2.0);
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
            x = 0;//(NSInteger)(xPadding / 2.0);
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
    // allowed?
    FFGame *game = [[FFGamesCore instance] gameWithId:self.activeGameId] ;
    if (game.Type != kFFGameTypeSingleChallenge && [[self shownPlayer].doneMoves objectForKey:view.pattern.Id]){
        NSLog(@"This pattern was already played. Ignore.");
        return;
    }
    if (game.activePlayer==game.player1 && self.secondPlayer){
        NSLog(@"Not accepting tap - not this player's turn!");
        return;
    }

    if (self.nowActivePatternView == view){
        self.nowActivePatternView = nil;
        [self cancelSelection];
        [self.delegate cancelMoveWithPattern:self.nowActivePatternView.pattern];
        return;
    }

    [self cancelSelection];

    self.nowActivePatternView = view;
    [view setViewState:kFFPatternViewStateActive];

    [self.delegate setPatternSelectedForMove:view.pattern fromView:view];
}

- (void)cancelSelection {
    [self.nowActivePatternView setViewState:
            [[self shownPlayer].doneMoves objectForKey:self.nowActivePatternView.pattern.Id] == nil ?
                    kFFPatternViewStateNormal : kFFPatternViewStateAlreadyPlayed];
    self.nowActivePatternView = nil;
}

- (void)sortPatterns:(NSMutableArray *)patterns {
    [patterns sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSUInteger o1 = ((FFPattern *)obj1).Coords.count;
        NSUInteger o2 = ((FFPattern *)obj2).Coords.count;

        return o1>o2 ? NSOrderedDescending :
                (o2>o1 ? NSOrderedAscending : NSOrderedSame);
    }];
}

- (void)showHistoryStartingFromStepsBack:(NSUInteger)stepsBack {
    FFGame *game = [[FFGamesCore instance] gameWithId:self.activeGameId];

    NSString *highlightPatternId = [(FFMove *) [game.moveHistory objectAtIndex:
            game.moveHistory.count - stepsBack - 1
    ] Pattern].Id;
    for (NSString *patternViewId in self.patternViewsById) {
        if ( ([patternViewId isEqualToString:highlightPatternId])){
            [(FFPatternView *)[self.patternViewsById objectForKey:patternViewId] setHistoryHighlighted:YES asStepBack:0];
        } else{
            [(FFPatternView *)[self.patternViewsById objectForKey:patternViewId] setHistoryHighlighted:NO asStepBack:0];
        }
    }
}

- (void)hideHistory {
    for (NSString *patternViewId in self.patternViewsById) {
        [(FFPatternView *)[self.patternViewsById objectForKey:patternViewId] setHistoryHighlighted:NO asStepBack:0];
    }
}

@end
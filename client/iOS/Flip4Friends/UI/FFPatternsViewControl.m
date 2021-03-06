//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/1/13.
//


#import "FFPatternsViewControl.h"
#import "FFGame.h"
#import "FFGamesCore.h"
#import "FFPatternView.h"
#import "FFHistoryStep.h"
#import "FFToast.h"

#define PATTERN_VIEW_SIZE 60

@interface FFPatternsViewControl ()

@property (weak, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) NSMutableDictionary *patternViewsById;
@property (strong, nonatomic) NSMutableDictionary *tmpRemovedCollector;

@property (weak, nonatomic) FFPatternView *nowActivePatternView;

@end

@implementation FFPatternsViewControl {
    BOOL _needsScrolling;        // YES when the view needs to scroll == not all patterns visible at once
}


- (id)initWithScrollView:(UIScrollView *)scrollView {
    self = [super init];
    if (self) {
        _scrollView = scrollView;
        self.patternViewsById = [[NSMutableDictionary alloc] initWithCapacity:20];
        self.tmpRemovedCollector = [[NSMutableDictionary alloc] initWithCapacity:20];
        scrollView.backgroundColor = [UIColor clearColor];
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

    // ONLY necessary to resort the patterns
    if (_needsScrolling) [self replacePatternsForPlayer:[self shownPlayer]];
    [self updatePatternStatesWithDoneMoves:
            [[[FFGamesCore instance] gameWithId:self.activeGameId] doneMovesForPlayer:self.shownPlayer]];

    [self cancelSelection];

    FFGame *game = [[FFGamesCore instance] gameWithId:self.activeGameId];
    if (game.currentHistoryBackSteps > 0){
        for (NSString *patternID in [game currentHistoryStep].affectedPatternIDs) {
            [[self.patternViewsById objectForKey:patternID] setHistoryHighlighted:YES asStepBack:0];
        }

    }
}

- (void)updatePatternStatesWithDoneMoves:(NSDictionary *)donePatternIds {
    for (NSString *key in self.patternViewsById) {
        FFPatternView *view = (FFPatternView *) [self.patternViewsById objectForKey:key];
        if (view == self.nowActivePatternView) continue;
        view.viewState = [donePatternIds objectForKey:key]== nil ?
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
    CGFloat yPadding = xPadding;

    CGFloat x = 0;
    CGFloat y = 0;

    for (FFPattern *pattern in patterns) {
        NSString *patternId = pattern.Id;
        [self.tmpRemovedCollector removeObjectForKey:patternId];

        FFPatternView *view = [self.patternViewsById objectForKey:patternId];
        if (!view){
            view = [[FFPatternView alloc] initWithFrame:CGRectMake(-100, 5,
                    PATTERN_VIEW_SIZE, PATTERN_VIEW_SIZE)];
            view.pattern = pattern;
            view.forPlayer2 = self.secondPlayer;
            [view addTarget:self action:@selector(patternTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:view];
            [self.patternViewsById setObject:view forKey:patternId];
        }

        [view positionAtX:x andY:y];

        x += (PATTERN_VIEW_SIZE + xPadding);
        if (x+PATTERN_VIEW_SIZE > self.scrollView.bounds.size.width){
            x = 0;
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

    if (x < PATTERN_VIEW_SIZE){     // just started a new line
        self.scrollView.contentSize = CGSizeMake(0, y);
    } else {
        self.scrollView.contentSize = CGSizeMake(0, y + PATTERN_VIEW_SIZE);
    }
    self.scrollView.contentOffset = CGPointMake(0, 0);

    _needsScrolling = self.scrollView.contentSize.height > CGRectGetHeight(self.scrollView.bounds);
}

- (void)patternTapped:(FFPatternView *)view {
    // allowed?
    FFGame *game = [[FFGamesCore instance] gameWithId:self.activeGameId];

    if ([[game doneMovesForPlayer:self.shownPlayer] objectForKey:view.pattern.Id]){
        NSLog(@"This pattern was already played at this point. Ignore.");

        // TODO: Show history pattern!
        // TODO: Highlight history step when this was played

        FFToast *toast = [FFToast make:NSLocalizedString(@"this_pattern_was_already_played", nil)];
        [toast show];

        return;
    }

    if (game.ActivePlayer==game.player1 && self.secondPlayer){
        NSLog(@"Not accepting tap - not this player's turn!");
        return;
    }

    if (self.nowActivePatternView == view){
        [self cancelSelection];
        [self.delegate cancelMoveWithPattern:self.nowActivePatternView.pattern];
        return;
    }

    if (game.Type == kFFGameTypeSingleChallenge && self.nowActivePatternView){
        [self.delegate executeCurrentMove];
        [self performSelector:@selector(chooseNewPattern:) withObject:view afterDelay:0.2];
    } else {
        [self chooseNewPattern:view];
    }


}

- (void)chooseNewPattern:(FFPatternView*)view {
    self.nowActivePatternView = view;
    [view setViewState:kFFPatternViewStateActive];

    [self.delegate setPatternSelectedForMove:view.pattern fromView:view];
}

- (void)activatePatternWithId:(NSString *)patternId {
    [self cancelSelection];

    FFPatternView *view = [self.patternViewsById objectForKey:patternId];
    if (!view) return;

    self.nowActivePatternView = view;
    [view setViewState:kFFPatternViewStateActive];
}

- (void)cancelSelection {
    BOOL wasAlreadyPlayed = [[self doneMoves] objectForKey:self.nowActivePatternView.pattern.Id] != nil;

    [self.nowActivePatternView setViewState:wasAlreadyPlayed ? kFFPatternViewStateAlreadyPlayed : kFFPatternViewStateNormal];
    self.nowActivePatternView = nil;
}

- (void)sortPatterns:(NSMutableArray *)patterns {
    [patterns sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
        if (_needsScrolling){
            NSDictionary *doneMoves = [self doneMoves];
            BOOL o1Played = [doneMoves objectForKey:((FFPattern *)obj1).Id] != nil;
            BOOL o2Played = [doneMoves objectForKey:((FFPattern *)obj2).Id] != nil;

            if (o1Played != o2Played){
                return o1Played ? NSOrderedDescending : NSOrderedAscending;
            }
        }

        NSUInteger o1 = ((FFPattern *)obj1).Coords.count;
        NSUInteger o2 = ((FFPattern *)obj2).Coords.count;

        return o1<o2 ? NSOrderedDescending :
                (o2<o1 ? NSOrderedAscending : NSOrderedSame);
    }];
}

- (NSDictionary *)doneMoves {
    FFGame *game = [[FFGamesCore instance] gameWithId:self.activeGameId];
    return [game doneMovesForPlayer:self.shownPlayer];
}

@end
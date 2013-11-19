//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 8/20/13.
//


#import "FFChallengeSidebar.h"
#import "FFGamesCore.h"
#import "FFMenuViewController.h"
#import "FFAutoSolver.h"
#import "FFChallengeHistorySliderView.h"


@interface FFChallengeSidebar()
@property (weak, nonatomic) FFChallengeHistorySliderView* historySlider;
@end

@implementation FFChallengeSidebar {
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [(UIButton *) [self viewWithTag:401] addTarget:self action:@selector(pauseTapped) forControlEvents:UIControlEventTouchUpInside];
        self.historySlider = (FFChallengeHistorySliderView *) [self viewWithTag:402];
        
        UIButton *solveButton = (UIButton *) [self viewWithTag:775];
        [solveButton addTarget:self action:@selector(solveTapped) forControlEvents:UIControlEventTouchUpInside];
        #ifdef DEBUG
        solveButton.hidden = NO;
        #else
        solveButton.hidden = YES;
        #endif
    }

    return self;
}

- (void)didAppear {
    [self.historySlider didAppear];
}

- (void)setActiveGameWithId:(NSString *)id {
    self.historySlider.activeGameId = id;
}

- (void)didDisappear {
    [self.historySlider didDisappear];
}

- (void)solveTapped {
    FFAutoSolver *solver = [[FFAutoSolver alloc] initWithGameId:[self.delegate.delegate activeGameId]];
    solver.visualize = NO;
    [solver solveAsynchronously];
}

- (void)pauseTapped {
    [self.delegate pauseTapped];
}

- (void)cleanTapped {
    [self.delegate.delegate cleanCurrentGame];
    FFGame *game = [[FFGamesCore instance] gameWithId:[self.delegate.delegate activeGameId]];
    [game clean];
}

@end
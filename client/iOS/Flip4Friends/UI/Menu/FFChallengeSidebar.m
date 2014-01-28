//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 8/20/13.
//


#import "FFChallengeSidebar.h"
#import "FFGamesCore.h"
#import "FFMenuViewController.h"
#import "FFAutoSolver.h"
#import "FFChallengeHistorySliderView.h"
#import "FFToast.h"
#import "FFAnalytics.h"


@interface FFChallengeSidebar()
@property (weak, nonatomic) FFChallengeHistorySliderView* historySlider;
@property (weak, nonatomic) UIView* hintBackground;
@property (weak, nonatomic) UIButton* hintButton;

@property (copy, nonatomic) NSString *activeGameId;

@end

@implementation FFChallengeSidebar {
    BOOL _hintWasAvailable;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [(UIButton *) [self viewWithTag:401] addTarget:self action:@selector(pauseTapped) forControlEvents:UIControlEventTouchUpInside];
        self.historySlider = (FFChallengeHistorySliderView *) [self viewWithTag:402];
        
        UIButton *solveButton = (UIButton *) [self viewWithTag:775];
        [solveButton addTarget:self action:@selector(solveTapped) forControlEvents:UIControlEventTouchUpInside];
        solveButton.hidden = YES;

        self.hintBackground = [self viewWithTag:415];
        self.hintBackground.hidden = YES;
        self.hintButton = (UIButton *) [self viewWithTag:416];
        [self.hintButton addTarget:self action:@selector(hintTapped) forControlEvents:UIControlEventTouchUpInside];
    }

    return self;
}

- (void)hintTapped {
    FFGame *game = [[FFGamesCore instance] gameWithId:self.activeGameId];

//    FFAutoSolver *solver = [[FFAutoSolver alloc] initWithGameId:[self.delegate.delegate activeGameId]];
//    solver.visualize = NO;
//    solver.toastResult = NO;
//    [solver solveAsynchronouslyAndAbortWhenFirstFound:YES];

    if ([game isHintAvailable]){
        [FFAnalytics log:@"HINT_ACTIVATED"];
        [game activateHint];
    } else {
        [FFAnalytics log:@"HINT_DENIED"];
        [[FFToast make:NSLocalizedString(@"hint_not_yet_available", nil)] show];
    }
}

- (void)didAppear {
    [self.historySlider didAppear];
    [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(updateHintButton) name:kFFNotificationGameChanged object:nil];
}

- (void)updateHintButton {
    FFGame *game = [[FFGamesCore instance] gameWithId:self.activeGameId];

    if ([game isRandomChallenge]){
        self.hintBackground.hidden = YES;
        self.hintButton.hidden = YES;
    } else {
        self.hintBackground.hidden = NO;
        self.hintButton.hidden = NO;

        BOOL hintIsAvailable = [game isHintAvailable];
        self.hintButton.alpha = hintIsAvailable ? 1 : 0.4;
        self.hintBackground.alpha = hintIsAvailable ? 1 : 0.4;

        if (hintIsAvailable && !_hintWasAvailable){
            CGRect baseFrame = self.hintBackground.frame;
            self.hintBackground.frame = CGRectMake(baseFrame.origin.x - 10, baseFrame.origin.y - 10, baseFrame.size.width+10, baseFrame.size.height+10);
            [UIView animateWithDuration:0.3 animations:^{
                self.hintBackground.frame = baseFrame;
            } completion:^(BOOL finished) {

                self.hintBackground.frame = CGRectMake(baseFrame.origin.x - 10, baseFrame.origin.y - 10, baseFrame.size.width+10, baseFrame.size.height+10);
                [UIView animateWithDuration:0.4 animations:^{
                    self.hintBackground.frame = baseFrame;
                }];

            }];
        }
        _hintWasAvailable = hintIsAvailable;
    }
}

- (void)setActiveGameWithId:(NSString *)id {
    self.activeGameId = id;
    self.historySlider.activeGameId = id;

    [self updateHintButton];
}

- (void)didDisappear {
    [self.historySlider didDisappear];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)solveTapped {
    FFAutoSolver *solver = [[FFAutoSolver alloc] initWithGameId:[self.delegate.delegate activeGameId]];
    solver.visualize = NO;
    solver.toastResult = YES;
    [solver solveAsynchronouslyAndAbortWhenFirstFound:YES];
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
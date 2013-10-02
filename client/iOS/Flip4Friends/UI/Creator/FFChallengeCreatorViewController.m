//
//  FFChallengeCreatorViewController.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 9/23/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <os/object.h>
#import "FFChallengeCreatorViewController.h"
#import "FFBoardView.h"
#import "FFPatternPaintView.h"
#import "FFCreateChallengeSession.h"
#import "FFMove.h"
#import "FFPatternView.h"
#import "FFBoard.h"
#import "FFAutoSolver.h"
#import "FFTestGameViewController.h"

@interface FFChallengeCreatorViewController ()

@property (weak, nonatomic) IBOutlet FFBoardView *boardView;
@property (weak, nonatomic) IBOutlet FFPatternPaintView *movePaintView;

@property (strong, nonatomic) NSMutableArray *patternViews;
@property (weak, nonatomic) IBOutlet UIScrollView *patternsScroller;

@property (weak, nonatomic) IBOutlet UIView *activePatternPanel;
@property (weak, nonatomic) IBOutlet UILabel *possiblePositionsLabel;

@end

@implementation FFChallengeCreatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.patternViews = [[NSMutableArray alloc] initWithCapacity:5];

    [[FFCreateChallengeSession instance] resetMoveBoard];
    [self.boardView updateTilesFromBoard:[FFCreateChallengeSession instance].moveTmpBoard];
    self.movePaintView.boardView = self.boardView;
    self.movePaintView.delegate = self;
}

- (void)moveStarted {
    self.activePatternPanel.hidden = NO;
}

- (void)moveAborted {
    self.activePatternPanel.hidden = YES;
}

- (IBAction)backButtonTapped:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)checkButtonTapped:(id)sender {
}

- (IBAction)analyzeTapped:(id)sender {
    // TODO
}

- (IBAction)playTapped:(id)sender {
    [[FFCreateChallengeSession instance] buildAndStoreTmpGame];
    [self performSegueWithIdentifier:@"testSegue" sender:self];
}

- (IBAction)addActivePatternTapped:(id)sender {
    FFMove *move = [self.movePaintView getCurrentMoveWithRotationAllowed:YES];
    [[FFCreateChallengeSession instance].moves addObject:move];

    FFAutoSolver *solver = [[FFAutoSolver alloc] init];
    int validPositions = [solver findValidPositionsForPattern:move.Pattern
                                                      onBoard:[FFCreateChallengeSession instance].moveTmpBoard];
    self.possiblePositionsLabel.text = [NSString stringWithFormat:@"%i", validPositions];

    // flip the board accordingly
    [[FFCreateChallengeSession instance].moveTmpBoard doMoveWithCoords:[move buildToFlipCoords]];
    [self.boardView updateTilesFromBoard:[FFCreateChallengeSession instance].moveTmpBoard];

    // show the pattern view for that
    FFPatternView *nuPatternView = [[FFPatternView alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
    nuPatternView.pattern = move.Pattern;
    nuPatternView.forPlayer2 = NO;
    nuPatternView.viewState = kFFPatternViewStateNormal;
    [self.patternsScroller addSubview:nuPatternView];

    [self.patternViews addObject:nuPatternView];
    [self repositionPatternViews];

    [self.movePaintView reset];
    self.activePatternPanel.hidden = YES;
}

- (void)repositionPatternViews {
    NSUInteger x = 28;
    for (FFPatternView *patternView in self.patternViews) {
        patternView.center = CGPointMake(x, 28);
        x += 54 + 2;
    }
    self.patternsScroller.contentSize = CGSizeMake(x, 1);
}

- (IBAction)cancelActivePatternTapped:(id)sender {
    [self.movePaintView reset];
    self.activePatternPanel.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

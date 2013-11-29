//
//  FFChallengeSelectMenu.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 11/28/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFChallengeSelectMenu.h"
#import "FFMenuViewController.h"
#import "FFGamesCore.h"
#import "FFStorageUtil.h"
#import "FFToast.h"

@interface FFChallengeSelectMenu ()
@property (weak, nonatomic) UITableView *tableView;
@end

@implementation FFChallengeSelectMenu

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tableView = (UITableView *) [self viewWithTag:501];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;

        [(UIButton*)[self viewWithTag:502] addTarget:self action:@selector(backToMainMenuTapped) forControlEvents:UIControlEventTouchUpInside];

        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_back_pattern.png"]];
    }
    return self;
}

- (void)backToMainMenuTapped {
    [self.delegate goBackToMainMenu];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[FFGamesCore instance] autoGeneratedLevelCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";

    NSUInteger index = (NSUInteger) indexPath.row;

    // hand-made challenge
    BOOL locked = [FFStorageUtil firstUnsolvedPuzzleIndex] < [[FFGamesCore instance] unlockLevelForChallenge:index];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setBackgroundColor:[UIColor clearColor]];

    UIView *difficultyBoxBack = [cell viewWithTag:1];
    UILabel *difficultyNumber = (UILabel *) [cell viewWithTag:2];

    difficultyBoxBack.hidden = NO;
    difficultyBoxBack.backgroundColor =
        [UIColor colorWithHue:(1.0-((CGFloat)index/ (CGFloat) [[FFGamesCore instance] autoGeneratedLevelCount])) * 120.0/360.0
                   saturation:locked ? 0.2 : 0.8
                   brightness:0.7
                        alpha:1];

    // lock visualization
    [cell viewWithTag:13].hidden = !locked;

    UILabel *label = (UILabel *) [cell viewWithTag:5];
    NSUInteger timesWon = [FFStorageUtil getTimesWonForChallengeLevel:index];
    NSUInteger timesPlayed = [FFStorageUtil getTimesPlayedForChallengeLevel:index];
    label.text = [NSString stringWithFormat:@"%i/%i", timesWon, timesPlayed];
    label.hidden = locked || timesPlayed < 1;

    difficultyNumber.hidden = NO;
    difficultyNumber.text = [NSString stringWithFormat:@"%i", index+1];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = (NSUInteger) indexPath.row;

    BOOL locked = [FFStorageUtil firstUnsolvedPuzzleIndex] < [[FFGamesCore instance] unlockLevelForChallenge:index];

    if (locked){
        FFToast *toast = [FFToast make:NSLocalizedString(@"challenge_not_yet_unlockedd", nil)];
        [toast show];

        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        [self.delegate activateRandomChallengeAtIndex:index];
    }
}

- (void)refreshListCells {
    [self.tableView reloadData];
}

- (void)hide:(BOOL)hidden {
    if (self.hidden == hidden) return;

    self.hidden = hidden;
    [self refreshListCells];
}

@end
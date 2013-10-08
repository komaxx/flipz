//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/25/13.
//


#import "FFChallengeMenu.h"
#import "FFGamesCore.h"
#import "FFMenuViewController.h"
#import "FFAppDelegate.h"
#import "FFStorageUtil.h"

@interface FFChallengeMenu ()
@property (weak, nonatomic) UITableView *tableView;
@end

@implementation FFChallengeMenu {
    NSInteger _firstUnsolvedIndex;
}
@synthesize delegate = _delegate;


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
    return [[FFGamesCore instance] challengesCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifierContact = @"ChallengeCell";

    NSUInteger index = (NSUInteger) indexPath.row;
    BOOL locked = index >= [FFStorageUtil firstUnsolvedChallengeIndex];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierContact];
    [cell setBackgroundColor:locked ? [UIColor darkGrayColor] : [UIColor clearColor]];

    [cell viewWithTag:index%2==1?1:11].hidden = YES;
    [cell viewWithTag:index%2==1?2:12].hidden = YES;

    UIView *difficultyBoxBack = [cell viewWithTag:index%2==0?1:11];
    UILabel *difficultyNumber = (UILabel *) [cell viewWithTag:index%2==0?2:12];

    difficultyBoxBack.hidden = NO;
    difficultyBoxBack.backgroundColor =
        [UIColor colorWithHue:(1.0-((CGFloat)index/ (CGFloat)[[FFGamesCore instance] challengesCount])) * 120.0/360.0
                   saturation:0.8
                   brightness:0.7
                        alpha:1];

    difficultyNumber.hidden = NO;
    difficultyNumber.text = [NSString stringWithFormat:@"%i", index+1];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = (NSUInteger) indexPath.row;

    if (index >= [FFStorageUtil firstUnsolvedChallengeIndex]){
        // TODO show toast
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        FFGame *game = [[FFGamesCore instance] challenge:(NSUInteger) index];
        [self.delegate activateGameWithId:game.Id];
        [self.delegate activateChallengeAtIndex:(NSUInteger)index];
    }
}

- (void)refreshListCells {
    [self.tableView reloadData];
}

- (void)hide:(BOOL)hidden {
    self.hidden = hidden;
}

@end
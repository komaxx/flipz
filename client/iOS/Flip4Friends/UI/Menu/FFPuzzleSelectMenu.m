//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/25/13.
//


#import "FFPuzzleSelectMenu.h"
#import "FFGamesCore.h"
#import "FFMenuViewController.h"
#import "FFAppDelegate.h"
#import "FFStorageUtil.h"
#import "FFToast.h"

@interface FFPuzzleSelectMenu ()
@property (weak, nonatomic) UITableView *tableView;
@end

@implementation FFPuzzleSelectMenu {
}
@synthesize delegate = _delegate;


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tableView = (UITableView *) [self viewWithTag:501];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;

        [(UIButton*)[self viewWithTag:502]
                addTarget:self
                   action:@selector(backToMainMenuTapped)
         forControlEvents:UIControlEventTouchUpInside];

        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_back_pattern.png"]];
    }
    return self;
}

- (void)backToMainMenuTapped {
    [self.delegate goBackToMainMenu];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[FFGamesCore instance] puzzlesCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *challengeCellIdentifier = @"PuzzleCell";

    NSUInteger index = (NSUInteger) indexPath.row;

    BOOL locked = index >= [FFStorageUtil firstUnsolvedPuzzleIndex];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:challengeCellIdentifier];
    [cell setBackgroundColor:[UIColor clearColor]];

    [cell viewWithTag:index%2==1?1:11].hidden = YES;
    [cell viewWithTag:index%2==1?2:12].hidden = YES;

    UIView *difficultyBoxBack = [cell viewWithTag:index%2==0?1:11];
    UILabel *difficultyNumber = (UILabel *) [cell viewWithTag:index%2==0?2:12];

    difficultyBoxBack.hidden = NO;
    difficultyBoxBack.backgroundColor =
        [UIColor colorWithHue:(1.0-((CGFloat)index/ (CGFloat) [[FFGamesCore instance] puzzlesCount])) * 120.0/360.0
                   saturation:locked ? 0.2 : 0.8
                   brightness:0.7
                        alpha:1];

    // lock visualization
    [cell viewWithTag:13].hidden = !locked;

    difficultyNumber.hidden = NO;
    difficultyNumber.text = [NSString stringWithFormat:@"%i", index+1];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = (NSUInteger) indexPath.row;

    if (index >= [FFStorageUtil firstUnsolvedPuzzleIndex]){
        FFToast *toast = [FFToast make:NSLocalizedString(@"puzzle_not_yet_unlocked", nil)];
        [toast show];

        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        FFGame *game = [[FFGamesCore instance] puzzle:(NSUInteger) index];
        [game clean];
        [self.delegate activatePuzzleAtIndex:(NSUInteger) index];
    }
}

- (void)refreshListCells {
    [self.tableView reloadData];
}

- (void)hide:(BOOL)hidden {
    if (self.hidden == hidden) return;

    self.hidden = hidden;
    if (!hidden){
        // just displayed -> focus on last unsolved element
        NSIndexPath *indexPath = [NSIndexPath
                indexPathForRow:MAX(0,[FFStorageUtil firstUnsolvedPuzzleIndex]-3)
                      inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/25/13.
//


#import "FFPuzzleSelectMenu.h"
#import "FFGamesCore.h"
#import "FFMenuViewController.h"
#import "FFStorageUtil.h"
#import "FFToast.h"
#import "FFCheatButton.h"

@interface FFPuzzleSelectMenu () <UIAlertViewDelegate>
@property (weak, nonatomic) UITableView *tableView;
@end

@implementation FFPuzzleSelectMenu {
    BOOL _previouslyShown;
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

        [(FFCheatButton *) [self viewWithTag:504] addTarget:self andAction:@selector(cheatUnlock)];

        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_back_pattern.png"]];
    }
    return self;
}

- (void)cheatUnlock {
    UIAlertView * alert = [[UIAlertView alloc]
            initWithTitle:NSLocalizedString(@"cheat_dialog_title", nil) message:NSLocalizedString(@"cheat_dialog_message", nil)
                 delegate:self
        cancelButtonTitle:NSLocalizedString(@"cancel", nil)
        otherButtonTitles:NSLocalizedString(@"btn_cheat", nil), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput; 
    alert.delegate = self;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.tag = 123;
    alertTextField.keyboardType = UIKeyboardTypeAlphabet;
    alertTextField.placeholder = NSLocalizedString(@"cheat_code_placeholder", nil);

    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex){
        NSString *enteredCheatCode = [[alertView textFieldAtIndex:0] text];
        [self.delegate cheatWithCode:enteredCheatCode];

        [self.tableView reloadData];
    }
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
    } else {
        FFGame *game = [[FFGamesCore instance] puzzle:(NSUInteger) index];
        [game clean];
        [self.delegate activatePuzzleAtIndex:(NSUInteger) index];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)refreshListCells {
    [self.tableView reloadData];
}

- (void)hide:(BOOL)hidden {
//    if (self.hidden == hidden) return;

    self.hidden = hidden;
    if (!hidden){

        if (!_previouslyShown){
            // just displayed -> focus on last unsolved element
            NSIndexPath *indexPath = [NSIndexPath
                    indexPathForRow:MAX(1,[FFStorageUtil firstUnsolvedPuzzleIndex]-3)
                          inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            _previouslyShown = YES;
        }
    }
}

@end
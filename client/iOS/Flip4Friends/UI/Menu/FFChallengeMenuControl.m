//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 7/25/13.
//


#import "FFChallengeMenuControl.h"
#import "FFGamesCore.h"
#import "FFMenuViewController.h"

@interface FFChallengeMenuControl ()
@property (weak, nonatomic) UITableView *tableView;
@end

@implementation FFChallengeMenuControl {
}
@synthesize delegate = _delegate;


- (id)initWithScrollView:(UITableView *)tableView {
    self = [super init];

    if (self){
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;

        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_back_pattern.png"]];
    }

    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [FFGamesCore instance].challenges.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifierContact = @"ChallengeCell";

    NSUInteger index = (NSUInteger) indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierContact];

    [cell viewWithTag:index%2==1?1:11].hidden = YES;
    [cell viewWithTag:index%2==1?2:12].hidden = YES;

    UIView *difficultyBoxBack =  [cell viewWithTag:index%2==0?1:11];
    UILabel *difficultyNumber = (UILabel *) [cell viewWithTag:index%2==0?2:12];

    difficultyBoxBack.hidden = NO;
    difficultyBoxBack.backgroundColor =
        [UIColor colorWithHue:(1.0-((CGFloat)index/ (CGFloat)[FFGamesCore instance].challenges.count)) * 120.0/360.0
                   saturation:0.8
                   brightness:0.7
                        alpha:1];

    difficultyNumber.hidden = NO;
    difficultyNumber.text = [NSString stringWithFormat:@"%i", index];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = (NSUInteger) indexPath.row;

    FFGame *game = [[FFGamesCore instance].challenges objectAtIndex:index];
    [self.delegate activateGameWithId:game.Id];
}

- (void)hide:(BOOL)hidden {
    self.tableView.hidden = hidden;
}
@end
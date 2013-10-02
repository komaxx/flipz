//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 9/26/13.
//


#import "FFAdditiveChallengeCreatorController.h"
#import "FFBoardView.h"
#import "FFBoard.h"
#import "FFAutoSolver.h"
#import "FFMove.h"
#import "FFPatternView.h"
#import "FFGamesCore.h"
#import "FFChallengeCreatorViewController.h"
#import "FFChallengeLoader.h"


@interface FFAdditiveChallengeCreatorController ()

@property (weak, nonatomic) IBOutlet FFBoardView *boardView;
@property (weak, nonatomic) IBOutlet UIView *parametersOverlay;
@property (weak, nonatomic) IBOutlet UITableView *flipTypeTable;
@property (weak, nonatomic) IBOutlet FFPatternPaintView *patternView;
@property (weak, nonatomic) IBOutlet UIView *activePatternPanel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *lockMovesSelector;
@property (weak, nonatomic) IBOutlet UISwitch *allowRotationSwitch;
@property (weak, nonatomic) IBOutlet UIButton *prerotationButton;

@property (strong, nonatomic) NSMutableArray *patternViews;
@property (weak, nonatomic) IBOutlet UIScrollView *patternsScroller;

@property (strong, nonatomic) FFBoard* board;
@property (strong, nonatomic) NSMutableArray *moves;

// history
@property (strong, nonatomic) FFBoard *lastBoard;
@property (strong, nonatomic) NSMutableArray *lastMoves;

@end

@implementation FFAdditiveChallengeCreatorController {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.board = [[FFBoard alloc] initWithSize:8];
    self.board.BoardType = kFFBoardType_multiStated_clamped;
    self.board.lockMoves = 1;

    self.moves = [[NSMutableArray alloc] initWithCapacity:10];
    self.patternViews = [[NSMutableArray alloc] initWithCapacity:10];

    [self.boardView updateTilesFromBoard:self.board];

    self.patternView.boardView = self.boardView;
    self.patternView.delegate = self;

    self.flipTypeTable.dataSource = self;
    self.flipTypeTable.delegate = self;

    [self.flipTypeTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:(UITableViewScrollPosition) 0];
}

// ////////////////////////////////////////////////////////////////////////////////
// basic parameters panel

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)parametersButtonTapped:(id)sender {
    self.parametersOverlay.hidden = NO;
}

- (IBAction)parametersTapGuardTapped:(id)sender {
    self.parametersOverlay.hidden = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    UILabel *label = (UILabel *) [cell viewWithTag:5];
    label.text = @"Two Stated";
    if (indexPath.row == 1) label.text = @"Multi (clamped)";
    if (indexPath.row == 2) label.text = @"Multi (rollover)";

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FFBoardType nuType = (FFBoardType) indexPath.row;

    if (nuType != self.board.BoardType){
        self.board.BoardType = nuType;

        [self createUndoPoint];
        [self resetPatterns];
    }
}

- (void)resetPatterns {
    [self.moves removeAllObjects];
    for (UIView *patternView in self.patternViews) [patternView removeFromSuperview];
    [self.patternViews removeAllObjects];

    [self.board cleanMonochromaticTo:0];
    [self.boardView updateTilesFromBoard:self.board];
}

- (IBAction)lockMoveCountChanged:(UISegmentedControl*)sender {
    self.board.lockMoves = sender.selectedSegmentIndex;
    [self resetPatterns];
    self.board.lockMoves = sender.selectedSegmentIndex;
}

// /////////////////////////////////////////////////////
// board painting

- (void)movePainting:(UISwipeGestureRecognizerDirection)direction {
    FFBoard *movedBoard = [[FFBoard alloc] initWithBoard:self.board];

    for (NSUInteger y = 0; y < self.board.BoardSize; y++){
        for (NSUInteger x = 0; x < self.board.BoardSize; x++){
            int sourceTileX = x;
            if (direction==UISwipeGestureRecognizerDirectionLeft) sourceTileX++;
            else if (direction==UISwipeGestureRecognizerDirectionRight) sourceTileX--;

            int sourceTileY = y;
            if (direction==UISwipeGestureRecognizerDirectionUp) sourceTileY++;
            else if (direction==UISwipeGestureRecognizerDirectionDown) sourceTileY--;

            if (sourceTileX<0||sourceTileX>=movedBoard.BoardSize
                    ||sourceTileY<0||sourceTileY>=movedBoard.BoardSize){
                [movedBoard tileAtX:x andY:y].color = 0;
            } else {
                FFTile *oTile = [self.board tileAtX:(NSUInteger)sourceTileX andY:(NSUInteger) sourceTileY];
                FFTile *tile = [movedBoard tileAtX:x andY:y];
                tile.color = oTile.color;
                tile.unlockTime = oTile.unlockTime;
                tile.nowLocked = oTile.nowLocked;
            }
        }
    }

    [self updateBoardWith:movedBoard];
}

- (IBAction)changeBoardSize:(id)sender {
    NSUInteger nuSize = (NSUInteger) [(UIStepper *) sender value];

    FFBoard *nuBoard = [[FFBoard alloc] initWithSize:nuSize];
    nuBoard.BoardType = self.board.BoardType;
    nuBoard.lockMoves = self.board.lockMoves;
    NSUInteger minSize = MIN(nuSize, self.board.BoardSize);
    for (NSUInteger y = 0; y < minSize; y++){
        for (NSUInteger x = 0; x < minSize; x++){
            [nuBoard tileAtX:x andY:y].color = [self.board tileAtX:x andY:y].color;
        }
    }

    [self updateBoardWith:nuBoard];
    [self resetPatterns];
}

- (void)updateBoardWith:(FFBoard *)nuBoard {
    self.board = nuBoard;
    [self.boardView updateTilesFromBoard:self.board];
}

// board painting
// /////////////////////////////////////////////////////
// pattern creation

- (IBAction)addCurrentPatternTapped:(id)sender {
    FFMove *move = [self.patternView getCurrentMoveWithRotationAllowed:self.allowRotationSwitch.on];
    if (self.allowRotationSwitch.on && self.prerotationButton.tag != 0){
        move = [[FFMove alloc] initWithPattern:[move.Pattern copyForOrientation:(FFOrientation)self.prerotationButton.tag]
                                     atPosition:move.Position
                                 andOrientation:(FFOrientation)((-self.prerotationButton.tag+4) % 4)];
    }

    [self.moves addObject:move];

    // flip the board accordingly
    [self.board buildGameByFlippingCoords:[move buildToFlipCoords]];
    [self.boardView updateTilesFromBoard:self.board];

    // show the pattern view for that
    FFPatternView *nuPatternView = [[FFPatternView alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
    nuPatternView.pattern = move.Pattern;
    nuPatternView.forPlayer2 = NO;
    nuPatternView.viewState = kFFPatternViewStateNormal;
    [self.patternsScroller addSubview:nuPatternView];

    [self.patternViews addObject:nuPatternView];
    [self repositionPatternViews];

    [self.patternView reset];
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

- (IBAction)cancelCurrentPatternTapped:(id)sender {
    [self.patternView reset];
    self.activePatternPanel.hidden = YES;
}

- (void)moveStarted {
    self.activePatternPanel.hidden = NO;
}

- (void)moveAborted {
    self.activePatternPanel.hidden = YES;
}

- (IBAction)prerotationButtonTapped:(id)sender {
    self.prerotationButton.tag = (self.prerotationButton.tag+1) % 4;

    switch (self.prerotationButton.tag) {
        case 1:
            [self.prerotationButton setTitle:@"90°" forState:UIControlStateNormal];
            break;
        case 2:
            [self.prerotationButton setTitle:@"180°" forState:UIControlStateNormal];
            break;
        case 3:
            [self.prerotationButton setTitle:@"270°" forState:UIControlStateNormal];
            break;
        case 0:
        default:
            [self.prerotationButton setTitle:@"NONE" forState:UIControlStateNormal];
            break;
    }
}

// pattern creation
// /////////////////////////////////////////////////////

- (IBAction)playTapped:(id)sender {
    [self makeAndRegisterGame];

    [self performSegueWithIdentifier:@"additiveTestSegue" sender:self];
}

- (IBAction)analyzeTapped:(id)sender {
    FFGame* game = [self makeCurrentGame];
    FFAutoSolver *solver = [[FFAutoSolver alloc] initWithGame:game];
    [solver solveAsynchronously];
}

- (IBAction)printTapped:(id)sender {
    FFGame* game = [self makeCurrentGame];
    NSString *json = [FFChallengeLoader encodeGameAsJson:game];
    NSLog(@"%@", json);
}

- (FFGame *)makeCurrentGame {
    FFBoard *boardCopy = [[FFBoard alloc] initWithBoard:self.board];
    [boardCopy unlock];

    FFGame* testGame = [[FFGame alloc]
            initTestChallengeWithId:@"tmpChallenge"
                           andBoard:boardCopy];

    NSMutableArray *patterns = [[NSMutableArray alloc] initWithCapacity:10];
    for (FFMove *move in self.moves) {
        [patterns addObject:move.Pattern];
    }
    testGame.player1.playablePatterns = patterns;
    return testGame;
}

- (void)makeAndRegisterGame {
    [[FFGamesCore instance] registerGame:[self makeCurrentGame]];
}

- (void)createUndoPoint {
    // TODO
}

@end

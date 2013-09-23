//
//  FFChallengeCreatorController.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 9/18/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FFBoardCreatorController.h"
#import "FFBoardView.h"
#import "FFBoard.h"
#import "FFBoardPaintView.h"

@interface FFBoardCreatorController ()

@property (strong, nonatomic) FFBoard* board;

@property (weak, nonatomic) IBOutlet FFBoardView *boardView;
@property (weak, nonatomic) IBOutlet FFBoardPaintView *paintView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *paintOrEraseSelect;
@property (weak, nonatomic) IBOutlet UIView *paramtersOverlay;
@property (weak, nonatomic) IBOutlet UITableView *flipTypeTable;

@end

@implementation FFBoardCreatorController

- (void)viewDidLoad {
    [super viewDidLoad];


    self.board = [[FFBoard alloc] initWithSize:8];
    self.board.BoardType = kFFBoardType_multiStated_clamped;

    [self.boardView updateTilesFromBoard:self.board];
    
    self.paintView.boardView = self.boardView;
    self.paintView.delegate = self;

    self.flipTypeTable.dataSource = self;
    self.flipTypeTable.delegate = self;

    [self.flipTypeTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:(UITableViewScrollPosition) 0];
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)forwardTapped:(id)sender {
}

- (IBAction)parametersButtonTapped:(id)sender {
    self.paramtersOverlay.hidden = NO;
}

- (IBAction)parametersTapGuardTapped:(id)sender {
    self.paramtersOverlay.hidden = YES;
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
        [self.boardView updateTilesFromBoard:self.board];
    }
}

// /////////////////////////////////////////////////////
// board painting

- (void)tileTappedToPaintX:(NSUInteger)x andY:(NSUInteger)y done:(BOOL)done {
    int toAdd = self.paintOrEraseSelect.selectedSegmentIndex==0 ? -1 : +1;

    if (done) [self createUndoPoint];

    [self.board tileAtX:x andY:y].color += toAdd;
    [self updateBoardWith:self.board];

    [self.boardView updateTilesFromBoard:self.board];
}

- (void)paintingEnded {
    [self createUndoPoint];
}


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
                [movedBoard tileAtX:x andY:y].color = [self.board tileAtX:(NSUInteger) sourceTileX andY:(NSUInteger) sourceTileY].color;
            }
        }
    }

    [self updateBoardWith:movedBoard];
}

- (IBAction)changeBoardSize:(id)sender {
    NSUInteger nuSize = (NSUInteger) [(UIStepper *) sender value];

    FFBoard *nuBoard = [[FFBoard alloc] initWithSize:nuSize];
    nuBoard.BoardType = self.board.BoardType;
    NSUInteger minSize = MIN(nuSize, self.board.BoardSize);
    for (NSUInteger y = 0; y < minSize; y++){
        for (NSUInteger x = 0; x < minSize; x++){
            [nuBoard tileAtX:x andY:y].color = [self.board tileAtX:x andY:y].color;
        }
    }

    [self updateBoardWith:nuBoard];
}

- (void)updateBoardWith:(FFBoard *)nuBoard {
    self.board = nuBoard;
    [self.boardView updateTilesFromBoard:self.board];

    [self.board printColorsToLog];
}

// board painting
// /////////////////////////////////////////////////////

- (void)createUndoPoint {
    // TODO
}

@end

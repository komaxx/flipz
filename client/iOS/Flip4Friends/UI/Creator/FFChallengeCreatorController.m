//
//  FFChallengeCreatorController.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 9/18/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FFChallengeCreatorController.h"
#import "FFBoardView.h"
#import "FFBoard.h"
#import "FFChallengePaintView.h"

@interface FFChallengeCreatorController ()

@property (strong, nonatomic) FFBoard* board;

@property (weak, nonatomic) IBOutlet FFBoardView *boardView;
@property (weak, nonatomic) IBOutlet FFChallengePaintView *paintView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *paintOrEraseSelect;

@end

@implementation FFChallengeCreatorController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.paintOrEraseSelect.layer.transform = CATransform3DMakeRotation((CGFloat) (-M_PI/2), 0, 0, 1);

    self.board = [[FFBoard alloc] initWithSize:8];
    self.board.BoardType = kFFBoardType_multiStated_clamped;

    [self.boardView updateTilesFromBoard:self.board];
    
    self.paintView.boardView = self.boardView;
    self.paintView.delegate = self;
}

- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// /////////////////////////////////////////////////////
// board painting

- (void)tileTappedToPaintX:(NSUInteger)x andY:(NSUInteger)y {
    int toAdd = self.paintOrEraseSelect.selectedSegmentIndex==0 ? -1 : +1;
    [self.board tileAtX:x andY:y].color += toAdd;
    [self updateBoardWith:self.board];

    [self.boardView updateTilesFromBoard:self.board];
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

@end

//
//  FFChallengePaintView.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 9/18/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFBoardPaintView.h"
#import "FFBoardView.h"
#import "FFBoardCreatorController.h"

@interface FFBoardPaintView ()
@property (strong, nonatomic) FFCoord *lastPannedCoord;
@end


@implementation FFBoardPaintView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tapRecognizer];

        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        panRecognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:panRecognizer];

        UISwipeGestureRecognizer *upCognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
        upCognizer.direction = UISwipeGestureRecognizerDirectionUp;
        upCognizer.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:upCognizer];

        UISwipeGestureRecognizer *rightCognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
        rightCognizer.direction = UISwipeGestureRecognizerDirectionRight;
        rightCognizer.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:rightCognizer];

        UISwipeGestureRecognizer *downCognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
        downCognizer.direction = UISwipeGestureRecognizerDirectionDown;
        downCognizer.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:downCognizer];

        UISwipeGestureRecognizer *leftCognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
        leftCognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        leftCognizer.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:leftCognizer];
    }

    return self;
}

- (void)panned:(UIPanGestureRecognizer*)panCognizer {
    if (panCognizer.state == UIGestureRecognizerStateCancelled){
        self.lastPannedCoord = nil;
    } else if (panCognizer.state == UIGestureRecognizerStateEnded) {
        self.lastPannedCoord = nil;
        [self.delegate paintingEnded];
    } else {
        CGFloat tileSize = [self.boardView computeTileSize];
        CGPoint tapPos = [panCognizer locationOfTouch:0 inView:self];

        ushort xCoord = (ushort)(tapPos.x / tileSize);
        ushort yCoord = (ushort)(tapPos.y / tileSize);

        if (!self.lastPannedCoord || xCoord != self.lastPannedCoord.x || yCoord != self.lastPannedCoord.y){
            NSLog(@"now on %ix%i", xCoord, yCoord);
            [self.delegate tileTappedToPaintX:xCoord andY:yCoord done:NO];
            self.lastPannedCoord = [[FFCoord alloc] initWithX:xCoord andY:yCoord];
        }
    }
}

- (void)swiped:(UISwipeGestureRecognizer*)swipeCognizer {
    if (swipeCognizer.state != UIGestureRecognizerStateRecognized) return;

    [self.delegate movePainting:swipeCognizer.direction];
}

- (void)tapped:(UITapGestureRecognizer *)tapCognizer {
    if (tapCognizer.state != UIGestureRecognizerStateEnded) return;

    CGFloat tileSize = [self.boardView computeTileSize];
    CGPoint tapPos = [tapCognizer locationOfTouch:0 inView:self];

    NSUInteger xCoord = (NSUInteger) (tapPos.x / tileSize);
    NSUInteger yCoord = (NSUInteger) (tapPos.y / tileSize);

    [self.delegate tileTappedToPaintX:xCoord andY:yCoord done:YES];
}

@end

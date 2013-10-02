//
//  FFPatternPaintView.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 9/24/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FFPatternPaintView.h"
#import "FFBoardView.h"
#import "FFPatternGenerator.h"
#import "FFMove.h"
#import "FFPattern.h"
#import "FFChallengeCreatorViewController.h"

@interface FFPatternPaintView ()

@property (strong, nonatomic) NSMutableArray *tiles;
@property (strong, nonatomic) NSMutableArray *tileViews;

@end

@implementation FFPatternPaintView
@synthesize boardView = _boardView;


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.tiles = [[NSMutableArray alloc] initWithCapacity:10];
        self.tileViews = [[NSMutableArray alloc] initWithCapacity:10];

        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tapRecognizer];

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

    BOOL found = NO;
    for (NSUInteger i = 0; i < self.tiles.count; i++) {
        FFCoord* coord = [self.tiles objectAtIndex:i];
        if (coord.x == xCoord && coord.y == yCoord){
            // already found!
            [self.tiles removeObjectAtIndex:i];
            [(UIView *)[self.tileViews objectAtIndex:i] removeFromSuperview];
            [self.tileViews removeObjectAtIndex:i];
            found = YES;

            if (self.tiles.count == 0) [self.delegate moveAborted];

            break;
        }
    }

    if (!found){
        CGRect frame = CGRectMake(xCoord*tileSize, yCoord*tileSize, tileSize, tileSize);
        UIView *tileView = [[UIView alloc] initWithFrame:frame];
        tileView.backgroundColor = [UIColor colorWithPatternImage:[FFPatternGenerator createHistoryMoveOverlayPatternForStep:0]];
        self.layer.anchorPointZ = -1000;
        [self addSubview:tileView];

        [self.tiles addObject:[[FFCoord alloc] initWithX:(ushort) xCoord andY:(ushort) yCoord]];
        [self.tileViews addObject:tileView];

        if (self.tiles.count == 1) [self.delegate moveStarted];
    }
}

- (void)reset {
    for (UIView *view in self.tileViews) {
        [view removeFromSuperview];
    }
    [self.tileViews removeAllObjects];
    [self.tiles removeAllObjects];
}

- (FFMove *)getCurrentMoveWithRotationAllowed:(BOOL)rotating {
    NSUInteger minX = 1000;
    NSUInteger minY = 1000;

    NSMutableArray *coords = [[NSMutableArray alloc] initWithCapacity:self.tiles.count];
    for (FFCoord *tile in self.tiles) {
        minX = MIN(minX, tile.x);
        minY = MIN(minY, tile.y);
        [coords addObject:tile];
    }

    FFMove *move = [[FFMove alloc] initWithPattern:[[FFPattern alloc] initWithCoords:coords andAllowRotation:rotating]
                                        atPosition:[[FFCoord alloc] initWithX:(ushort) minX andY:(ushort) minY]
                                    andOrientation:kFFOrientation_0_degrees];
    return move;
}
@end

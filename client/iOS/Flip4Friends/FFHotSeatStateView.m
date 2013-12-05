//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/18/13.
//


#import "FFHotSeatStateView.h"
#import "FFGame.h"
#import "FFGamesCore.h"
#import "UIColor+FFColors.h"
#import "FFGrayBackedLabel.h"

@interface FFHotSeatStateView ()

@property (weak, nonatomic) UIView *centerBlock;

@property (weak, nonatomic) UILabel *player1Score;
@property (weak, nonatomic) UILabel *player2Score;

@property (weak, nonatomic) UILabel *player1Label;
@property (weak, nonatomic) UILabel *player2Label;

@property (weak, nonatomic) UIView *player1Column;
@property (weak, nonatomic) UIView *player2Column;

@property (weak, nonatomic) UILabel *player1DeltaScore;
@property (weak, nonatomic) UILabel *player2DeltaScore;

@end

@implementation FFHotSeatStateView {
    NSUInteger _p1LastScore;
    NSUInteger _p2LastScore;
}
@synthesize activeGameId = _activeGameId;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        self.centerBlock = [self viewWithTag:460];

        self.player1Score = (UILabel *) [self viewWithTag:461];
        [self.player1Score.layer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)-M_PI_2)];
        self.player2Score = (UILabel *) [self viewWithTag:462];
        [self.player2Score.layer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)-M_PI_2)];

        self.player1Label = (UILabel *) [self viewWithTag:463];
        [self styleLabel:self.player1Label];
        [self.player1Label.layer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)-M_PI_2)];

        self.player2Label = (UILabel *) [self viewWithTag:464];
        [self.player2Label.layer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)-M_PI_2)];
        [self styleLabel:self.player2Label];

        // score columns
        UIView *player1Col = [[UIView alloc] initWithFrame:CGRectMake(0, self.center.y, 2, self.center.y)];
        player1Col.backgroundColor = [UIColor movePatternBack];
        player1Col.layer.borderWidth = 2;
        player1Col.layer.borderColor = [[UIColor colorWithWhite:1 alpha:0.2] CGColor];
        [self addSubview:player1Col];
        self.player1Column = player1Col;

        UIView *player2Col = [[UIView alloc] initWithFrame:CGRectMake(0, self.center.y, 2, self.center.y)];
        player2Col.backgroundColor = [UIColor movePattern2Back];
        player2Col.layer.borderWidth = 2;
        player2Col.layer.borderColor = [[UIColor colorWithWhite:1 alpha:0.2] CGColor];
        [self addSubview:player2Col];
        self.player2Column = player2Col;

        [self sendSubviewToBack:player1Col];
        [self sendSubviewToBack:player2Col];

        // delta score labels
        UILabel* p1Score = [[FFGrayBackedLabel alloc] initWithFrame:self.player1Score.frame];
        [p1Score.layer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)-M_PI_2)];
        CGPoint c = p1Score.center;
        c.x -= p1Score.bounds.size.width;
        c.y += self.centerBlock.frame.origin.y;
        p1Score.center = c;
        self.player1DeltaScore = p1Score;
        [self styleDeltaLabel:p1Score];
        [self addSubview:p1Score];

        UILabel* p2Score = [[FFGrayBackedLabel alloc] initWithFrame:self.player2Score.frame];
        [p2Score.layer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)-M_PI_2)];
        c = p2Score.center;
        c.x -= p2Score.bounds.size.width;
        c.y += self.centerBlock.frame.origin.y;
        p2Score.center = c;
        self.player2DeltaScore = p2Score;
        [self addSubview:p2Score];
        [self styleDeltaLabel:p2Score];

        self.player1DeltaScore.hidden = YES;
        self.player2DeltaScore.hidden = YES;


        UITapGestureRecognizer *tapCognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        [self addGestureRecognizer:tapCognizer];


        [self repositionScoreColumnsAndLabelsForScore1:0 andScore2:0];
    }

    return self;
}

- (void)tapped {
    [self showDeltaScores];
}

- (void)styleDeltaLabel:(UILabel *)label {
    label.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:19];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
}

- (void)repositionScoreColumnsAndLabelsForScore1:(NSUInteger)p1score andScore2:(NSUInteger)p2score {
    BOOL p1Leads = p1score >= p2score;

    CGFloat p1Width = p1Leads ? 20 : 12;
    CGFloat p2Width = p1Leads ? 12 : 20;

    CGFloat p1Height = ((CGFloat)MIN(p1score,150) / 150.0) * (self.bounds.size.height-self.centerBlock.frame.size.height) / 2.0;
    CGFloat p2Height = ((CGFloat)MIN(p2score,150) / 150.0) * (self.bounds.size.height-self.centerBlock.frame.size.height) / 2.0;

    [UIView animateWithDuration:0.2 animations:^{
        self.player1Column.frame = CGRectMake(
                CGRectGetMidX(self.bounds) - p1Width/2, CGRectGetMidY(self.centerBlock.frame),
                p1Width, p1Height + self.centerBlock.bounds.size.height/2);
        self.player2Column.frame = CGRectMake(
                CGRectGetMidX(self.bounds) - p2Width/2, CGRectGetMidY(self.centerBlock.frame) - p2Height - self.centerBlock.bounds.size.height/2,
                p2Width, p2Height + self.centerBlock.bounds.size.height/2);


        self.player1Label.center = CGPointMake(
                self.bounds.size.width/2,
                CGRectGetMaxY(self.centerBlock.frame)+p1Height + self.player1Label.bounds.size.width/2
        );
        self.player2Label.center = CGPointMake(
                self.bounds.size.width/2,
                CGRectGetMinY(self.centerBlock.frame)-p2Height - self.player2Label.bounds.size.width / 2
        );
    }];
}

- (void)styleLabel:(UILabel *)label {
    [label setTextColor:[UIColor colorWithWhite:1 alpha:0.2]];
    label.layer.shadowColor = [[UIColor blackColor] CGColor];
    label.layer.shadowOpacity = 1;
    label.layer.shadowOffset = CGSizeMake(-3, 0);
    label.layer.shadowRadius = 0;
    [label sizeToFit];
}

- (void)setActiveGameId:(NSString *)gameId {
    _activeGameId = gameId;
    FFGame *game = [[FFGamesCore instance] gameWithId:gameId];
    if ([game Type] != kFFGameTypeHotSeat){
        _activeGameId = nil;
        // not interested.
    } else {
        [self updateFromGame:game];
    }
}

- (void)didAppear {
    [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(gameChanged:) name:kFFNotificationGameChanged object:nil];
}

- (void)didDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)gameChanged:(NSNotification *)notification {
    NSString *changedGameID = [notification.userInfo objectForKey:kFFNotificationGameChanged_gameId];
    if (![changedGameID isEqualToString:self.activeGameId]) {
        return;  // ignore. Update for the wrong game (not the active one).
    }

    FFGame *game = [[FFGamesCore instance] gameWithId:changedGameID];
    [self updateFromGame:game];
}

- (void)updateFromGame:(FFGame *)game {
    NSUInteger nuP1Score = [game scoreForColor:0];
    NSUInteger nuP2Score = [game scoreForColor:1];

    self.player1Score.text = [@(nuP1Score) stringValue];
    self.player2Score.text = [@(nuP2Score) stringValue];

    [self.player1Score.layer setAffineTransform:CGAffineTransformMakeScale(2, 2)];
    [self.player2Score.layer setAffineTransform:
            CGAffineTransformConcat(
                    CGAffineTransformRotate(CGAffineTransformIdentity,
                    (CGFloat)M_PI), CGAffineTransformMakeScale(2, 2))
    ];

    [UIView animateWithDuration:0.5 animations:^{
        [self.player1Score.layer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)-M_PI_2)];
        [self.player2Score.layer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, (CGFloat)-M_PI_2)];
    }];

    NSUInteger p1Delta = nuP1Score - _p1LastScore;
    NSUInteger p2Delta = nuP2Score - _p2LastScore;

    self.player1DeltaScore.text = [NSString stringWithFormat:@"+%i", p1Delta];
    self.player2DeltaScore.text = [NSString stringWithFormat:@"+%i", p2Delta];
    _p1LastScore = nuP1Score;
    _p2LastScore = nuP2Score;

    if (nuP1Score > 0 || nuP2Score > 0){        // don't show this, when the game has just begun
        [self showDeltaScores];
    }

    [self repositionScoreColumnsAndLabelsForScore1:[game scoreForColor:0] andScore2:[game scoreForColor:1]];
}

- (void)showDeltaScores {
    self.player1DeltaScore.alpha = 1;
    self.player2DeltaScore.alpha = 1;
    self.player1DeltaScore.hidden = NO;
    self.player2DeltaScore.hidden = NO;

    CGPoint c = self.player1Score.center;
    c.y += self.centerBlock.frame.origin.y + self.player1DeltaScore.bounds.size.height;
    self.player1DeltaScore.center = c;

    c = self.player2Score.center;
    c.y += self.centerBlock.frame.origin.y - self.player2DeltaScore.bounds.size.height;
    self.player2DeltaScore.center = c;

    [UIView animateWithDuration:3 animations:^{
        self.player1DeltaScore.alpha = 0;
        self.player2DeltaScore.alpha = 0;

        CGPoint tC = self.player1Score.center;
        tC.y += self.centerBlock.frame.origin.y;
        self.player1DeltaScore.center = tC;

        tC = self.player2Score.center;
        tC.y += self.centerBlock.frame.origin.y;
        self.player2DeltaScore.center = tC;

    } completion:^(BOOL finished) {
        if (finished){
            self.player1DeltaScore.hidden = YES;
            self.player2DeltaScore.hidden = YES;
        }
    }];
}

@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/18/13.
//


#import "FFTutorial.h"
#import "FFGame.h"
#import "FFGamesCore.h"

#define RADIUS 10

@interface FFTutorialMessage : UIView
@property (weak, nonatomic) UILabel *backText;
@property (weak, nonatomic) UILabel *message;
@property (weak, nonatomic) UILabel *backIndicator;
@property (weak, nonatomic) UILabel *nextIndicator;
@end

@implementation FFTutorialMessage

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor =
                [UIColor colorWithHue:0.20 saturation:0. brightness:0.25 alpha:1];
        self.layer.cornerRadius = RADIUS;

        CGRect messageRect = CGRectMake(30, 0, frame.size.width-60, frame.size.height);
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:messageRect];
        self.message = messageLabel;
        self.message.textAlignment = NSTextAlignmentCenter;
        self.message.backgroundColor = [UIColor clearColor];
        self.message.textColor = [UIColor whiteColor];
        self.message.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:18];
        self.message.numberOfLines = 4;
        self.message.shadowOffset = CGSizeMake(0, 3);
        self.message.shadowColor = [UIColor blackColor];

        UILabel *backTextLabel = [[UILabel alloc] initWithFrame:frame];
        self.backText = backTextLabel;
        backTextLabel.backgroundColor = [UIColor clearColor];
        backTextLabel.textColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        backTextLabel.textAlignment = NSTextAlignmentCenter;
        backTextLabel.adjustsFontSizeToFitWidth = YES;
        backTextLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:68];
        backTextLabel.text = @"TUTORIAL";

        UILabel *back = [[UILabel alloc] initWithFrame:
                CGRectMake(2, CGRectGetMidY(self.bounds)-11, 10, 20)];
        back.textColor = [UIColor colorWithWhite:1 alpha:1];
        back.text = @"<";
        back.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
        back.backgroundColor = [UIColor clearColor];
        back.shadowOffset = CGSizeMake(0, 3);
        back.shadowColor = [UIColor blackColor];
        self.backIndicator = back;

        UILabel *next = [[UILabel alloc] initWithFrame:
                CGRectMake(self.bounds.size.width-12, CGRectGetMidY(self.bounds)-11, 10, 20)];
        next.textColor = [UIColor colorWithWhite:1 alpha:1];
        next.text = @">";
        next.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
        next.backgroundColor = [UIColor clearColor];
        next.shadowOffset = CGSizeMake(0, 3);
        next.shadowColor = [UIColor blackColor];
        self.nextIndicator = next;

        [self addSubview:self.backText];
        [self addSubview:self.message];
        [self addSubview:self.backIndicator];
        [self addSubview:self.nextIndicator];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    NSArray *colors = @[
    [UIColor colorWithHue:0.7 saturation:0.8 brightness:0.8 alpha:1],
            [UIColor colorWithHue:0.7 saturation:0.7 brightness:0.8 alpha:0.9],
            [UIColor colorWithHue:0.7 saturation:0.6 brightness:0.8 alpha:0.8],
            [UIColor colorWithHue:0.7 saturation:0.5 brightness:0.8 alpha:0.7],
            [UIColor colorWithHue:0.7 saturation:0.4 brightness:0.8 alpha:0.6],
            [UIColor colorWithHue:0.7 saturation:0.3 brightness:0.8 alpha:0.5],
    ];

    int count = MIN(colors.count, (NSInteger)(self.bounds.size.height/(2* RADIUS)));

    CGRect circleRect = CGRectMake(0, 0, 2*RADIUS, 2*RADIUS);
    for (NSUInteger i = 0; i < count; i++){
        circleRect.origin.x = 0;
        circleRect.origin.y = i*2*RADIUS;
        for (int x = 0; x <= rect.size.width; x+=2*RADIUS){
            CGContextAddEllipseInRect(context, circleRect);
            circleRect.origin.x = x;
        }
        CGContextSetFillColorWithColor(context, [(UIColor *)[colors objectAtIndex:i] CGColor]);
        CGContextFillPath(context);
    }

    CGContextRestoreGState(context);
}

@end



@interface FFTutorial () <UIScrollViewDelegate>

@property (copy, nonatomic) NSString *gameId;
@property (strong, nonatomic) NSMutableArray *tutorialMessages;
@property (weak, nonatomic) UIScrollView *scrollView;

@end

@implementation FFTutorial

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.tutorialMessages = [[NSMutableArray alloc] initWithCapacity:5];

        UIScrollView *contentScroller = [[UIScrollView alloc] initWithFrame:self.bounds];
        contentScroller.pagingEnabled = YES;
        contentScroller.showsHorizontalScrollIndicator = NO;
        contentScroller.showsVerticalScrollIndicator = NO;
        [self addSubview:contentScroller];
        self.scrollView = contentScroller;

        [self.scrollView setDelegate:self];

        UISwipeGestureRecognizer *downSwiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(downSwipe)];
        downSwiper.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:downSwiper];
    }

    return self;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self vanishIfDone];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self vanishIfDone];
}

- (void)vanishIfDone {
    if (self.scrollView.contentOffset.x <
            self.scrollView.contentSize.width - self.scrollView.bounds.size.width -1) return;
    [self disappear];
}

- (void)downSwipe {
    [self disappear];
}

- (void)showForChallenge:(FFGame*)game {
    if (!game){
        if (!self.hidden) self.hidden = YES;
        self.gameId = nil;
        return;
    }

    if (![game.Id isEqualToString:[[FFGamesCore instance] challenge:0].Id]){
        // tutorial only for the first puzzle!
        self.hidden = YES;
        return;
    }

    if ([self.gameId isEqualToString:game.Id]) return;
    self.hidden = NO;

    [self removeOldMessages];

    NSArray *tutTexts = [self messagesForGame:game];

    CGPoint nowCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    for (NSUInteger i = 0; i < tutTexts.count; i++){
        FFTutorialMessage *message = [[FFTutorialMessage alloc] initWithFrame:self.bounds];
        message.message.text = [(NSString*)[tutTexts objectAtIndex:i] uppercaseString];
        message.center = nowCenter;
        message.backIndicator.hidden = (i==0);
        message.nextIndicator.text = (i==tutTexts.count-1) ? @"|" : @">";
        nowCenter.x += self.bounds.size.width;

        [self.scrollView addSubview:message];
        [self.tutorialMessages addObject:message];
    }

    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width*(tutTexts.count+1), 1);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.gameId = game.Id;

    [self appear];
}

- (void)appear {
    CGRect frame = self.frame;
    frame.origin.y = self.superview.bounds.size.height;
    self.frame = frame;
    [UIView animateWithDuration:0.7 animations:^{
        CGRect targetFrame = self.frame;
        targetFrame.origin.y = self.superview.frame.size.height - self.frame.size.height;
        self.frame = targetFrame;
    }];
}

- (void)disappear {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect targetFrame = self.frame;
        targetFrame.origin.y = self.superview.frame.size.height;
        self.frame = targetFrame;
    } completion:^(BOOL finished) {
        if (finished) self.hidden = YES;
    }];
}

- (NSArray *)messagesForGame:(FFGame *)game {
    return @[
            NSLocalizedString(@"tut_1", nil), NSLocalizedString(@"tut_2", nil),
            NSLocalizedString(@"tut_3", nil), NSLocalizedString(@"tut_4", nil),
            NSLocalizedString(@"tut_5", nil), NSLocalizedString(@"tut_6", nil)
    ];
}

- (void)removeOldMessages {
    for (FFTutorialMessage *message in self.tutorialMessages) {
        [message removeFromSuperview];
    }
    [self.tutorialMessages removeAllObjects];
}

@end
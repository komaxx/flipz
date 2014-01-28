//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 1/23/14.
//


#import "FFLevelStrip.h"

#define DEFAULT_DISAPPEAR_DELAY 2
#define RADIUS 10

@interface FFLevelStrip ()

@property (weak, nonatomic) UILabel *label;

@end

@implementation FFLevelStrip {
}

+ (FFLevelStrip*)make:(NSInteger)number {
    FFLevelStrip *ret = [[FFLevelStrip alloc] init];

    UILabel *label = [[UILabel alloc] init];
    ret.label = label;
    ret.label.text = [NSString stringWithFormat:NSLocalizedString(@"now_level_strip", nil), number];
    ret.label.userInteractionEnabled = NO;
    [ret addSubview:ret.label];

    ret.disappearTime = DEFAULT_DISAPPEAR_DELAY;

    return ret;
}

- (void)show {
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor whiteColor];
    self.label.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:25];
    self.label.opaque = NO;
    self.label.backgroundColor = nil;
    self.label.numberOfLines = 1;
    self.label.shadowOffset = CGSizeMake(0, 3);
    self.label.shadowColor = [UIColor blackColor];

    // size me
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    self.bounds = CGRectMake(0, 0, 800, 80);

    // fit the background
//    self.stripBackground.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

    // fit the label
    self.label.bounds = CGRectMake(0, 0, window.frame.size.width - 40, 70);
    self.label.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2);

    // add to view tree
    [window addSubview:self];

    // make appear
    CGPoint targetPoint = CGPointMake(
            window.frame.size.width/2 + 10,
            190);

    self.alpha = 0;
    self.center = CGPointMake(window.frame.size.width + self.bounds.size.width/2, targetPoint.y);

    [UIView animateWithDuration:0.2 animations:^{ self.center = targetPoint; }];
    [UIView animateWithDuration:0.3 animations:^{ self.alpha = 1; }
                     completion:^(BOOL finished) { [self triggerSlowFade];  }];

    // schedule disappear
    [self performSelector:@selector(disappear) withObject:self afterDelay:self.disappearTime];
}

- (void)triggerSlowFade {
    CGPoint nowCenter = self.center;

    [UIView animateWithDuration:(self.disappearTime - 0.3) animations:^{
        self.center = CGPointMake(nowCenter.x-20, nowCenter.y);
    }];
}

- (void)disappear {
    CGPoint nowCenter = self.center;

    [UIView animateWithDuration:0.2 animations:^{
        self.center = CGPointMake(-self.frame.size.width/2, nowCenter.y);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 10/11/13.
//


#import "FFToast.h"
#import <QuartzCore/QuartzCore.h>

#define DEFAULT_DISAPPEAR_DELAY 2
#define RADIUS 10

@interface FFToastBackgroundView : UIView
@end

@implementation FFToastBackgroundView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor colorWithHue:0.20 saturation:0. brightness:0.25 alpha:1];
        self.layer.cornerRadius = RADIUS;
    }

    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    CGFloat hue = 0;
    CGFloat alpha = 0.8;

    NSArray *colors = @[
            [UIColor colorWithHue:hue saturation:0. brightness:0.6 alpha:alpha],
            [UIColor colorWithHue:hue saturation:0. brightness:0.5 alpha:alpha],
            [UIColor colorWithHue:hue saturation:0. brightness:0.4 alpha:alpha],
            [UIColor colorWithHue:hue saturation:0. brightness:0.3 alpha:alpha],
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


@interface FFToast ()

@property (weak, nonatomic) UILabel *label;
@property (weak, nonatomic) FFToastBackgroundView *toastBackground;

@end


@implementation FFToast {}

+ (FFToast *)make:(NSString *)text {
    FFToast *ret = [[FFToast alloc] init];
    ret.opaque = YES;

    FFToastBackgroundView *toastBackground = [[FFToastBackgroundView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    ret.toastBackground.userInteractionEnabled = NO;
    ret.toastBackground = toastBackground;
    [ret addSubview:ret.toastBackground];

    UILabel *label = [[UILabel alloc] init];
    ret.label = label;
    ret.label.text = text;
    ret.label.userInteractionEnabled = NO;
    [ret addSubview:ret.label];

    ret.disappearTime = DEFAULT_DISAPPEAR_DELAY;

    return ret;
}

- (void)show {
    // style me
    self.backgroundColor = nil;
    self.opaque = YES;

    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor whiteColor];
    self.label.font = [UIFont boldSystemFontOfSize:17];
    self.label.opaque = NO;
    self.label.backgroundColor = nil;
    self.label.numberOfLines = 4;
    self.label.shadowOffset = CGSizeMake(0, 3);
    self.label.shadowColor = [UIColor blackColor];

    // size me
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    self.bounds = CGRectMake(0, 0, window.frame.size.width, 100);

    // fit the background
    self.toastBackground.frame = CGRectMake(
            0, self.bounds.size.height-100, window.frame.size.width, 100);

    // fit the label
    self.label.bounds = CGRectMake(0, 0, window.frame.size.width - 40, 90);
    self.label.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2 - 10);

    // add to view tree
    [window addSubview:self];

    // make appear
    CGPoint targetPoint = CGPointMake(
            window.frame.origin.x + window.frame.size.width/2,
            window.frame.size.height - self.bounds.size.height/2);

    self.alpha = 0;
    self.center = CGPointMake(targetPoint.x, window.frame.size.height + 0.5 * self.bounds.size.height);

    [UIView animateWithDuration:0.2 animations:^{ self.center = targetPoint; }];
    [UIView animateWithDuration:0.3 animations:^{ self.alpha = 1; }
                     completion:^(BOOL finished) { [self triggerSlowFade];  }];

    // schedule disappear
    [self performSelector:@selector(disappear) withObject:self afterDelay:self.disappearTime];
}

- (void)triggerSlowFade {
    CGPoint nowCenter = self.center;

    [UIView animateWithDuration:(self.disappearTime - 0.3) animations:^{
        self.center = CGPointMake(nowCenter.x, nowCenter.y + 8);
    }];
}

- (void)disappear {
    CGPoint nowCenter = self.center;

    [UIView animateWithDuration:0.2 animations:^{
        self.center = CGPointMake(nowCenter.x, nowCenter.y + 2*self.bounds.size.height);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end
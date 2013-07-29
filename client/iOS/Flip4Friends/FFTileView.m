//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/14/13.
//


#import "FFTileView.h"
#import "QuartzCore/QuartzCore.h"

@interface  FFTileView ()

@property (weak, nonatomic) UIView *white;
@property (weak, nonatomic) UIView *black;

@end

@implementation FFTileView {
    NSInteger _currentColor;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0;

        CALayer* layer = self.layer;

        layer.cornerRadius = 3;
        layer.masksToBounds = YES;
        layer.backgroundColor = [[UIColor clearColor] CGColor];
//        layer.borderWidth = 1;
//        layer.borderColor = [[UIColor grayColor] CGColor];

        CATransform3D perspective = CATransform3DIdentity;
        perspective.m34 = -1.0 / 1200.0;
        layer.sublayerTransform = perspective;


        UIView* whiteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"white_pattern.png"]];
        whiteView.frame = CGRectMake(0, 0, 200, 200);
//        UIView* whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
//        whiteView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        self.white.alpha = 0;
        [self addSubview:whiteView];
        self.white = whiteView;

        UIView* blackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black_pattern.png"]];
        blackView.frame = CGRectMake(0, 0, 200, 200);
//        UIView* blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1000, 1000)];
//        blackView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        [self addSubview:blackView];
        self.black.alpha = 0;
        self.black = blackView;
    }

    return self;
}


- (void)updateFromTile:(FFTile *)tile {
//    if (tile.color == _currentColor) return;
    _currentColor = tile.color;

    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0 / 1200.0;
    self.layer.sublayerTransform = perspective;
    self.white.layer.sublayerTransform = perspective;
    self.black.layer.sublayerTransform = perspective;

    [UIView animateWithDuration:1 animations:^{
        self.white.alpha = tile.color==0 ? 1.0 : 0.0;
        self.black.alpha = tile.color==1 ? 1.0 : 0.0;
        self.layer.transform =
                        CATransform3DMakeRotation(tile.color * (CGFloat) M_PI, 1, 0, 0);
    }];
}

- (void)positionAt:(CGRect)rect {
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = CGRectInset(rect, 1, 1);
        self.white.frame = CGRectMake(0, 0, rect.size.width-2, rect.size.height-2);
        self.black.frame = CGRectMake(0, 0, rect.size.width-2, rect.size.height-2);
        self.alpha = 1;         // will make the tile appear in case it was invisible before.
    }];
}


- (void)removeYourself {
    CGRect targetRect = CGRectMake(CGRectGetMidX(self.superview.bounds), CGRectGetMidY(self.superview.bounds), 1, 1);
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
        self.frame = targetRect;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];

    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.26];
}

@end
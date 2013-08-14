//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 6/14/13.
//


#import "FFBoardView.h"
#import "FFTileViewMultiStated.h"
#import "QuartzCore/QuartzCore.h"
#import "FFBoard.h"

@interface FFTileViewMultiStated ()

@property (strong, nonatomic) CAShapeLayer *patternLayer;

@end

@implementation FFTileViewMultiStated {
    NSInteger _currentColor;
    CGFloat _currentRotation;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0;
        self.opaque = YES;

        self.layer.cornerRadius=3;
        self.backgroundColor = [UIColor whiteColor];

        self.patternLayer = [[CAShapeLayer alloc] init];
        self.patternLayer.fillColor = [[UIColor colorWithWhite:0 alpha:0.4] CGColor];
        [self.layer addSublayer:self.patternLayer];
        self.patternLayer.hidden = YES;
    }

    return self;
}


- (void)updateFromTile:(FFTile *)tile {
    if (_currentColor != tile.color){
//        _currentRotation += M_PI;
//        NSLog(@"color : %i, from _rotation: %f to %f", tile.color, _currentRotation, (CGFloat) (tile.color%2==1 ? M_PI : 0));

        _currentRotation = (CGFloat) (tile.color%2==1 ? M_PI : 0);
    }
    _currentColor = tile.color;

    if (self.tileType == kFFBoardType_twoStated){
        [UIView animateWithDuration:1 animations:^{
            self.backgroundColor = [UIColor colorWithWhite:tile.color%2==0?1:0 alpha:1];
            self.layer.transform = CATransform3DMakeRotation(_currentRotation, 1, 0, 0);
        }];
    } else {
        [UIView animateWithDuration:1 animations:^{
            self.backgroundColor = [UIColor colorWithWhite:1.0 - MIN(tile.color/3.0, 1)*0.8  alpha:1];
            self.layer.transform = CATransform3DMakeRotation(_currentRotation, 1, 0, 0);
        }];
    }

    [self performSelector:@selector(updateTileImage) withObject:nil afterDelay:0.5];
}

- (void)updateTileImage {
    if (_currentColor == 0 || self.tileType == kFFBoardType_twoStated){
        self.patternLayer.hidden = YES;
        return;
    }

    CGFloat width = self.bounds.size.width / 6;
    CGMutablePathRef path = CGPathCreateMutable();

    if (_currentColor == 1){
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) - width/2, 0, width, self.bounds.size.height));
    } else if (_currentColor == 2){
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) - 3*width/2, 0, width, self.bounds.size.height));
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) + width/2, 0, width, self.bounds.size.height));
    } else if (_currentColor == 3){
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) - 3*width/2, 0, width, self.bounds.size.height));
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) + width/2, 0, width, self.bounds.size.height));
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(0, CGRectGetMidY(self.bounds) - width/2, self.bounds.size.height, width));
    } else if (_currentColor > 3){
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) - 3*width/2, 0, width, self.bounds.size.height));
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) + width/2, 0, width, self.bounds.size.height));

        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(0, CGRectGetMidY(self.bounds) - 3*width/2, self.bounds.size.height, width));
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(0, CGRectGetMidY(self.bounds) + width/2, self.bounds.size.height, width));
    }

    [self.patternLayer setPath:path];
    self.patternLayer.hidden = NO;
}

- (void)positionAt:(CGRect)rect {
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = CGRectInset(rect, 1, 1);
        self.alpha = 1;         // will make the tile appear in case it was invisible before.
    } completion:^(BOOL finished) {
        [self updateTileImage];
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
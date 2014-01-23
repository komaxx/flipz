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
@property (strong, nonatomic) CAShapeLayer *lockedLayer;
@property (strong, nonatomic) CAShapeLayer *doubleLockedLayer;

@end

@implementation FFTileViewMultiStated {
    NSInteger _currentColor;
    CGFloat _currentRotation;
    BOOL _currentlyLocked;
    BOOL _currentlyDoubleLocked;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0;
        self.opaque = YES;

        self.turnSpeed = 0.5;

        self.layer.cornerRadius=3;
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = NO;

        self.lockedLayer = [[CAShapeLayer alloc] init];
        self.lockedLayer.strokeColor = [[UIColor colorWithRed:1 green:0 blue:0 alpha:0.5] CGColor];
        self.lockedLayer.lineCap = @"round";
        [self.layer addSublayer:self.lockedLayer];
        self.lockedLayer.hidden = YES;

        self.doubleLockedLayer = [[CAShapeLayer alloc] init];
        self.doubleLockedLayer.strokeColor = [[UIColor colorWithRed:1 green:0 blue:0 alpha:0.5] CGColor];
        self.doubleLockedLayer.lineCap = @"round";
        [self.layer addSublayer:self.doubleLockedLayer];
        self.doubleLockedLayer.hidden = YES;

        self.patternLayer = [[CAShapeLayer alloc] init];
        self.patternLayer.fillColor = [[UIColor colorWithWhite:0 alpha:0.4] CGColor];
        [self.layer addSublayer:self.patternLayer];
        self.patternLayer.hidden = YES;

        _currentlyLocked = NO;
    }

    return self;
}

- (BOOL)updateFromTile:(FFTile *)tile {
    BOOL ret = NO;

    if (_currentColor != tile.color){
        _currentRotation = (CGFloat) (tile.color%2==1 ? M_PI : 0);
        ret = YES;
    }
    _currentColor = tile.color;

    if (_currentlyLocked && !tile.nowLocked){
        [UIView animateWithDuration:0.3 animations:^{
            self.lockedLayer.lineWidth = 0;
        } completion:^(BOOL finished) {
            if (!_currentlyLocked) self.lockedLayer.hidden = YES;
        }];
    }
    _currentlyLocked = tile.nowLocked;


    if (_currentlyDoubleLocked && !tile.doubleLocked){
        [UIView animateWithDuration:0.3 animations:^{
            self.doubleLockedLayer.lineWidth = 0;
        } completion:^(BOOL finished) {
            if (!_currentlyDoubleLocked) self.doubleLockedLayer.hidden = YES;
        }];
    }
    _currentlyDoubleLocked = tile.doubleLocked;


    if (self.tileType == kFFBoardType_twoStated){
        [UIView animateWithDuration:self.turnSpeed animations:^{
            self.backgroundColor = [UIColor colorWithWhite:tile.color%2==0?1:0 alpha:1];
            self.layer.transform = CATransform3DMakeRotation(_currentRotation, 1, 0, 0);
        }];
    } else {
        [UIView animateWithDuration:self.turnSpeed animations:^{
            self.backgroundColor = [UIColor colorWithWhite:1.0 - MIN(tile.color/3.0, 1)*0.8  alpha:1];
            self.layer.transform = CATransform3DMakeRotation(_currentRotation, 1, 0, 0);
        }];
    }

    [self performSelector:@selector(updateTileImage) withObject:nil afterDelay:(self.turnSpeed / 2.0f)];
    return ret;
}

- (void)updateTileImage {
    CGFloat width = self.bounds.size.width / 6;
    if (_currentlyLocked){
        self.lockedLayer.lineWidth = width;
    }
    if (_currentlyDoubleLocked){
        self.doubleLockedLayer.lineWidth = width;
    }

    self.lockedLayer.hidden = !_currentlyLocked;
    self.doubleLockedLayer.hidden = !_currentlyDoubleLocked;
    if (_currentColor == 0 || self.tileType == kFFBoardType_twoStated){
        self.patternLayer.hidden = YES;
        return;
    }

    CGMutablePathRef path = CGPathCreateMutable();

    if (_currentColor == 1){
        width = self.bounds.size.width / 3;

        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) - width/2, 0, width, self.bounds.size.height));
    } else if (_currentColor == 2){
        width = self.bounds.size.width / 5;

        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) - 3*width/2, 0, width, self.bounds.size.height));
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) + width/2, 0, width, self.bounds.size.height));
    } else if (_currentColor == 3){
        width = self.bounds.size.width / 5;

        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) - 3*width/2, 0, width, self.bounds.size.height));
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) + width/2, 0, width, self.bounds.size.height));
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(0, CGRectGetMidY(self.bounds) - width/2, self.bounds.size.height, width));
    } else if (_currentColor == 4){
        width = self.bounds.size.width / 5;

        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) - 3*width/2, 0, width, self.bounds.size.height));
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) + width/2, 0, width, self.bounds.size.height));

        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(0, CGRectGetMidY(self.bounds) - 3*width/2, self.bounds.size.height, width));
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(0, CGRectGetMidY(self.bounds) + width/2, self.bounds.size.height, width));
    } else if (_currentColor > 4){
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) - 3*width/2, 0, width, self.bounds.size.height));
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(CGRectGetMidX(self.bounds) + width/2, 0, width, self.bounds.size.height));

        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(0, CGRectGetMidY(self.bounds) - 3*width/2, self.bounds.size.height, width));
        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(0, CGRectGetMidY(self.bounds) + width/2, self.bounds.size.height, width));

        CGPathAddRect(path, &CGAffineTransformIdentity,
                CGRectMake(width, width, self.bounds.size.width-2*width, self.bounds.size.height-2*width));
    }

    [self.patternLayer setPath:path];
    CGPathRelease(path);
    self.patternLayer.hidden = NO;
}

- (void)positionAt:(CGRect)rect {
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = CGRectInset(rect, 1, 1);
        self.alpha = 1;         // will make the tile appear in case it was invisible before.
    } completion:^(BOOL finished) {
        [self updateTileImage];
        [self resetLockedLayer];
    }];
}

- (void)resetLockedLayer {
    CGFloat lineWidth = self.bounds.size.width / 6;
    self.lockedLayer.lineWidth = lineWidth;
    self.doubleLockedLayer.lineWidth = lineWidth;

    // single locked
    CGMutablePathRef path = CGPathCreateMutable();

    CGPathMoveToPoint(path, &CGAffineTransformIdentity, lineWidth, lineWidth);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity,
            self.bounds.size.width-lineWidth, self.bounds.size.height-lineWidth);

    CGPathMoveToPoint(path, &CGAffineTransformIdentity, lineWidth, self.bounds.size.height-lineWidth);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, self.bounds.size.width-lineWidth, lineWidth);

    [self.lockedLayer setPath:path];
    CGPathRelease(path);

    // >= double locked
    path = CGPathCreateMutable();

    CGPathMoveToPoint(path, &CGAffineTransformIdentity, self.bounds.size.width/2, lineWidth);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, self.bounds.size.width/2, self.bounds.size.height-lineWidth);

    CGPathMoveToPoint(path, &CGAffineTransformIdentity, lineWidth, self.bounds.size.height/2);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, self.bounds.size.width-lineWidth, self.bounds.size.height/2);

    [self.doubleLockedLayer setPath:path];
    CGPathRelease(path);
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
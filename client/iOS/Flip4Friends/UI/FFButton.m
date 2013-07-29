//
//  FFButton.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 7/28/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FFButton.h"

@interface FFButton()
@property (strong, nonatomic) UIColor *backColor;
@property (strong, nonatomic) UIColor *backColorHighlighted;
@end

@implementation FFButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.cornerRadius = 20;

        self.backColor = [UIColor colorWithHue:230.0/360 saturation:0.7 brightness:0.5 alpha:1];
        self.backColorHighlighted = [UIColor colorWithHue:230.0/360 saturation:0.9 brightness:0.7 alpha:1];

        self.layer.borderWidth = 5;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.backgroundColor = self.backColor;

        self.layer.shadowOpacity = 1;
        self.layer.shadowOffset = CGSizeMake(0, 5);
        self.layer.shadowRadius = 0;
        self.layer.shadowColor = [self.backColor CGColor];

        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];

        [self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

        [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchCancel];
        [self addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchDragExit];
        [self addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchUpOutside];
    }

    return self;
}

- (void)touchCancel:(id)touchCancel {
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.backgroundColor = self.backColor;
    self.layer.shadowColor = [self.backColor CGColor];
}

- (void)touchDown:(id)touchDown {
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.shadowColor = [self.backColorHighlighted CGColor];
    self.backgroundColor = self.backColorHighlighted;
}

@end

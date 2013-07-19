//
//  FFViewController.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFViewController.h"
#import "FFBoardView.h"
#import "FFGameViewController.h"

@interface FFViewController ()

@property (weak, nonatomic) IBOutlet FFGameViewController *gameViewController;

@end

@implementation FFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.gameViewController didLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.gameViewController didAppear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.gameViewController didDisappear];
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setGameViewController:nil];
    [self setGameViewController:nil];
    [super viewDidUnload];
}
@end

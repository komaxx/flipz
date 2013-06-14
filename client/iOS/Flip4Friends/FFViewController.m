//
//  FFViewController.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFViewController.h"
#import "FFBoardView.h"
#import "FFGame.h"

@interface FFViewController ()

@property (weak, nonatomic) IBOutlet FFBoardView *boardView;

@end

@implementation FFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.boardView didAppear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.boardView didDisappear];
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBoardView:nil];
    [super viewDidUnload];
}
@end

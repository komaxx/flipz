//
//  FFViewController.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFViewController.h"
#import "FFGamesCore.h"

@interface FFViewController ()

@property (weak, nonatomic) IBOutlet FFGameViewController *gameViewController;
@property (weak, nonatomic) IBOutlet FFMenuViewController *menuViewController;

@property (copy, nonatomic, readwrite) NSString *activeGameId;


@end

@implementation FFViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.gameViewController.delegate = self;
    self.menuViewController.delegate = self;

    [self.gameViewController didLoad];
    [self.menuViewController didLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.gameViewController didAppear];
    [self.menuViewController didAppear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.gameViewController didDisappear];
    [self.menuViewController didDisappear];

    [super viewDidDisappear:animated];
}

- (void)activateGameWithId:(NSString *)gameId {
    self.activeGameId = gameId;
    [self.gameViewController selectedGameWithId:gameId];
}

- (void)undoTapped {
    [self.gameViewController undo];
}


- (void)restartCurrentGame {
    [self.gameViewController selectedGameWithId:self.activeGameId];
}

- (void)cleanCurrentGame {
    [self.gameViewController gameCleaned];
}

- (NSString *)activeGameId {
    return _activeGameId;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setGameViewController:nil];
    [self setMenuViewController:nil];

    [super viewDidUnload];
}
@end

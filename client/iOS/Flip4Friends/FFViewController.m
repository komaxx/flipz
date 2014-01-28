//
//  FFViewController.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "FFViewController.h"
#import "FFToast.h"
#import "FFStorageUtil.h"

@interface FFViewController () <UIAlertViewDelegate>

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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)gotoStore {
    [self performSegueWithIdentifier:@"storeSegue" sender:self];
}

- (void)openFeedbackForm {
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:NSLocalizedString(@"feedback_subject_line", nil)];
        [mc setToRecipients:@[@"flipz@poroba.com"]];

        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    } else {
        [[FFToast make:@"This only works with your email account - which is missing :/"] show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
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

//
//  FFStoreViewController.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 11/29/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import "FFStoreViewController.h"
#import "Flurry.h"
#import "FFAnalytics.h"

@interface FFStoreViewController ()

@property (weak, nonatomic) IBOutlet UILabel *youGetLabel;
@property (weak, nonatomic) IBOutlet UIButton *alreadyPaidButton;

@end

@implementation FFStoreViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.youGetLabel.text = NSLocalizedString(@"you_get_label", nil);
    [self.alreadyPaidButton setTitle:NSLocalizedString(@"already_paid", nil) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [FFAnalytics log:@"STORE_ENTERED"];
}


- (IBAction)backButtonTapped:(id)sender {
    [FFAnalytics log:@"STORE_QUIT"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)alreadyUnlockedButton:(id)sender {
    [FFAnalytics log:@"STORE_ALREADY_UNLOCKED_TAPPED"];
}

- (IBAction)unlockButtonTapped:(id)sender {
    [FFAnalytics log:@"STORE_UNLOCK_NOW_TAPPED"];
}

@end

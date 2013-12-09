//
//  FFStoreViewController.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 11/29/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "FFStoreViewController.h"
#import "FFAnalytics.h"
#import "FFStoreDataHandler.h"
#import "FFAppDelegate.h"

@interface FFStoreViewController () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *youGetLabel;
@property (weak, nonatomic) IBOutlet UIButton *alreadyPaidButton;

@property (weak, nonatomic) IBOutlet UIView *activityOverlay;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@property (weak, nonatomic) IBOutlet UIView *unlockingOverlay;
@property (weak, nonatomic) IBOutlet UILabel *unlockingLabel;

@property (weak, nonatomic) IBOutlet UIView *thankYouOverlay;
@property (weak, nonatomic) IBOutlet UILabel *thankYouLabel;
@property (weak, nonatomic) IBOutlet UIButton *thankYouPlayButton;

@end

@implementation FFStoreViewController {
    UnlockingState _lastUnlockingState;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.youGetLabel.text = NSLocalizedString(@"you_get_label", nil);
    [self.alreadyPaidButton setTitle:NSLocalizedString(@"already_paid", nil) forState:UIControlStateNormal];

    self.thankYouLabel.text = NSLocalizedString(@"thank_you_message", nil);

    self.thankYouOverlay.hidden = YES;
    self.unlockingOverlay.hidden = YES;
    self.activityOverlay.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [FFAnalytics log:@"STORE_ENTERED"];

    [self dataChanged];

    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(dataChanged)
                   name:FFStoreDataHandlerNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dataChanged {
    [self updatePrize];
    [self updateBasicLoadingOverlay];
    [self updateUnlockingOverlay];
}

- (void)updateUnlockingOverlay {
    if ([self dataHandler].unlockingState == kFFUnlockingState_Unlocking){
        self.unlockingOverlay.hidden = NO;
    } else {
        self.unlockingOverlay.hidden = YES;

        if (_lastUnlockingState != kFFUnlockingState_Unlocked
                && [self dataHandler].unlockingState== kFFUnlockingState_Unlocked){
            [self showThankYouMessage];
        }

        if (_lastUnlockingState != kFFUnlockingState_Failed
                && [self dataHandler].unlockingState== kFFUnlockingState_Failed){
            UIAlertView *alertView = [[UIAlertView alloc]
                    initWithTitle:NSLocalizedString(@"dialog_title_unlocking_failed", nil)
                          message:NSLocalizedString(@"dialog_unlocking_failed", nil)
                         delegate:self
                cancelButtonTitle:NSLocalizedString(@"thats_some_bullshit", nil) otherButtonTitles:nil];
            [alertView show];
        }
    }

    _lastUnlockingState = [self dataHandler].unlockingState;
}

- (void)showThankYouMessage {
    self.thankYouOverlay.hidden = NO;
}

- (void)updateBasicLoadingOverlay {
    if ([self dataHandler].basicLoadingState == kFFLoadingState_Loading){
        self.activityOverlay.hidden = NO;
    } else {
        self.activityOverlay.hidden = YES;

        if ([self dataHandler].basicLoadingState == kFFLoadingState_Failed){
            UIAlertView *alertView = [[UIAlertView alloc]
                    initWithTitle:NSLocalizedString(@"dialog_title_could_not_access_store", nil)
                          message:NSLocalizedString(@"dialog_could_not_access_store", nil)
                         delegate:self
                cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                otherButtonTitles:NSLocalizedString(@"try_again", nil), nil];
            [alertView show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0){
        [self backButtonTapped:nil];
    } else {
        [[self dataHandler] fetchBasicData];
    }
}
- (void)alertViewCancel:(UIAlertView *)alertView {
    [self backButtonTapped:nil];
}


- (void)updatePrize {
    NSString *priceText = @"...";

    if ([self dataHandler].product){
        // Add new instance variable to class extension
        NSNumberFormatter * _priceFormatter = [[NSNumberFormatter alloc] init];
        [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];

        [_priceFormatter setLocale:[self dataHandler].product.priceLocale];
        priceText =
                [NSString stringWithFormat:NSLocalizedString(@"btn_unlock_now", nil),
                                [_priceFormatter stringFromNumber:[self dataHandler].product.price]];
    }

    for (int i = 50; i <= 53; i++){
        ((UILabel *)[self.view viewWithTag:i]).text = priceText;
    }
}

- (IBAction)playTapped:(id)sender {
    [self backButtonTapped:nil];
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

    [[self dataHandler] unlockNow];
    // the view will be update by the triggered notification!
}

- (FFStoreDataHandler *) dataHandler {
    return [(FFAppDelegate *) [[UIApplication sharedApplication] delegate] dataHandler];
}

@end

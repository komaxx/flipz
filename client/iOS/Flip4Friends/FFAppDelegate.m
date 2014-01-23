//
//  FFAppDelegate.m
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "FFAppDelegate.h"
#import "FFAnalytics.h"
#import "FFStoreDataHandler.h"
#import "FFStorageUtil.h"
#import "FFToast.h"


#define NEW_LAUNCH_TIME_INTERVAL 5*60
#define TIMES_TO_OPEN_UNTIL_RATING_REQUEST 3


@interface FFAppDelegate () <UIAlertViewDelegate>
@property (readwrite, strong, nonatomic) FFStoreDataHandler* dataHandler;
@end

@implementation FFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FFAnalytics appDidLoad];

    self.dataHandler = [[FFStoreDataHandler alloc] init];
    [self.dataHandler fetchBasicData];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    [FFStorageUtil setLastAppBackgroundTime:[[NSDate date] timeIntervalSince1970]];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    double timeSinceLastBackground = [[NSDate date] timeIntervalSince1970] - [FFStorageUtil getLastAppBackgroundTime];
    if (timeSinceLastBackground > NEW_LAUNCH_TIME_INTERVAL){
        [FFStorageUtil setTimesAppOpened:[FFStorageUtil getAppTimesOpened] + 1];
    }


    if ([FFStorageUtil rateRequestDialogFinished]){
        NSLog(@"request dialog already finished.");
    } else {
        NSLog(@"request dialog not yet finished.");
    }
    NSLog(@"app times opened: %i", [FFStorageUtil getAppTimesOpened]);

    if (![FFStorageUtil rateRequestDialogFinished]
            && [FFStorageUtil getAppTimesOpened] >= TIMES_TO_OPEN_UNTIL_RATING_REQUEST){
        [self showRatingRequestDialog];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// //////////////////////////////////////////////////////////////////////////////////
// rating dialog

- (void)showRatingRequestDialog {
    UIAlertView *rateRequestDialog = [[UIAlertView alloc]
            initWithTitle:NSLocalizedString(@"rate_request_dialog_title", nil)
                  message:NSLocalizedString(@"rate_request_dialog_message", nil)
                 delegate:self
        cancelButtonTitle:NSLocalizedString(@"no", nil)
        otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
    [rateRequestDialog show];

    [FFAnalytics log:@"RATE_DIALOG_SHOWN"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:NSLocalizedString(@"rate_request_dialog_title", nil)]){
        if (buttonIndex == 0){
            // NO, don't like it
            UIAlertView *dontLikeItDialog = [[UIAlertView alloc]
                    initWithTitle:NSLocalizedString(@"dont_like_it_dialog_title", nil)
                          message:NSLocalizedString(@"dont_like_it_dialog_message", nil)
                         delegate:self
                cancelButtonTitle:NSLocalizedString(@"later", nil)
                otherButtonTitles:NSLocalizedString(@"feedback", nil),
                                  NSLocalizedString(@"dont_ask_again", nil),
                                  nil];
            [dontLikeItDialog show];
            [FFAnalytics log:@"RATE_DIALOG_LIKE_NO"];
        } else {
            // YES, like it :)
            UIAlertView *likeItDialog = [[UIAlertView alloc]
                    initWithTitle:NSLocalizedString(@"like_it_dialog_title", nil)
                          message:NSLocalizedString(@"like_it_dialog_message", nil)
                         delegate:self
                cancelButtonTitle:NSLocalizedString(@"later", nil)
                otherButtonTitles:NSLocalizedString(@"rate_it", nil),
                                  NSLocalizedString(@"dont_ask_again", nil),
                                  nil];
            [likeItDialog show];
            [FFAnalytics log:@"RATE_DIALOG_LIKE_YES"];
        }
    } else if ([alertView.title isEqualToString:NSLocalizedString(@"dont_like_it_dialog_title", nil)]){
        if (buttonIndex == 0){
            [self showRateDialogLaterAgain];
        } else if (buttonIndex == 1){
            [self openFeedbackForm];
        } else {
            [self neverShowRateDialogAgain];
            [FFAnalytics log:@"RATE_DIALOG_NEVER_AGAIN"];
        }
    } else if ([alertView.title isEqualToString:NSLocalizedString(@"like_it_dialog_title", nil)]){
        if (buttonIndex == 0){
            [self showRateDialogLaterAgain];
        } else if (buttonIndex == 1){
            [self openAppStore];
            [self neverShowRateDialogAgain];
        } else {
            [self neverShowRateDialogAgain];
        }
    }
}

- (void)openAppStore {
    [[UIApplication sharedApplication]
            openURL:[NSURL URLWithString:@"itms://itunes.com/apps/flipz"]];
}

- (void)neverShowRateDialogAgain {
    [FFStorageUtil setRateRequestDialogFinished];
}

- (void)showRateDialogLaterAgain {
    [FFAnalytics log:@"RATE_DIALOG_LATER"];
    [FFStorageUtil setTimesAppOpened:0];
}

- (void)openFeedbackForm {
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:NSLocalizedString(@"feedback_subject_line", nil)];
        [mc setToRecipients:@[@"flipz@poroba.com"]];

        // Present mail view controller on screen
        [self.window.rootViewController presentViewController:mc animated:YES completion:NULL];
    } else {
        [[FFToast make:@"This only works with your email account - which is missing :/"] show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    if (result == MFMailComposeResultSent || result == MFMailComposeResultSaved){
        [self neverShowRateDialogAgain];
    } else {
        [self showRateDialogLaterAgain];
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end

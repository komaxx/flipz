//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 12/5/13.
//


#import "FFAnalytics.h"
#import "Flurry.h"


@implementation FFAnalytics {
}

+ (void)appDidLoad {
    NSLog(@"Logging initialized.");

    [Flurry setDebugLogEnabled:YES];

    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"PFNPNQ45HRB6WCVBJQF3"];
}

+ (void)log:(NSString *)event {
    NSLog(@"Logging event: %@", event);
    [Flurry logEvent:event];
}

+ (void)log:(NSString *)event with:(NSDictionary *)data {
    NSLog(@"Logging event: %@ with data: %@", event, data);
    [Flurry logEvent:event withParameters:data];
}


@end
//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 12/5/13.
//


#import "FFAnalytics.h"




@implementation FFAnalytics {
}

+ (void)appDidLoad {
    #ifdef LOGGING
    NSLog(@"Logging initialized.");
    [Flurry setDebugLogEnabled:YES];
    #endif


//    [Flurry setCrashReportingEnabled:YES];
//    [Flurry startSession:@"PFNPNQ45HRB6WCVBJQF3"];
}

+ (void)log:(NSString *)event {
    #ifdef LOGGING
    NSLog(@"Logging event: %@", event);
    #endif

//    [Flurry logEvent:event];
}

+ (void)log:(NSString *)event with:(NSDictionary *)data {
    #ifdef LOGGING
    NSLog(@"Logging event: %@ with data: %@", event, data);
    #endif

//    [Flurry logEvent:event withParameters:data];
}

@end
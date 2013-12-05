//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 12/5/13.
//


#import <Foundation/Foundation.h>

/**
* Facade for some other analytics framework
*/
@interface FFAnalytics : NSObject

/**
* MUST be called at app start.
*/
+ (void) appDidLoad;

+ (void) log:(NSString *)event;

+ (void) log:(NSString *)event with:(NSDictionary *)data;

@end
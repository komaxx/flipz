//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 10/11/13.
//


#import <UIKit/UIKit.h>


@interface FFToast : UIView

+ (FFToast*) make:(NSString *)string;

/**
* How long until the toast disappears. Defaults to 2 seconds
*/
@property (nonatomic) CGFloat disappearTime;

-(void) show;

@end















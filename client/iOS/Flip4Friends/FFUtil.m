//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/15/13.
//


#import "FFUtil.h"


@implementation FFUtil {

}

+ (void)shuffle:(NSMutableArray *)array {
    for (int i = 0; i < array.count; i++){
        [array exchangeObjectAtIndex:arc4random()%array.count withObjectAtIndex:arc4random()%array.count];
    }
}

@end
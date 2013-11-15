//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 11/15/13.
//


#import <Foundation/Foundation.h>

#define CLAMP(x, low, high) ({\
  __typeof__(x) __x = (x); \
  __typeof__(low) __low = (low);\
  __typeof__(high) __high = (high);\
  __x > __high ? __high : (__x < __low ? __low : __x);\
  })

@interface FFUtil : NSObject
@end
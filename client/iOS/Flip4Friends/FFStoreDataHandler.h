//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 12/8/13.
//


#import <Foundation/Foundation.h>
#import <StoreKit/SKProduct.h>

typedef enum {
    kFFLoadingState_Loading, kFFLoadingState_Successful, kFFLoadingState_Failed
} LoadingState;

typedef enum {
    kFFUnlockingState_NotStarted, kFFUnlockingState_Unlocking, kFFUnlockingState_Unlocked, kFFUnlockingState_Failed
} UnlockingState;

extern NSString *const FFStoreDataHandlerNotification;


@interface FFStoreDataHandler : NSObject

@property (strong, nonatomic) SKProduct *product;

@property (nonatomic) LoadingState basicLoadingState;
@property (nonatomic) UnlockingState unlockingState;

- (void)fetchBasicData;
- (void)unlockNow;

@end
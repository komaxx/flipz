//
// Created by Matthias Schicker (matthias@pocketsunited.com)
// on 12/8/13.
//


#import <StoreKit/StoreKit.h>
#import "FFStoreDataHandler.h"
#import "Flurry.h"
#import "FFStorageUtil.h"
#import "FFAnalytics.h"


NSString *const FFStoreDataHandlerNotification = @"StoreDataHandlerNotification";

@interface FFStoreDataHandler() <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (strong, nonatomic) SKProductsRequest *basicDataRequest;

@end



@implementation FFStoreDataHandler

- (id)init {
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

        self.unlockingState = kFFUnlockingState_NotStarted;
        if ([FFStorageUtil isUnlocked]) self.unlockingState = kFFUnlockingState_Unlocked;
    }

    return self;
}

- (void)fetchBasicData {
    if (!self.basicDataRequest){
        NSSet *productIdentifiers = [NSSet setWithObjects:@"Flipz_unlock_1", nil];

        self.basicDataRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
        self.basicDataRequest.delegate = self;

        self.basicLoadingState = kFFLoadingState_Loading;
        [self notifyChange];

        [self.basicDataRequest start];
    }
}

- (void)requestDidFinish:(SKRequest *)request {
    NSLog(@"Request finished");
    self.basicDataRequest = nil;

    self.basicLoadingState = kFFLoadingState_Successful;
    [self notifyChange];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request did fial with error: %@", error.localizedDescription);
    self.basicDataRequest = nil;

    [Flurry
            logError:@"STORE_ERROR"
             message:@"basic product request failed"
           error:error];
    self.basicLoadingState = kFFLoadingState_Failed;
    [self notifyChange];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if (!response.products || response.products.count != 1){
        [Flurry
                logError:@"STORE_ERROR"
                 message:[NSString stringWithFormat:@"Unexpected SKProduct count: %i", response.products.count]
               exception:nil];
        self.product = nil;
    } else {
        self.product = [response.products objectAtIndex:0];

//        NSLog(@"Got product[%@]:\n%@\n%@\nFor:%@ in locale:%@",
//                self.product.productIdentifier,
//                self.product.localizedTitle,
//                self.product.localizedDescription,
//                self.product.price,
//                self.product.priceLocale);
    }

    [self notifyChange];
}

// ///////////////////////////////////////////////////////
// paying

- (void) unlockNow {
    if (!self.product || self.basicLoadingState != kFFLoadingState_Successful){
        NSLog(@"ERROR: Product was not loaded previously");
        return;
    }

    SKPayment * payment = [SKPayment paymentWithProduct:self.product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];

    self.unlockingState = kFFUnlockingState_Unlocking;
    [self notifyChange];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                return;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                return;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                return;
            default:
                break;
        }
    };

    self.unlockingState = kFFUnlockingState_NotStarted;
    [self notifyChange];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"failedTransaction...");

    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);

        [Flurry logError:@"STORE_PAYMENT_FAILED" message:@":(" error:transaction.error];
    } else {
        [FFAnalytics log:@"STORE_PAYMENT_CANCELLED"];
    }

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    self.unlockingState = kFFUnlockingState_Failed;
    [self notifyChange];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    [FFAnalytics log:@"STORE_PAYMENT_COMPLETE"];

    [self unlockComplete];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    [FFAnalytics log:@"STORE_PAYMENT_RESTORED"];

    [self unlockComplete];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)unlockComplete {
    [FFAnalytics log:@"UNLOCK_COMPLETE"];
    [FFStorageUtil unlockThisAwesomeFantasmagon];

    self.unlockingState = kFFUnlockingState_Unlocked;
    [self notifyChange];
}

- (void)notifyChange {
    [[NSNotificationCenter defaultCenter] postNotificationName:FFStoreDataHandlerNotification object:nil userInfo:nil];
}

- (void)restorePreviousTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];

    self.unlockingState = kFFUnlockingState_Unlocking;
    [self notifyChange];
}
@end
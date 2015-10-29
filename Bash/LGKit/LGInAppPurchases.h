//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface LGInAppPurchases : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

+ (instancetype)sharedManager;
- (void)initialize;

- (void)requestProductData;
- (void)loadStore;
- (BOOL)isStoreLoadedWithMessage;
- (BOOL)isStoreLoaded;
- (BOOL)canMakePurchases;
- (void)restoreCompletedTransactions;
- (void)purchaseProduct:(NSString *)productId;
- (SKProduct *)getProduct:(NSString *)productId;

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedManager instead")));

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end
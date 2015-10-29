//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "LGInAppPurchases.h"
#import "LGKit.h"
#import "AppDelegate.h"
#import "LGAdMob.h"
#import "InfoViewController.h"

#pragma mark ----------------------------------------------------------------------------------------------------

@interface LGInAppPurchases ()

@property (assign, nonatomic) BOOL              storeDoneLoading;
@property (strong, nonatomic) SKProductsRequest *productsRequest;
@property (strong, nonatomic) UIAlertView       *progressAlert;
@property (strong, nonatomic) NSMutableArray    *productsArray;

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@implementation LGInAppPurchases

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static id sharedManager = nil;
    
    dispatch_once(&once, ^
                  {
                      sharedManager = [super new];
                  });
    
    return sharedManager;
}

- (id)init
{
    LOG(@"");
    
    if ((self = [super init]))
    {
        NSLog(@"LGInAppPurchases: Shared Manager initialization...");
    }
	return self;
}

- (void)initialize
{
    LOG(@"");
    
    _storeDoneLoading = NO;
    _productsArray = [NSMutableArray new];
    
    [self loadStore];
}

// call this method once on startup
- (void)loadStore
{
    LOG(@"");
    
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    [self requestProductData];
}

- (BOOL)isStoreLoadedWithMessage
{
    LOG(@"");
    
    if (_storeDoneLoading) NSLog(@"LGInAppPurchases: Store is Loaded");
    else
    {
        NSLog(@"LGInAppPurchases: Store is not Loaded");
        
        [kInfoVC showInfoWithText:@"Ошибка соединения.\n•   •   •\nПожалуйста, повторите попытку позже."];
    }
    
	return _storeDoneLoading;
}

- (BOOL)isStoreLoaded
{
    LOG(@"");
    
    if (_storeDoneLoading) NSLog(@"LGInAppPurchases: Store is Loaded");
    else NSLog(@"LGInAppPurchases: Store is not Loaded");
    
	return _storeDoneLoading;
}

// call this before making a purchase
- (BOOL)canMakePurchases
{
    LOG(@"");
    
    if ([SKPaymentQueue canMakePayments]) NSLog(@"LGInAppPurchases: Purchasing Enabled");
    else
    {
        NSLog(@"LGInAppPurchases: Purchasing Disabled");
        
        [kInfoVC showInfoWithText:@"Покупки недоступны.\n•   •   •\nИзмените настройки родительского контроля и попробуйте снова."];
    }
    
    return [SKPaymentQueue canMakePayments];
}

// kick off the upgrade transaction
- (void)purchaseProduct:(NSString *)productId
{
    LOG(@"");
    
    SKPayment *payment = [SKPayment paymentWithProduct:[self getProduct:productId]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    _progressAlert = [[UIAlertView alloc] initWithTitle:@"Подключение к серверу"
                                                message:@"Подключение..."
                                               delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:nil];
    [_progressAlert show];
}

// Restore completed transactions
- (void)restoreCompletedTransactions
{
    LOG(@"");
    
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - In-App Product Accessor Methods

- (SKProduct *)getProduct:(NSString *)productId
{
    LOG(@"");
    
    SKProduct *product;
	
	for (int i=0; i < _productsArray.count; i++)
	{
		product = [_productsArray objectAtIndex:i];
        
        if ([product.productIdentifier isEqualToString:productId]) break;
        else product = nil;
	}
    
    return product;
}

+ (NSMutableArray *)allProductsId
{
    LOG(@"");
    
    NSMutableArray *productsIdArray = [NSMutableArray array];
    NSArray *consumables = [[LGInAppPurchases getItemsDictionary] objectForKey:@"Consumables"];
    NSArray *nonConsumables = [[LGInAppPurchases getItemsDictionary] objectForKey:@"Non-Consumables"];
    
    [productsIdArray addObjectsFromArray:consumables];
    [productsIdArray addObjectsFromArray:nonConsumables];
    
    return productsIdArray;
}

#pragma mark - Product Data

+ (NSDictionary *)getItemsDictionary
{
    LOG(@"");
    
    return [NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LGInAppPurchases.plist"]];
}

- (void)requestProductData
{
    LOG(@"");
    
    NSLog(@"LGInAppPurchases: request product data...");
    
    NSMutableArray *productsIdArray = [NSMutableArray array];
    NSArray *consumables = [[LGInAppPurchases getItemsDictionary] objectForKey:@"Consumables"];
    NSArray *nonConsumables = [[LGInAppPurchases getItemsDictionary] objectForKey:@"Non-Consumables"];
    
    [productsIdArray addObjectsFromArray:consumables];
    [productsIdArray addObjectsFromArray:nonConsumables];
    
    //NSLog(@"%@", productsIdArray);
    
	_productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productsIdArray]];
	_productsRequest.delegate = self;
	[_productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    LOG(@"");
    
    NSArray *purchasableObjects = response.products;
    
    //NSString *baseString = [[LGInAppPurchases getItemsDictionary] objectForKey:@"BaseFeatureIdString"];
    //NSUInteger baseLength = [baseString length];
	
	for (int i=0; i < purchasableObjects.count; i++)
	{
		SKProduct *product = [purchasableObjects objectAtIndex:i];
        [_productsArray addObject:product];
        
        NSString *localizedTitleString = [NSString stringWithFormat:@"%@", [product localizedTitle]];
        NSString *priceString = [NSString stringWithFormat:@"%.2f", [[product price] doubleValue]];
        //NSString *productIdentifierShortString = [NSString stringWithFormat:@"%@", [[product productIdentifier] substringFromIndex:baseLength]];
        NSString *productIdentifierFullString = [NSString stringWithFormat:@"%@", [product productIdentifier]];
        
		NSLog(@"LGInAppPurchases:\nProduct: %@| Price: %@| ID: %@",
              [localizedTitleString stringByAppendingString:[@"                              " substringFromIndex:[localizedTitleString length]]],
              [priceString stringByAppendingString:[@"               " substringFromIndex:[priceString length]]],
              [productIdentifierFullString stringByAppendingString:[@"                                                                      " substringFromIndex:[productIdentifierFullString length]]]);
	}
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"LGInAppPurchases:\nInvalid product id: %@" , invalidProductId);
    }
}

- (void)requestDidFinish:(SKRequest *)request
{
    LOG(@"");
    
    NSLog(@"LGInAppPurchases: request did finish.");
    
    _storeDoneLoading = YES;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    LOG(@"");
    
    NSLog(@"LGInAppPurchases: request did fail with error - %@", error);
}

#pragma mark - Transaction Methods

// called when the transaction status is updated
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    LOG(@"");
    
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

// called when the transaction was successful
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    LOG(@"");
    
    NSLog(@"LGInAppPurcahses: Transaction Complete...");
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

// called when a transaction has been restored and successfully completed
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    LOG(@"");
    
    NSLog(@"LGInAppPurcahses: Transaction Restore...");
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

// called when a transaction has failed
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    LOG(@"");
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"LGInAppPurcahses: Transaction Failed... Reason: %@", transaction.error.localizedDescription);
        
        // error
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        NSLog(@"LGInAppPurcahses: User Cancelled Transaction");
        
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        [_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
}

// saves a record of the transaction by storing the receipt to disk
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    LOG(@"");
    
    NSMutableArray *productsIdArray = [LGInAppPurchases allProductsId];
	
	for (int i=0; i < [productsIdArray count]; i++)
	{
		NSString *product = [productsIdArray objectAtIndex:i];
        
        if ([transaction.payment.productIdentifier isEqualToString:product])
        {
            NSString *baseString = [[LGInAppPurchases getItemsDictionary] objectForKey:@"BaseFeatureIdString"];
            NSUInteger baseLength = [baseString length];
            
            // save the transaction receipt to disk
            [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:[NSString stringWithFormat:@"%@TransactionReceipt", [product substringFromIndex:baseLength]]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSLog(@"LGInAppPurchases: recordTransaction - %@ forKey - %@", transaction.payment.productIdentifier, [NSString stringWithFormat:@"%@TransactionReceipt", [product substringFromIndex:baseLength]]);
            
            break;
        }
	}
}

// enable features
- (void)provideContent:(NSString *)productId
{
    LOG(@"");
    
    if ([productId rangeOfString:@"RemoveAds33"].length)
    {
        NSString *baseString = [[LGInAppPurchases getItemsDictionary] objectForKey:@"BaseFeatureIdString"];
        NSUInteger baseLength = [baseString length];
        
        // enable the requested features by setting a global user value
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"is%@Purchased", [productId substringFromIndex:baseLength]]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (kLGKit.isAdMobEnabled)
        {
            kLGKit.isAdMobEnabled = NO;
            [kLGAdMob bannerHide];
        }
        
        NSLog(@"LGInAppPurchases: provideContent - %@ forKey - %@", productId, [NSString stringWithFormat:@"is%@Purchased", [productId substringFromIndex:baseLength]]);
    }
    else if ([productId rangeOfString:@"RemoveAds"].length)
    {
        NSString *baseString = [[LGInAppPurchases getItemsDictionary] objectForKey:@"BaseFeatureIdString"];
        NSUInteger baseLength = [baseString length];
        
        // enable the requested features by setting a global user value
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"is%@Purchased", [productId substringFromIndex:baseLength]]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (kLGKit.isAdMobEnabled)
        {
            kLGKit.isAdMobEnabled = NO;
            [kLGAdMob bannerHide];
        }
        
        NSLog(@"LGInAppPurchases: provideContent - %@ forKey - %@", productId, [NSString stringWithFormat:@"is%@Purchased", [productId substringFromIndex:baseLength]]);
    }
    else NSLog(@"LGInAppPurchases: %@ success purchased", productId);
}

// removes the transaction from the queue and posts a notification with the transaction result
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    LOG(@"");
    
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [_progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    if (wasSuccessful)
    {
        NSString *product = transaction.payment.productIdentifier;
        
        if ([product rangeOfString:@"RemoveAds33"].length || [product rangeOfString:@"RemoveAds"].length)
            [[[UIAlertView alloc] initWithTitle:@"Спасибо за покупку!"
                                        message:@"Вы успешно удалили рекламу!"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        else if ([product rangeOfString:@"Donate"].length)
            [[[UIAlertView alloc] initWithTitle:@"Спасибо за покупку!"
                                        message:@"Мы очень признательны вам за отправленные деньги!"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
    }
    else [[[UIAlertView alloc] initWithTitle:@"Ошибка при покупке"
                                     message:[NSString stringWithFormat:@"%@.\nПожалуйста повторите попытку позже.", transaction.error.localizedDescription]
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil] show];
}

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice
{
    LOG(@"");
    
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    return formattedString;
}

@end







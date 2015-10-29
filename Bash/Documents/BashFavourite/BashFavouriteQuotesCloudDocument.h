//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGDocumentTemplate.h"

@interface BashFavouriteQuotesCloudDocument : LGDocumentTemplate

@property (strong, nonatomic) NSMutableArray    *array;
@property (strong, nonatomic, readonly) NSError *openingError;
@property (strong, nonatomic, readonly) NSError *savingError;

@end

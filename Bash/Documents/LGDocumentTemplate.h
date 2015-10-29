//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGDocumentTemplate : UIDocument

typedef enum
{
    LGDocumentErrorZeroLengthFile,
    LGDocumentErrorCorruptFile,
    LGDocumentErrorUnexpectedVersion,
    LGDocumentErrorNoSuchFile,
    
    LGDocumentErrorOccurredWhileSaving
}
LGDocumentError;

@property (strong, nonatomic) NSMutableArray    *array;
@property (strong, nonatomic, readonly) NSError *openingError;
@property (strong, nonatomic, readonly) NSError *savingError;

@end

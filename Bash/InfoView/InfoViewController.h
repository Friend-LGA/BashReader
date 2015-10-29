//
//  InfoViewController.h
//  Bash
//
//  Created by Friend_LGA on 04.01.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGChapter.h"

@class
InfoButton,
BashCashQuoteObject,
TopTableViewCellStandartFull;

@interface InfoViewController : NSObject <UIGestureRecognizerDelegate>

typedef enum
{
    LGInfoViewTypeTextOnly,
    LGInfoViewTypeFirstInfo,
    LGInfoViewTypeUpdateInfo,
    LGInfoViewTypeHelpInfo,
    LGInfoViewTypeCopyrightInfo,
    LGInfoViewTypeVkReminder,
    LGInfoViewTypeRateReminder,
    LGInfoViewTypeSync,
    LGInfoViewTypeCashClean,
    LGInfoViewTypeVersionError,
    LGInfoViewTypeButtonsMain,
    LGInfoViewTypeButtonsFavourites
}
LGInfoViewType;

@property (assign, nonatomic) BOOL isPopViewOnScreen;

+ (instancetype)sharedManager;
- (void)initialize;

- (void)resizeAndRepositionAfterRotateToSize:(CGSize)size;
- (void)showInfoWithText:(NSString *)text;
- (void)showInfoWithText:(NSString *)text type:(LGInfoViewType)type;
- (void)showInfoWithText:(NSString *)text type:(LGInfoViewType)type chapterType:(LGChapterType)chapterType quote:(BashCashQuoteObject *)quote cell:(TopTableViewCellStandartFull *)cell;
- (void)remove;

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedManager instead")));

@end

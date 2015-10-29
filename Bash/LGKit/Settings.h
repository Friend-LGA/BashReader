//
//  Settings.h
//  Bash
//
//  Created by Friend_LGA on 03.02.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class
LGChapter,
BottomThemeObject,
TopThemeObject;

@interface Settings : NSObject

typedef enum
{
    LGLoadingFromInternet = 1,
    LGLoadingFromLocal = 2
}
LGLoadingFromType;

typedef enum
{
    LGSyncBoth = 0,
    LGSyncCloudToLocal = 1,
    LGSyncLocalToCloud = 2
}
LGSyncType;

typedef enum
{
    LGPostingByText = 0,
    LGPostingByPicture = 1
}
LGPostingType;

typedef enum
{
    LGQuoteInfoVisibilityShow = 0,
    LGQuoteInfoVisibilityHide = 1
}
LGQuoteInfoVisibility;

typedef enum
{
    LGQuoteMenuActionClose = 0,
    LGQuoteMenuActionNone = 1
}
LGQuoteMenuAction;

typedef enum
{
    LGOrientationAuto = 0,
    LGOrientationPortrait = 1,
    LGOrientationLandscape = 2
}
LGOrientation;

typedef enum
{
    LGIndentNone = 0,
    LGIndentSmall = 1,
    LGIndentMedium = 2,
    LGIndentLarge = 3,
}
LGIndent;

@property (strong, nonatomic) NSMutableArray                *quotesNeedRating;
@property (strong, nonatomic) UIColor                       *colorMain;
@property (assign, nonatomic) NSUInteger                    fontSize;
@property (strong, nonatomic) BottomThemeObject             *bottomTheme;
@property (strong, nonatomic) TopThemeObject                *topTheme;
@property (strong, nonatomic) LGChapter                     *chapter;
@property (assign, nonatomic) LGLoadingFromType             loadingFrom;
@property (assign, nonatomic) LGPostingType                 postingType;
@property (assign, nonatomic) LGQuoteInfoVisibility         quoteInfoVisibility;
@property (assign, nonatomic) LGQuoteMenuAction             quoteMenuAction;
@property (assign, nonatomic) LGSyncType                    syncType;
@property (assign, nonatomic) LGOrientation                 orientation;
@property (assign, nonatomic) LGIndent                      indentVertical;
@property (assign, nonatomic) LGIndent                      indentHorizontal;
@property (assign, nonatomic) BOOL                          isNavBarHidden;
@property (assign, nonatomic) BOOL                          isCloudEnabled;
@property (assign, nonatomic) BOOL                          isAutoLockOn;

+ (instancetype)sharedManager;

- (void)load;
- (void)save;

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedManager instead")));

@end

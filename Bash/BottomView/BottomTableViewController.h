//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface BottomTableViewController : UITableViewController <UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate>

typedef enum
{
    LGIndexPathSectionChapters  = 0,
    LGIndexPathSectionLoading   = 1,
    LGIndexPathSectionSettings  = 2,
    LGIndexPathSectionPurchases = 3,
    LGIndexPathSectionExtra     = 4,
}
LGIndexPathSectionType;

typedef enum
{
    LGBottomSectionCapacityChapters     = 9,
    LGBottomSectionCapacityLoading      = 3,
    LGBottomSectionCapacitySettings     = 13,
    LGBottomSectionCapacityPurchases    = 5,
    LGBottomSectionCapacityExtra        = 5
}
LGBottomSectionCapacity;

typedef enum
{
    // основные
    
    LGIndexPathRowFirst = -1,
    
    LGIndexPathRowChapterNew                    = 1 + LGIndexPathRowFirst,
    LGIndexPathRowChapterBest                   = 2 + LGIndexPathRowFirst,
    LGIndexPathRowChapterRating                 = 3 + LGIndexPathRowFirst,
    LGIndexPathRowChapterAbyss                  = 4 + LGIndexPathRowFirst,
    LGIndexPathRowChapterAbyssTop               = 5 + LGIndexPathRowFirst,
    LGIndexPathRowChapterAbyssBest              = 6 + LGIndexPathRowFirst,
    LGIndexPathRowChapterRandom                 = 7 + LGIndexPathRowFirst,
    LGIndexPathRowChapterSearch                 = 8 + LGIndexPathRowFirst,
    LGIndexPathRowChapterFavourites             = 9 + LGIndexPathRowFirst,
    
    LGIndexPathRowLoadingFromInternet           = 1 + LGIndexPathRowFirst,
    LGIndexPathRowLoadingFromLocal              = 2 + LGIndexPathRowFirst,
    LGIndexPathRowLoadingAllNew                 = 3 + LGIndexPathRowFirst,
    
    LGIndexPathRowSettingsCloud                 = 1 + LGIndexPathRowFirst,
    LGIndexPathRowSettingsFontSize              = 2 + LGIndexPathRowFirst,
    LGIndexPathRowSettingsChooseTheme           = 3 + LGIndexPathRowFirst,
    LGIndexPathRowSettingsSetTheme              = 4 + LGIndexPathRowFirst,
    LGIndexPathRowSettingsColorSchema           = 5 + LGIndexPathRowFirst,
    LGIndexPathRowSettingsPosting               = 6 + LGIndexPathRowFirst,
    LGIndexPathRowSettingsQuoteInfo             = 7 + LGIndexPathRowFirst,
    LGIndexPathRowSettingsQuoteMenu             = 8 + LGIndexPathRowFirst,
    LGIndexPathRowSettingsAutoLock              = 9 + LGIndexPathRowFirst,
    LGIndexPathRowSettingsOrientation           = 10 + LGIndexPathRowFirst,
    LGIndexPathRowSettingsIndent                = 11 + LGIndexPathRowFirst,
    LGIndexPathRowSettingsCash                  = 12 + LGIndexPathRowFirst,
    LGIndexPathRowSettingsVk                    = 13 + LGIndexPathRowFirst,
    
    LGIndexPathRowPurchasesRemoveAds            = 1 + LGIndexPathRowFirst,
    LGIndexPathRowPurchasesDonate33             = 2 + LGIndexPathRowFirst,
    LGIndexPathRowPurchasesDonate66             = 3 + LGIndexPathRowFirst,
    LGIndexPathRowPurchasesDonate99             = 4 + LGIndexPathRowFirst,
    LGIndexPathRowPurchasesRestore              = 5 + LGIndexPathRowFirst,
    
    LGIndexPathRowExtraApps                     = 1 + LGIndexPathRowFirst,
    LGIndexPathRowExtraRate                     = 2 + LGIndexPathRowFirst,
    LGIndexPathRowExtraSupport                  = 3 + LGIndexPathRowFirst,
    LGIndexPathRowExtraUpdateInfo               = 4 + LGIndexPathRowFirst,
    LGIndexPathRowExtraInfo                     = 5 + LGIndexPathRowFirst,
    
    // дополнительные
    
    LGIndexPathRowSettingsCloudOn                   = 1,
    LGIndexPathRowSettingsCloudOff                  = 2,

    LGIndexPathRowSettingsFontSize12                = 1,
    LGIndexPathRowSettingsFontSize13                = 2,
    LGIndexPathRowSettingsFontSize14                = 3,
    LGIndexPathRowSettingsFontSize15                = 4,
    LGIndexPathRowSettingsFontSize16                = 5,
    LGIndexPathRowSettingsFontSize17                = 6,
    LGIndexPathRowSettingsFontSize18                = 7,
    
    LGIndexPathRowSettingsThemeLight                = 1,
    LGIndexPathRowSettingsThemeDark                 = 2,
    
    LGIndexPathRowSettingsTopTheme                  = 1,
    LGIndexPathRowSettingsTopThemeBash              = 2,
    LGIndexPathRowSettingsTopThemeLightEntire       = 3,
    LGIndexPathRowSettingsTopThemeLightIndent       = 4,
    LGIndexPathRowSettingsTopThemeDarkEntire        = 5,
    LGIndexPathRowSettingsTopThemeDarkIndent        = 6,
    LGIndexPathRowSettingsBottomTheme               = 7,
    LGIndexPathRowSettingsBottomThemeLight          = 8,
    LGIndexPathRowSettingsBottomThemeDark           = 9,
    
    LGIndexPathRowSettingsColorSchema1              = 1,
    LGIndexPathRowSettingsColorSchema2              = 2,
    LGIndexPathRowSettingsColorSchema3              = 3,
    LGIndexPathRowSettingsColorSchema4              = 4,
    LGIndexPathRowSettingsColorSchema5              = 5,
    LGIndexPathRowSettingsColorSchema6              = 6,
    LGIndexPathRowSettingsColorSchema7              = 7,
    LGIndexPathRowSettingsColorSchema8              = 8,
    LGIndexPathRowSettingsColorSchema9              = 9,
    LGIndexPathRowSettingsColorSchema10             = 10,
    LGIndexPathRowSettingsColorSchema11             = 11,
    LGIndexPathRowSettingsColorSchema12             = 12,
    
    LGIndexPathRowSettingsPostingText               = 1,
    LGIndexPathRowSettingsPostingPicture            = 2,
    
    LGIndexPathRowSettingsQuoteInfoShow             = 1,
    LGIndexPathRowSettingsQuoteInfoHide             = 2,
    
    LGIndexPathRowSettingsQuoteMenuActionClose      = 1,
    LGIndexPathRowSettingsQuoteMenuActionNone       = 2,
    
    LGIndexPathRowSettingsAutoLockOn                = 1,
    LGIndexPathRowSettingsAutoLockOff               = 2,
    
    LGIndexPathRowSettingsOrientationAuto           = 1,
    LGIndexPathRowSettingsOrientationVertical       = 2,
    LGIndexPathRowSettingsOrientationHorizontal     = 3,
    
    LGIndexPathRowSettingsIndentVertical            = 1,
    LGIndexPathRowSettingsIndentVerticalNone        = 2,
    LGIndexPathRowSettingsIndentVerticalSmall       = 3,
    LGIndexPathRowSettingsIndentVerticalMedium      = 4,
    LGIndexPathRowSettingsIndentVerticalLarge       = 5,
    LGIndexPathRowSettingsIndentHorizontal          = 6,
    LGIndexPathRowSettingsIndentHorizontalNone      = 7,
    LGIndexPathRowSettingsIndentHorizontalSmall     = 8,
    LGIndexPathRowSettingsIndentHorizontalMedium    = 9,
    LGIndexPathRowSettingsIndentHorizontalLarge     = 10,
    
    LGIndexPathRowSettingsCashClear                 = 1,
    
    LGIndexPathRowSettingsVkLogout                  = 1
}
LGIndexPathRowType;

typedef enum
{
    LGBottomMultiCellCapacityCloud          = 2,
    LGBottomMultiCellCapacityFontSize       = 7,
    LGBottomMultiCellCapacityChooseTheme    = 2,
    LGBottomMultiCellCapacitySetTheme       = 9,
    LGBottomMultiCellCapacityColorSchema    = 12,
    LGBottomMultiCellCapacityPosting        = 2,
    LGBottomMultiCellCapacityQuoteInfo      = 2,
    LGBottomMultiCellCapacityQuoteMenu      = 2,
    LGBottomMultiCellCapacityCash           = 1,
    LGBottomMultiCellCapacityAutoLock       = 2,
    LGBottomMultiCellCapacityOrientation    = 3,
    LGBottomMultiCellCapacityIndent         = 10,
    LGBottomMultiCellCapacityVk             = 1
}
LGBottomMultiCellCapacity;

- (void)selectSavedCells;
- (void)setCloudSettingsTo:(BOOL)k;
- (void)collapseCloudSettings;

@end

//
//  TopThemeObject.h
//  Bash
//
//  Created by Friend_LGA on 18.10.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopThemeObject : NSObject

typedef enum
{
    TopThemeCellBgTypeFull,
    TopThemeCellBgTypeText
}
TopThemeCellBgType;

typedef enum
{
    TopThemeTypeBash,
    TopThemeTypeLightEntire,
    TopThemeTypeLightIndent,
    TopThemeTypeDarkEntire,
    TopThemeTypeDarkIndent
}
TopThemeType;

@property (assign, nonatomic) TopThemeType                  type;
@property (strong, nonatomic) NSString                      *name;
@property (strong, nonatomic) UIFont                        *font;
@property (assign, nonatomic) CGFloat                       cellIndent;

@property (strong, nonatomic) UIColor                       *infoTextColor;
@property (strong, nonatomic) UIColor                       *infoButtonsColor;
@property (strong, nonatomic) UIColor                       *infoBgColor;
@property (strong, nonatomic) UIColor                       *infoStripeColor;
@property (strong, nonatomic) UIColor                       *infoCellHighlightedBgColor;
@property (strong, nonatomic) UIColor                       *infoCloseButtonColor;

@property (strong, nonatomic) UIColor                       *backgroundColor;
@property (strong, nonatomic) UIColor                       *pullToRefreshColor;

@property (strong, nonatomic) UIColor                       *navBarBgColor;
@property (strong, nonatomic) UIColor                       *navBarStripeColor;
@property (assign, nonatomic) CGFloat                       navBarStripeThickness;
@property (strong, nonatomic) UIColor                       *navBarTextColor;

@property (strong, nonatomic) UIColor                       *searchViewBgColor;
@property (strong, nonatomic) UIColor                       *searchViewTextColor;
@property (strong, nonatomic) UIColor                       *searchViewSubtextColor;

@property (strong, nonatomic) UIColor                       *textColor;
@property (strong, nonatomic) UIColor                       *subtextColor;

@property (assign, nonatomic) TopThemeCellBgType            cellBgType;
@property (strong, nonatomic) UIColor                       *cellBgColor;

@property (strong, nonatomic) UIColor                       *plusMinusColor;
@property (strong, nonatomic) UIColor                       *plusMinusBgColor;
@property (strong, nonatomic) UIColor                       *plusMinusHighlightedColor;
@property (strong, nonatomic) UIColor                       *plusMinusHighlightedBgColor;
@property (strong, nonatomic) UIColor                       *plusMinusSelectedColor;
@property (strong, nonatomic) UIColor                       *plusMinusSelectedBgColor;

@property (strong, nonatomic) UIColor                       *heartColor;
@property (strong, nonatomic) UIColor                       *heartHighlightedColor;
@property (strong, nonatomic) UIColor                       *heartSelectedColor;

@property (assign, nonatomic) CGFloat                       separatorThickness;
@property (strong, nonatomic) UIColor                       *separatorColor;

- (id)initWithType:(TopThemeType)type;
+ (TopThemeObject *)themeWithType:(TopThemeType)type;

- (BOOL)isColorConflict;
- (BOOL)isDark;
- (BOOL)isLight;
- (void)update;

@end






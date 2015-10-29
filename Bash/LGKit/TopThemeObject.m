//
//  TopThemeObject.m
//  Bash
//
//  Created by Friend_LGA on 18.10.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "TopThemeObject.h"
#import "LGKit.h"
#import "Settings.h"
#import "LGColorConverter.h"

@implementation TopThemeObject

- (id)initWithType:(TopThemeType)type
{
    self = [super init];
    if (self)
    {
        self.type = type;
    }
    return self;
}

+ (TopThemeObject *)themeWithType:(TopThemeType)type
{
    return [[self alloc] initWithType:type];
}

#pragma mark -

- (void)setType:(TopThemeType)type
{
    _type = type;
    
    BOOL isColorConflict = [self isColorConflict];
    BOOL isColorWhite = [kColorMain isEqual:kColorWhite];
    
    _font                               = [UIFont systemFontOfSize:14.f];
    
    _pullToRefreshColor                 = kColorMain;
    
    _navBarStripeThickness              = (kIsRetina ? 0.5f : 1.f);
    
    if (_type == TopThemeTypeBash || _type == TopThemeTypeLightEntire || _type == TopThemeTypeLightIndent)
    {
        if (_type == TopThemeTypeBash)
        {
            _name                       = @"Bash";
            _cellIndent                 = 15.f;
            
            _backgroundColor            = kColorWhite;
            
            _cellBgType                 = TopThemeCellBgTypeText;
            _cellBgColor                = kColorSet(245, 245, 245, 1);
            
            _separatorThickness         = 1.f;
            
            _plusMinusBgColor           = kColorSet(0, 0, 0, 0.03);
        }
        else if (_type == TopThemeTypeLightEntire)
        {
            _name                       = @"LightEntire";
            _cellIndent                 = 0.f;
            
            _backgroundColor            = kColorWhite;
            
            _cellBgType                 = TopThemeCellBgTypeFull;
            _cellBgColor                = kColorWhite;
            
            _separatorThickness         = (kIsRetina ? 0.5f : 1.f);
            
            _plusMinusBgColor           = kColorSet(0, 0, 0, 0.03);
        }
        else if (_type == TopThemeTypeLightIndent)
        {
            _name                       = @"LightIndent";
            _cellIndent                 = 15.f;
            
            _backgroundColor            = kColorSet(240, 240, 240, 1);
            
            _cellBgType                 = TopThemeCellBgTypeText;
            _cellBgColor                = kColorWhite;
            
            _separatorThickness         = (kIsRetina ? 0.5f : 1.f);
            
            _plusMinusBgColor           = kColorSet(255, 255, 255, 0.5);
        }
        
        _textColor                      = kColorBlack;
        _subtextColor                   = kColorSet(0, 0, 0, 0.4);
        
        _separatorColor                 = kColorSet(0, 0, 0, 0.2);
        
        _plusMinusColor                 = kColorSet(0, 0, 0, 0.4);
        
        _plusMinusSelectedBgColor       = (isColorConflict && isColorWhite ? kColorSet(50, 50, 50, 1) : kColorMain);
        _plusMinusSelectedColor         = (isColorConflict && !isColorWhite ? kColorBlack : kColorWhite);
        
        _heartColor                     = kColorSet(0, 0, 0, 0.1);
        _heartSelectedColor             = (isColorConflict && isColorWhite ? kColorSet(50, 50, 50, 1) : kColorMain);
        
        // ----------------------------------
        
        _navBarBgColor                  = [kColorMain colorWithAlphaComponent:0.95f];
        _navBarStripeColor              = nil;
        _navBarTextColor                = (isColorConflict ? kColorBlack : kColorWhite);
        
        _searchViewBgColor              = kColorSet(0, 0, 0, 0.2);
        _searchViewTextColor            = (isColorConflict ? kColorBlack : kColorWhite);
        _searchViewSubtextColor         = [LGColorConverter getMixedColorInLAB:kColorSet(0, 0, 0, 1) andColor:kColorMain percent:60];
        
        _infoTextColor                  = kColorBlack;
        _infoBgColor                    = kColorSet(255, 255, 255, 0.9);
        _infoStripeColor                = kColorSet(180, 180, 180, 1);
        _infoCloseButtonColor           = kColorSet(200, 200, 200, 1);
        if (isColorWhite)
            _infoButtonsColor           = kColorBlack;
        else if (isColorConflict)
            _infoButtonsColor           = [LGColorConverter getMixedColorInLAB:kColorBlack andColor:kColorMain percent:70];
        else
            _infoButtonsColor           = [LGColorConverter getMixedColorInLAB:kColorBlack andColor:kColorMain percent:90];
        _infoCellHighlightedBgColor     = kColorSet(0, 0, 0, 0.05);
    }
    else
    {
        if (_type == TopThemeTypeDarkEntire)
        {
            _name                       = @"DarkEntire";
            _cellIndent                 = 0.f;
            
            _backgroundColor            = kColorBlack;
            
            _cellBgType                 = TopThemeCellBgTypeFull;
            _cellBgColor                = kColorBlack;
            
            _plusMinusBgColor           = kColorSet(255, 255, 255, 0.1);
        }
        else if (_type == TopThemeTypeDarkIndent)
        {
            _name                       = @"DarkIndent";
            _cellIndent                 = 15.f;
            
            _backgroundColor            = kColorSet(15, 15, 15, 1);
            
            _cellBgType                 = TopThemeCellBgTypeText;
            _cellBgColor                = kColorBlack;
            
            _plusMinusBgColor           = kColorSet(0, 0, 0, 0.5);
        }
        
        _textColor                      = kColorWhite;
        _subtextColor                   = kColorSet(255, 255, 255, 0.4);
        
        _separatorColor                 = kColorSet(255, 255, 255, 0.2);
        _separatorThickness             = (kIsRetina ? 0.5f : 1.f);
        
        _plusMinusColor                 = kColorSet(255, 255, 255, 0.4);
        
        _plusMinusSelectedBgColor       = kColorMain;
        _plusMinusSelectedColor         = kColorBlack;
        
        _heartColor                     = kColorSet(255, 255, 255, 0.13);
        _heartSelectedColor             = kColorMain;
        
        // ----------------------------------
        
        _navBarBgColor                  = [kColorBlack colorWithAlphaComponent:0.95f];
        _navBarStripeColor              = kColorSet(55, 55, 55, 1);
        _navBarTextColor                = kColorWhite;
        
        _searchViewBgColor              = kColorSet(255, 255, 255, 0.2);
        _searchViewTextColor            = kColorWhite;
        _searchViewSubtextColor         = kColorSet(0, 0, 0, 1);
        
        _infoTextColor                  = kColorWhite;
        _infoBgColor                    = kColorSet(50, 50, 50, 0.95);
        _infoStripeColor                = kColorSet(100, 100, 100, 1);
        _infoCloseButtonColor           = kColorSet(80, 80, 80, 1);
        if (isColorWhite)
            _infoButtonsColor           = kColorWhite;
        else if (isColorConflict)
            _infoButtonsColor           = [LGColorConverter getMixedColorInLAB:kColorBlack andColor:kColorMain percent:70];
        else
            _infoButtonsColor           = [LGColorConverter getMixedColorInLAB:kColorBlack andColor:kColorMain percent:90];
        _infoCellHighlightedBgColor     = kColorSet(0, 0, 0, 0.2);
    }
}

- (BOOL)isColorConflict
{
    if (self.isLight && ([kColorMain isEqual:kColorWhite] || [kColorMain isEqual:kColorAquamarine]))
        return YES;
    else
        return NO;
}

- (BOOL)isDark
{
    return (_type == TopThemeTypeDarkEntire || _type == TopThemeTypeDarkIndent);
}

- (BOOL)isLight
{
    return !(_type == TopThemeTypeDarkEntire || _type == TopThemeTypeDarkIndent);
}

- (void)update
{
    self.type = _type;
}

@end

//
//  BottomThemeObject.m
//  Bash
//
//  Created by Friend_LGA on 18.10.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "BottomThemeObject.h"
#import "LGKit.h"
#import "Settings.h"

@implementation BottomThemeObject

- (id)initWithType:(BottomThemeType)type
{
    self = [super init];
    if (self)
    {
        self.type = type;
    }
    return self;
}

+ (BottomThemeObject *)themeWithType:(BottomThemeType)type
{
    return [[self alloc] initWithType:type];
}

#pragma mark -

- (void)setType:(BottomThemeType)type
{
    _type = type;
    
    BOOL isColorConflict = [self isColorConflict];
    BOOL isColorWhite = [kColorMain isEqual:kColorWhite];
    
    _font                                   = [UIFont systemFontOfSize:16.f];
    
    _plusMinusThickness                     = 1.f;
    _plusMinusSelectedThickness             = 2.f;
    
    _cellSeparatorThickness                 = (kIsRetina ? 0.5f : 1.f);
    _cellLeftStripeThickness                = 5.f;
    
    _cellMultiLeftStripeColor               = kColorClear;
    _cellMultiLeftStripeSelectedColor       = (isColorConflict && isColorWhite ? kColorSet(50, 50, 50, 1) : kColorMain);
    
    _stripeThickness                        = (kIsRetina ? 0.5f : 1.f);
    
    if (_type == BottomThemeTypeLight)
    {
        _name                               = @"Light";

        _backgroundColor                    = kColorSet(230, 230, 230, 0.95);
        _stripeColor                        = nil;
        
        _cellBgColor                        = kColorSet(255, 255, 255, 0.95);
        _cellBgSelectedColor                = (isColorWhite ? kColorSet(50, 50, 50, 0.975) : [kColorMain colorWithAlphaComponent:0.95]);
        _cellTextColor                      = kColorBlack;
        _cellTextSelectedColor              = (isColorConflict && !isColorWhite ? kColorBlack : kColorWhite);
        _cellSubtextColor                   = kColorSet(200, 200, 200, 1);
        _cellSubtextSelectedColor           = (isColorWhite ? kColorBlack : kColorMain);
        _cellLeftStripeColor                = kColorClear;
        _cellLeftStripeSelectedColor        = kColorClear;
        
        _cellMultiBgSelectedColor           = kColorSet(255, 255, 255, 0.95);
        _cellMultiTextSelectedColor         = kColorBlack;
        
        _cellAddedLeftStripeColor           = (isColorWhite ? kColorSet(50, 50, 50, 1) : kColorMain);
        _cellAddedLeftStripeSelectedColor   = (isColorWhite ? kColorSet(50, 50, 50, 1) : kColorMain);;

        _cellSeparatorColor                 = kColorSet(200, 200, 200, 1);
        
        _sectionTextColor                   = kColorSet(130, 130, 130, 1);
    }
    else if (_type == BottomThemeTypeDark)
    {
        _name                               = @"Dark";
        
        _backgroundColor                    = kColorSet(25, 25, 25, 0.975);
        _stripeColor                        = kColorSet(55, 55, 55, 1);
        
        _cellBgColor                        = kColorSet(0, 0, 0, 0.925);
        _cellBgSelectedColor                = (isColorWhite ? kColorSet(100, 100, 100, 0.975) : kColorSet(0, 0, 0, 0.925));
        _cellTextColor                      = kColorWhite;
        _cellTextSelectedColor              = kColorMain;
        _cellSubtextColor                   = kColorSet(55, 55, 55, 1);
        _cellSubtextSelectedColor           = kColorMain;
        _cellLeftStripeColor                = kColorClear;
        _cellLeftStripeSelectedColor        = (isColorWhite ? kColorClear : kColorMain);
        
        _cellMultiBgSelectedColor           = kColorSet(0, 0, 0, 0.925);
        _cellMultiTextSelectedColor         = kColorWhite;
        
        _cellAddedLeftStripeColor           = kColorMain;
        _cellAddedLeftStripeSelectedColor   = kColorMain;
        
        _cellSeparatorColor                 = kColorSet(55, 55, 55, 1);
        
        _sectionTextColor                   = kColorSet(145, 145, 145, 1);
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
    return (_type == BottomThemeTypeDark);
}

- (BOOL)isLight
{
    return (_type == BottomThemeTypeLight);
}

- (void)update
{
    self.type = _type;
}

@end







//
//  BottomThemeObject.h
//  Bash
//
//  Created by Friend_LGA on 18.10.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BottomThemeObject : NSObject

typedef enum
{
    BottomThemeTypeLight,
    BottomThemeTypeDark
}
BottomThemeType;

@property (assign, nonatomic) BottomThemeType   type;
@property (strong, nonatomic) NSString          *name;
@property (strong, nonatomic) UIFont            *font;

@property (strong, nonatomic) UIColor           *backgroundColor;

@property (strong, nonatomic) UIColor           *stripeColor;
@property (assign, nonatomic) CGFloat           stripeThickness;

@property (strong, nonatomic) UIColor           *cellBgColor;
@property (strong, nonatomic) UIColor           *cellBgSelectedColor;
@property (strong, nonatomic) UIColor           *cellTextColor;
@property (strong, nonatomic) UIColor           *cellTextSelectedColor;
@property (strong, nonatomic) UIColor           *cellSubtextColor;
@property (strong, nonatomic) UIColor           *cellSubtextSelectedColor;
@property (strong, nonatomic) UIColor           *cellLeftStripeColor;
@property (strong, nonatomic) UIColor           *cellLeftStripeSelectedColor;

@property (strong, nonatomic) UIColor           *cellMultiBgSelectedColor;
@property (strong, nonatomic) UIColor           *cellMultiTextSelectedColor;
@property (strong, nonatomic) UIColor           *cellMultiLeftStripeColor;
@property (strong, nonatomic) UIColor           *cellMultiLeftStripeSelectedColor;

@property (strong, nonatomic) UIColor           *cellAddedLeftStripeColor;
@property (strong, nonatomic) UIColor           *cellAddedLeftStripeSelectedColor;

@property (strong, nonatomic) UIColor           *cellSeparatorColor;
@property (assign, nonatomic) CGFloat           cellSeparatorThickness;

@property (assign, nonatomic) CGFloat           cellLeftStripeThickness;

@property (assign, nonatomic) CGFloat           plusMinusThickness;
@property (assign, nonatomic) CGFloat           plusMinusSelectedThickness;

@property (strong, nonatomic) UIColor           *sectionTextColor;

- (id)initWithType:(BottomThemeType)type;
+ (BottomThemeObject *)themeWithType:(BottomThemeType)type;

- (BOOL)isColorConflict;
- (void)update;

@end
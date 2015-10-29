//
//  NavBarButton.m
//  Bash
//
//  Created by Friend_LGA on 22.01.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "NavBarButton.h"
#import "LGKit.h"
#import "Settings.h"
#import "LGGraphics.h"
#import "TopThemeObject.h"

#pragma mark ----------------------------------------------------------------------------------------------------

@interface NavBarButton ()

@property (strong, nonatomic) UIColor *colorFill;
@property (strong, nonatomic) UIColor *colorButtons;

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@implementation NavBarButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = YES;
        self.opaque = NO;
        self.backgroundColor = kColorClear;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    _colorFill      = kTopTheme.navBarBgColor;
    _colorButtons   = kTopTheme.navBarTextColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetFillColorWithColor(context, _colorFill.CGColor);
    CGContextSetShouldAntialias(context, YES);
    
    if (_type == LGNavBarButtonLeft)
    {
        CGContextSetStrokeColorWithColor(context, _colorButtons.CGColor);
        CGContextSetLineWidth(context, 2);
        
        CGFloat lenght = 10.f;
        CGFloat shift = 8.f;
        
        CGContextMoveToPoint(context, lenght, rect.size.height/2-shift);
        CGContextAddLineToPoint(context, rect.size.width-lenght, rect.size.height/2-shift);
        
        CGContextMoveToPoint(context, lenght, rect.size.height/2);
        CGContextAddLineToPoint(context, rect.size.width-lenght, rect.size.height/2);
        
        CGContextMoveToPoint(context, lenght, rect.size.height/2+shift);
        CGContextAddLineToPoint(context, rect.size.width-lenght, rect.size.height/2+shift);
        
        CGContextStrokePath(context);
    }
}

@end

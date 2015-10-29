//
//  NavBarSearchFieldClearButton.m
//  Bash
//
//  Created by Friend_LGA on 22.01.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "NavBarSearchFieldClearButton.h"
#import "LGKit.h"
#import "Settings.h"
#import "TopThemeObject.h"

#pragma mark ----------------------------------------------------------------------------------------------------

@interface NavBarSearchFieldClearButton ()

@property (strong, nonatomic) UIColor *colorStroke;

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@implementation NavBarSearchFieldClearButton

- (id)init
{
    self = [super init];
    if (self)
    {
        self.opaque = NO;
        self.backgroundColor = kColorClear;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    BOOL isNeedToRedraw = (CGSizeEqualToSize(self.frame.size, frame.size) ? NO : YES);
    
    [super setFrame:frame];
    
    if (isNeedToRedraw) [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    _colorStroke = kTopTheme.searchViewSubtextColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetLineWidth(context, 2);
    CGContextSetShouldAntialias(context, YES);

    int k = 5;
    
    CGContextSetStrokeColorWithColor(context, _colorStroke.CGColor);
    CGContextMoveToPoint(context, rect.size.width/2-k, rect.size.height/2-k);
    CGContextAddLineToPoint(context, rect.size.width/2+k, rect.size.height/2+k);
    CGContextMoveToPoint(context, rect.size.width/2+k, rect.size.height/2-k);
    CGContextAddLineToPoint(context, rect.size.width/2-k, rect.size.height/2+k);
    CGContextStrokePath(context);
}

@end









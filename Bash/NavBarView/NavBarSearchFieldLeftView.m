//
//  NavBarSearchFieldLeftView.m
//  Bash
//
//  Created by Friend_LGA on 22.01.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "NavBarSearchFieldLeftView.h"
#import "LGKit.h"
#import "Settings.h"
#import "TopThemeObject.h"

#pragma mark ----------------------------------------------------------------------------------------------------

@interface NavBarSearchFieldLeftView ()

@property (strong, nonatomic) UIColor *colorStroke;

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@implementation NavBarSearchFieldLeftView

- (id)init
{
    self = [super init];
    if (self)
    {
        self.opaque = NO;
        self.backgroundColor = kColorClear;
        self.userInteractionEnabled = NO;
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

    int k = 6;
    
    CGRect bounds = CGRectMake(rect.origin.x+k, rect.origin.y+k, rect.size.width-k*2, rect.size.height-k*2);
    
    CGContextSetStrokeColorWithColor(context, _colorStroke.CGColor);
    CGContextStrokeEllipseInRect(context, CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width-3, bounds.size.height-3));
    
    CGContextMoveToPoint(context, bounds.origin.x+bounds.size.width-5, bounds.origin.y+bounds.size.height-5);
    CGContextAddLineToPoint(context, bounds.origin.x+bounds.size.width, bounds.origin.y+bounds.size.height);
    CGContextStrokePath(context);
}

@end







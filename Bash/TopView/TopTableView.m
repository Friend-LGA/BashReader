//
//  TopTableView.m
//  Bash
//
//  Created by Friend_LGA on 26.12.13.
//  Copyright (c) 2013 Grigory Lutkov. All rights reserved.
//

#import "TopTableView.h"
#import "LGKit.h"
#import "Settings.h"
#import "TopThemeObject.h"

@interface TopTableView ()

@end

@implementation TopTableView

- (id)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = kColorClear;
        self.allowsSelection = NO;
        self.placeholderEnabled = NO;
        self.backgroundView = nil;
        
        self.indicatorStyle = (kTopTheme.isDark ? UIScrollViewIndicatorStyleWhite : UIScrollViewIndicatorStyleBlack);
        
        [self updateRefreshViewColor];
    }
    return self;
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    
    self.indicatorStyle = (kTopTheme.isDark ? UIScrollViewIndicatorStyleWhite : UIScrollViewIndicatorStyleBlack);
    
    [self updateRefreshViewColor];
}

- (void)updateRefreshViewColor
{
    BOOL isColorConflict = kTopTheme.isColorConflict;
    BOOL isColorWhite = [kColorMain isEqual:kColorWhite];
    
    self.refreshView.color = (isColorConflict && isColorWhite ? kColorSet(50, 50, 50, 1) : kColorMain);
}

@end

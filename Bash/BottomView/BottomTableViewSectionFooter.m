//
//  BottomTableViewSectionFooter.m
//  Bash
//
//  Created by Friend_LGA on 24.11.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "BottomTableViewSectionFooter.h"
#import "LGKit.h"
#import "Settings.h"
#import "BottomThemeObject.h"

@implementation BottomTableViewSectionFooter

- (id)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = kBottomTheme.backgroundColor;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    
    self.backgroundColor = kBottomTheme.backgroundColor;
}

@end

//
//  BottomTableView.m
//  Bash
//
//  Created by Friend_LGA on 26.12.13.
//  Copyright (c) 2013 Grigory Lutkov. All rights reserved.
//

#import "BottomTableView.h"
#import "LGKit.h"
#import "Settings.h"
#import "BottomThemeObject.h"

#pragma mark - Private

@interface BottomTableView ()

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *bottomView;

@end

#pragma mark - Implementation

@implementation BottomTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        self.backgroundColor = kColorClear;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.allowsMultipleSelection = YES;
        self.userInteractionEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.backgroundView = nil;
        
        _topView = [UIView new];
        _topView.backgroundColor = kBottomTheme.backgroundColor;
        [self addSubview:_topView];
        
        _bottomView = [UIView new];
        _bottomView.backgroundColor = kBottomTheme.backgroundColor;
        [self addSubview:_bottomView];
    }
    return self;
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    
    _topView.backgroundColor = kBottomTheme.backgroundColor;
    _bottomView.backgroundColor = kBottomTheme.backgroundColor;
}

- (void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    
    _topView.frame = CGRectMake(0, -kMainScreenHeight, self.frame.size.width, kMainScreenHeight);
    _bottomView.frame = CGRectMake(0, contentSize.height, self.frame.size.width, kMainScreenHeight);
}

@end

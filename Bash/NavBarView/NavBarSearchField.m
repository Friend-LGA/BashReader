//
//  NavBarSearchField.m
//  Bash
//
//  Created by Friend_LGA on 22.01.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "NavBarSearchField.h"
#import "NavBarSearchFieldLeftView.h"
#import "NavBarSearchFieldClearButton.h"
#import "AppDelegate.h"
#import "TopView.h"
#import "LGKit.h"
#import "Settings.h"
#import "LGColorConverter.h"
#import "TopThemeObject.h"

#pragma mark ----------------------------------------------------------------------------------------------------

@interface NavBarSearchField ()

@property (strong, nonatomic) NavBarSearchFieldLeftView     *iconView;
@property (strong, nonatomic) NavBarSearchFieldClearButton  *clearButton;
@property (strong, nonatomic) UIColor *colorFill;
@property (strong, nonatomic) UIColor *colorSubText;
@property (strong, nonatomic) UIColor *colorText;
@property (strong, nonatomic) UIColor *colorTraits;

@end

#pragma mark ----------------------------------------------------------------------------------------------------

@implementation NavBarSearchField

- (id)init
{
    self = [super init];
    if (self)
    {
        self.opaque = NO;
        self.backgroundColor = kColorClear;
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.userInteractionEnabled = YES;
        
        self.placeholder = @"текст или номер цитаты";
        self.font = [UIFont systemFontOfSize:14];
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.returnKeyType = UIReturnKeySearch;
        
        _iconView = [NavBarSearchFieldLeftView new];
        [self addSubview:_iconView];
        
        _clearButton = [NavBarSearchFieldClearButton new];
        [_clearButton addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_clearButton];
        
        [self checkColors];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _clearButton.frame = CGRectMake(frame.size.width-frame.size.height, 0, frame.size.height, frame.size.height);
    _iconView.frame = CGRectMake(0, 0, frame.size.height, frame.size.height);
}

- (BOOL)becomeFirstResponder
{
    LOG(@"");
    
    [self checkColors];
    
    return [super becomeFirstResponder];
}

- (void)checkColors
{
    LOG(@"");
    
    _colorFill      = kTopTheme.searchViewBgColor;
    _colorSubText   = kTopTheme.searchViewSubtextColor;
    _colorText      = kTopTheme.searchViewTextColor;
    _colorTraits    = [_colorText colorWithAlphaComponent:0.5f];
    
    if (kSystemVersion < 7) self.keyboardAppearance = UIKeyboardAppearanceAlert;
    else
    {
        if (kTopTheme.isDark)
            self.keyboardAppearance = UIKeyboardAppearanceDark;
        else
            self.keyboardAppearance = UIKeyboardAppearanceLight;
    }
    
    self.textColor = _colorText;
    [self setValue:_colorSubText forKeyPath:@"_placeholderLabel.textColor"];
    [[self valueForKey:@"textInputTraits"] setValue:_colorTraits forKey:@"insertionPointColor"];
}

- (void)drawRect:(CGRect)rect
{
    [self checkColors];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, _colorFill.CGColor);
    CGContextSetShouldAntialias(context, NO);

    CGContextFillRect(context, rect);
}

- (void)saveSearchText:(NSString *)string
{
    LOG(@"");
    
    NSMutableString *muteString = [NSMutableString stringWithString:string];
    
    while (muteString.length && [[muteString substringWithRange:NSMakeRange(0, 1)] rangeOfString:@" "].location != NSNotFound)
        [muteString deleteCharactersInRange:NSMakeRange(0, 1)];
    
    while (muteString.length && [[muteString substringWithRange:NSMakeRange(muteString.length-1, 1)] rangeOfString:@" "].location != NSNotFound)
        [muteString deleteCharactersInRange:NSMakeRange(muteString.length-1, 1)];
    
    kLGKit.searchText = [muteString stringByAddingPercentEscapesUsingEncoding:NSWindowsCP1251StringEncoding];
    self.text = muteString;
}

- (void)clearTextField:(id)sender
{
    LOG(@"");
    
    [self becomeFirstResponder];
    
    self.text = @"";
    kLGKit.searchText = @"";
    
    //[kTopView tableViewRefreshWithCompletionHandler:nil];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    float yOrigin = 0;
    if (kSystemVersion < 7) yOrigin = bounds.size.height/2-[UIFont systemFontOfSize:14].pointSize/1.75;
    return CGRectIntegral(CGRectMake(bounds.origin.x+self.frame.size.height, yOrigin, bounds.size.width-self.frame.size.height*2, bounds.size.height));
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    float yOrigin = 0;
    if (kSystemVersion < 7) yOrigin = bounds.size.height/2-[UIFont systemFontOfSize:14].pointSize/1.75;
    return CGRectIntegral(CGRectMake(bounds.origin.x+self.frame.size.height, yOrigin, bounds.size.width-self.frame.size.height*2, bounds.size.height));
}

- (void)dealloc
{
    LOG(@"");
    
    kLGKit.searchText = @"";
}

@end

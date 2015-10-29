//
//  PrerenderedImages.m
//  Bash
//
//  Created by Friend_LGA on 20.10.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "PrerenderedImages.h"
#import "LGKit.h"
#import "Settings.h"
#import "BottomThemeObject.h"
#import "TopThemeObject.h"

@implementation PrerenderedImages

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static id sharedManager = nil;
    
    dispatch_once(&once, ^
                  {
                      sharedManager = [super new];
                  });
    
    return sharedManager;
}

- (id)init
{
    LOG(@"");
    
    if ((self = [super init]))
    {
        NSLog(@"PrerenderedImages: Shared Manager initialization...");
    }
    return self;
}

- (void)initialize
{
    [self updateMenuViewImages];
    
    [self updateMainViewImages];
}

- (void)updateMenuViewImages
{
    CGFloat shadowBlur = 6.f;
    
    _menuShadowTopImage         = [LGDrawer drawShadowWithDirection:LGDrawerDirectionTop
                                                         shadowBlur:shadowBlur];
    
    _menuShadowRightImage       = [LGDrawer drawShadowWithDirection:LGDrawerDirectionRight
                                                         shadowBlur:shadowBlur];
    
    _menuShadowTopRightImage    = [LGDrawer drawShadowWithDirection:LGDrawerDirectionTopRight
                                                          imageSize:CGSizeMake(shadowBlur, shadowBlur)
                                                    backgroundColor:nil
                                                         shadowBlur:shadowBlur
                                                        shadowColor:[UIColor blackColor]];
    
    CGFloat plusMinusImageSize = 40.f;
    CGFloat plusMinusSize = 20.f;
    
    _multiCellPlusImage = [LGDrawer drawPlusWithSize:CGSizeMake(plusMinusSize, plusMinusSize)
                                           imageSize:CGSizeMake(plusMinusImageSize, plusMinusImageSize)
                                           thickness:kBottomTheme.plusMinusThickness
                                               color:kBottomTheme.cellSubtextColor];
    
    _multiCellPlusHighlightedImage = [LGDrawer drawPlusWithSize:CGSizeMake(plusMinusSize, plusMinusSize)
                                                      imageSize:CGSizeMake(plusMinusImageSize, plusMinusImageSize)
                                                      thickness:kBottomTheme.plusMinusSelectedThickness
                                                          color:kBottomTheme.cellSubtextSelectedColor];
    
    _multiCellMinusImage = [LGDrawer drawLineWithDirection:LGDrawerDirectionHorizontal
                                                 imageSize:CGSizeMake(plusMinusImageSize, plusMinusImageSize)
                                                    length:plusMinusSize
                                                 thickness:kBottomTheme.plusMinusSelectedThickness
                                                     color:kBottomTheme.cellSubtextSelectedColor];
    
    _multiCellMinusHighlightedImage = [LGDrawer drawLineWithDirection:LGDrawerDirectionHorizontal
                                                            imageSize:CGSizeMake(plusMinusImageSize, plusMinusImageSize)
                                                               length:plusMinusSize
                                                            thickness:kBottomTheme.plusMinusThickness
                                                                color:kBottomTheme.cellSubtextColor];
}

- (void)updateMainViewImages
{
    CGFloat shadowBlur = 3.f;
    
    _navBarShadowBottomImage = [LGDrawer drawShadowWithDirection:LGDrawerDirectionBottom
                                                      shadowBlur:shadowBlur];
    CGFloat imageSize = 10.f;
    CGFloat size = 9.f;
    
    if (kTopTheme.type == TopThemeTypeLightIndent || kTopTheme.type == TopThemeTypeDarkIndent)
    {
        _cellBgImage = nil;
    }
    else
    {
        _cellBgImage = [LGDrawer drawLineWithDirection:LGDrawerDirectionHorizontal
                                             imageSize:CGSizeMake(imageSize, imageSize)
                                       backgroundColor:kTopTheme.cellBgColor
                                                center:CGPointMake(imageSize/2, imageSize-kTopTheme.separatorThickness)
                                                length:imageSize
                                             thickness:kTopTheme.separatorThickness
                                                 color:kTopTheme.separatorColor];
    }
    
    {
        imageSize = 30.f;
        size = 20.f;
        
        _ratingBayanImage = [LGDrawer drawEllipseWithSize:CGSizeMake(size, size)
                                                imageSize:CGSizeMake(imageSize, imageSize)
                                                    color:kTopTheme.plusMinusBgColor];
        
        imageSize = 31.f;
        size = 10.f;
        
        UIImage *plusImage = [LGDrawer drawPlusWithSize:CGSizeMake(size, size)
                                              imageSize:CGSizeMake(imageSize, imageSize)
                                              thickness:1.f
                                                  color:kTopTheme.plusMinusColor];
        
        UIImage *minusImage = [LGDrawer drawLineWithDirection:LGDrawerDirectionHorizontal
                                                    imageSize:CGSizeMake(imageSize, imageSize)
                                                       length:size
                                                    thickness:1.f
                                                        color:kTopTheme.plusMinusColor];
        
        _ratingPlusImage = [LGDrawer drawImage:plusImage
                                       onImage:_ratingBayanImage
                                    finishSize:CGSizeMake(imageSize, imageSize)];
        
        _ratingMinusImage = [LGDrawer drawImage:minusImage
                                        onImage:_ratingBayanImage
                                     finishSize:CGSizeMake(imageSize, imageSize)];

        imageSize = 30.f;
        size = 20.f;
        
        _favouriteImage = [LGDrawer drawHeartWithSize:CGSizeMake(size, size)
                                            imageSize:CGSizeMake(imageSize, imageSize)
                                      backgroundColor:nil
                                                color:kTopTheme.heartColor];
    }
    
    {
        imageSize = 30.f;
        size = 20.f;
        
        _ratingBayanSelectedImage = [LGDrawer drawEllipseWithSize:CGSizeMake(size, size)
                                                        imageSize:CGSizeMake(imageSize, imageSize)
                                                            color:kTopTheme.plusMinusSelectedBgColor];
        
        imageSize = 31.f;
        size = 10.f;
        
        UIImage *plusImage = [LGDrawer drawPlusWithSize:CGSizeMake(size, size)
                                              imageSize:CGSizeMake(imageSize, imageSize)
                                              thickness:1.f
                                                  color:kTopTheme.plusMinusSelectedColor];
        
        UIImage *minusImage = [LGDrawer drawLineWithDirection:LGDrawerDirectionHorizontal
                                                    imageSize:CGSizeMake(imageSize, imageSize)
                                                       length:size
                                                    thickness:1.f
                                                        color:kTopTheme.plusMinusSelectedColor];

        _ratingPlusSelectedImage = [LGDrawer drawImage:plusImage
                                               onImage:_ratingBayanSelectedImage
                                            finishSize:CGSizeMake(imageSize, imageSize)];
        
        _ratingMinusSelectedImage = [LGDrawer drawImage:minusImage
                                                onImage:_ratingBayanSelectedImage
                                             finishSize:CGSizeMake(imageSize, imageSize)];

        imageSize = 30.f;
        size = 20.f;
        
        _favouriteSelectedImage = [LGDrawer drawHeartWithSize:CGSizeMake(size, size)
                                                    imageSize:CGSizeMake(imageSize, imageSize)
                                              backgroundColor:nil
                                                        color:kTopTheme.heartSelectedColor];
    }
    
    {
        CGFloat tickSize = 20.f;
        
        _tickImage = [LGDrawer drawTickWithSize:CGSizeMake(tickSize, tickSize)
                                      imageSize:CGSizeMake(tickSize, tickSize)
                                backgroundColor:nil
                                          color:kTopTheme.infoButtonsColor
                                      thickness:2.f];
    }
    
    {
        UIImage *circleImage = [LGDrawer drawEllipseWithSize:CGSizeMake(20.f, 20.f)
                                                   imageSize:CGSizeMake(44.f, 44.f)
                                                       color:kTopTheme.infoCloseButtonColor];
        
        UIImage *crossImage = [LGDrawer drawCrossWithSize:CGSizeMake(8.f, 8.f)
                                                thickness:1.f
                                                    color:kTopTheme.infoTextColor];
        
        _closeImage = [LGDrawer drawImage:crossImage onImage:circleImage finishSize:circleImage.size];
    }
}

@end
















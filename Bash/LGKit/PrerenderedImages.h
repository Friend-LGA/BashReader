//
//  PrerenderedImages.h
//  Bash
//
//  Created by Friend_LGA on 20.10.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrerenderedImages : NSObject

// Menu View

@property (strong, nonatomic) UIImage *menuShadowTopImage;
@property (strong, nonatomic) UIImage *menuShadowRightImage;
@property (strong, nonatomic) UIImage *menuShadowTopRightImage;

@property (strong, nonatomic) UIImage *multiCellPlusImage;
@property (strong, nonatomic) UIImage *multiCellPlusHighlightedImage;

@property (strong, nonatomic) UIImage *multiCellMinusImage;
@property (strong, nonatomic) UIImage *multiCellMinusHighlightedImage;

// Main View

@property (strong, nonatomic) UIImage *navBarShadowBottomImage;

@property (strong, nonatomic) UIImage *cellBgImage;

@property (strong, nonatomic) UIImage *ratingPlusImage;
@property (strong, nonatomic) UIImage *ratingPlusSelectedImage;
@property (strong, nonatomic) UIImage *ratingMinusImage;
@property (strong, nonatomic) UIImage *ratingMinusSelectedImage;
@property (strong, nonatomic) UIImage *ratingBayanImage;
@property (strong, nonatomic) UIImage *ratingBayanSelectedImage;

@property (strong, nonatomic) UIImage *favouriteImage;
@property (strong, nonatomic) UIImage *favouriteSelectedImage;

// Info View

@property (strong, nonatomic) UIImage *tickImage;
@property (strong, nonatomic) UIImage *closeImage;

+ (instancetype)sharedManager;
- (void)initialize;

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call sharedManager instead")));
- (instancetype)init __attribute__((unavailable("init not available, call sharedManager instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call sharedManager instead")));

- (void)updateMenuViewImages;
- (void)updateMainViewImages;

@end

//
//  LGGraphics.h
//  Bash
//
//  Created by Friend_LGA on 03.02.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGGraphics : NSObject

void roundCorners(CGContextRef context, CGRect rect, CGFloat radius);
void roundTopCorners(CGContextRef context, CGRect rect, CGFloat radius);
void roundBottomCorners(CGContextRef context, CGRect rect, CGFloat radius);
void roundLeftCorners(CGContextRef context, CGRect rect, CGFloat radius);
void roundRightCorners(CGContextRef context, CGRect rect, CGFloat radius);

+ (instancetype)alloc __attribute__((unavailable("alloc not available, call methods instead")));
- (instancetype)init __attribute__((unavailable("init not available, call methods instead")));
+ (instancetype)new __attribute__((unavailable("new not available, call methods instead")));

@end

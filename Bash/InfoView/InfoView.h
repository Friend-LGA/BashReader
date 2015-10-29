//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "InfoViewController.h"

@class
BashCashQuoteObject,
InfoViewButton,
TopTableViewCellStandartFull;

@interface InfoView : UIScrollView <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (assign, nonatomic) LGInfoViewType type;

- (id)initWithText:(NSString *)text;
- (id)initWithText:(NSString *)text type:(LGInfoViewType)type;
- (id)initWithText:(NSString *)text type:(LGInfoViewType)type chapterType:(LGChapterType)chapterType quote:(BashCashQuoteObject *)quote cell:(TopTableViewCellStandartFull *)cell;
- (void)resizeAndRepositionAfterRotateToSize:(CGSize)size;

@end
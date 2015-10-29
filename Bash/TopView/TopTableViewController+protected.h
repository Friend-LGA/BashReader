//
//  TopTableViewCell+protected.m
//  Bash
//
//  Created by Friend_LGA on 30.11.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "TopTableViewController.h"
#import "TopTableViewCellLoading.h"
#import "TopTableViewCellInfo.h"
#import "TopTableViewCellStandartFull.h"
#import "TopTableViewCellStandartShort.h"
#import "TopTableViewCellStandartText.h"
#import "TopTableViewCellObject.h"
#import "QuoteGetter.h"
#import "BashCashQuoteObject.h"

@interface TopTableViewController (protected)

@property (strong, nonatomic) NSMutableArray    *dataArray;
@property (strong, nonatomic) QuoteGetter       *quoteGetter;
@property (strong, nonatomic) NSString          *errorMessage;
@property (assign, nonatomic) NSUInteger        numberOfObjectsInDB;

@property (assign, nonatomic) CGFloat           cellWidth;
@property (assign, nonatomic) CGFloat           cellOriginX;

@property (strong, nonatomic) TopTableViewCellLoading       *prototypeCell1;
@property (strong, nonatomic) TopTableViewCellInfo          *prototypeCell2;
@property (strong, nonatomic) TopTableViewCellStandartFull  *prototypeCell3;
@property (strong, nonatomic) TopTableViewCellStandartShort *prototypeCell4;
@property (strong, nonatomic) TopTableViewCellStandartText  *prototypeCell5;

@end

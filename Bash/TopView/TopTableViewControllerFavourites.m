//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "TopTableViewControllerFavourites.h"
#import "TopTableViewController+protected.h"
#import "Settings.h"
#import "LGKit.h"
#import "TopTableViewCellStandartFavourite.h"
#import "LGCloud.h"

#pragma mark - Private

@interface TopTableViewControllerFavourites ()

@property (strong, nonatomic) TopTableViewCellStandartFavourite *prototypeCell6;

@end

#pragma mark - Implementation

@implementation TopTableViewControllerFavourites

- (id)init
{
    LOG(@"");
    
    self = [super init];
    if (self)
    {
        [self.tableView registerClass:[TopTableViewCellStandartFavourite class] forCellReuseIdentifier:@"cellFavourite"];

        _prototypeCell6 = [[TopTableViewCellStandartFavourite alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TopTableViewCell *cell_;
    
    if ([self.dataArray[indexPath.row] isKindOfClass:[NSString class]])
    {
        if ([self.dataArray[indexPath.row] isEqualToString:@"cellLoading"])
        {
            TopTableViewCellLoading *cell = [tableView dequeueReusableCellWithIdentifier:@"cellLoading"];
            
            cell.width          = self.cellWidth;
            cell.originX        = self.cellOriginX;
            
            cell.textLabel.text = (kLGCloud.status == LGCloudStatusSyncing ? @"Синхр. с iCloud..." : @"Загрузка...");
            
            cell_ = cell;
        }
        else if ([self.dataArray[indexPath.row] isEqualToString:@"cellInfo"])
        {
            TopTableViewCellInfo *cell = [tableView dequeueReusableCellWithIdentifier:@"cellInfo"];
            
            cell.width          = self.cellWidth;
            cell.originX        = self.cellOriginX;
            cell.textLabel.text = [NSString stringWithFormat:@"Цитат в базе: %lu", (unsigned long)self.numberOfObjectsInDB];
            
            cell_ = cell;
        }
        else if ([self.dataArray[indexPath.row] isEqualToString:@"cellError"])
        {
            TopTableViewCellInfo *cell = [tableView dequeueReusableCellWithIdentifier:@"cellError"];
            
            cell.width          = self.cellWidth;
            cell.originX        = self.cellOriginX;
            cell.textLabel.text = self.errorMessage;
            
            cell_ = cell;
        }
    }
    else
    {
        BashCashQuoteObject *quote = self.dataArray[indexPath.row];
        
        if (kSettings.quoteInfoVisibility == LGQuoteInfoVisibilityShow)
        {
            TopTableViewCellStandartFavourite *cell = [tableView dequeueReusableCellWithIdentifier:@"cellFavourite"];
            
            cell.width      = self.cellWidth;
            cell.originX    = self.cellOriginX;
            cell.quote      = quote;
            
            cell_ = cell;
        }
        else
        {
            TopTableViewCellStandartText *cell = [tableView dequeueReusableCellWithIdentifier:@"cellText"];
            
            cell.width      = self.cellWidth;
            cell.originX    = self.cellOriginX;
            cell.quote      = quote;
            
            cell_ = cell;
        }
    }
    
    return cell_;
}

#pragma mark - Table View delegate

- (CGFloat)tableView:(UITableView *)tableView asyncHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.f;
    
    if ([self.dataArray[indexPath.row] isKindOfClass:[NSString class]])
    {
        if ([self.dataArray[indexPath.row] isEqualToString:@"cellLoading"])
        {
            self.prototypeCell1.width          = self.cellWidth;
            self.prototypeCell1.originX        = self.cellOriginX;
            
            self.prototypeCell1.textLabel.text = (kLGCloud.status == LGCloudStatusSyncing ? @"Синхр. с iCloud..." : @"Загрузка...");
            
            [self.prototypeCell1 layoutSubviews];
            height = self.prototypeCell1.height;
        }
        else if ([self.dataArray[indexPath.row] isEqualToString:@"cellInfo"])
        {
            self.prototypeCell2.width          = self.cellWidth;
            self.prototypeCell2.originX        = self.cellOriginX;
            self.prototypeCell2.textLabel.text = [NSString stringWithFormat:@"Цитат в базе: %lu", (unsigned long)self.numberOfObjectsInDB];
            
            [self.prototypeCell2 layoutSubviews];
            height = self.prototypeCell2.height;
        }
        else if ([self.dataArray[indexPath.row] isEqualToString:@"cellError"])
        {
            self.prototypeCell2.width          = self.cellWidth;
            self.prototypeCell2.originX        = self.cellOriginX;
            self.prototypeCell2.textLabel.text = self.errorMessage;
            
            [self.prototypeCell2 layoutSubviews];
            height = self.prototypeCell2.height;
        }
    }
    else
    {
        if (self.dataArray && self.dataArray.count > indexPath.row)
        {
            BashCashQuoteObject *quote = (self.dataArray && self.dataArray.count > indexPath.row ? self.dataArray[indexPath.row] : [BashCashQuoteObject new]);
            
            if (kSettings.quoteInfoVisibility == LGQuoteInfoVisibilityShow)
            {
                self.prototypeCell6.width   = self.cellWidth;
                self.prototypeCell6.originX = self.cellOriginX;
                self.prototypeCell6.quote   = quote;
                
                [self.prototypeCell6 layoutSubviews];
                height = self.prototypeCell6.height;
            }
            else
            {
                self.prototypeCell5.width   = self.cellWidth;
                self.prototypeCell5.originX = self.cellOriginX;
                self.prototypeCell5.quote   = quote;
                
                [self.prototypeCell5 layoutSubviews];
                height = self.prototypeCell5.height;
            }
        }
    }
    
    return height;
}

@end














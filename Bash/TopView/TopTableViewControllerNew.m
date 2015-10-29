//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "TopTableViewControllerNew.h"
#import "TopTableViewController+protected.h"
#import "Settings.h"
#import "LGKit.h"

@implementation TopTableViewControllerNew

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
            cell.textLabel.text = @"Загрузка...";
            
            cell_ = cell;
        }
        else if ([self.dataArray[indexPath.row] isEqualToString:@"cellInfo"])
        {
            TopTableViewCellInfo *cell = [tableView dequeueReusableCellWithIdentifier:@"cellInfo"];
            
            cell.width          = self.cellWidth;
            cell.originX        = self.cellOriginX;
            
            if (kSettings.loadingFrom == LGLoadingFromInternet)
            {
                if (self.quoteGetter.statsArray.count >= 3)
                    cell.textLabel.text = [NSString stringWithFormat:@"Утверждено цитат всего: %@\nсегодня: %@\nждyт очереди в Бездне: %@", self.quoteGetter.statsArray[0], self.quoteGetter.statsArray[1], self.quoteGetter.statsArray[2]];
            }
            else cell.textLabel.text = [NSString stringWithFormat:@"Цитат в базе: %lu", (unsigned long)self.numberOfObjectsInDB];
            
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
            TopTableViewCellStandartFull *cell = [tableView dequeueReusableCellWithIdentifier:@"cellFull"];
            
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
            self.prototypeCell1.textLabel.text = @"Загрузка...";
            
            [self.prototypeCell1 layoutSubviews];
            height = self.prototypeCell1.height;
        }
        else if ([self.dataArray[indexPath.row] isEqualToString:@"cellInfo"])
        {
            self.prototypeCell2.width          = self.cellWidth;
            self.prototypeCell2.originX        = self.cellOriginX;
            
            if (kSettings.loadingFrom == LGLoadingFromInternet)
            {
                if (self.quoteGetter.statsArray.count >= 3)
                self.prototypeCell2.textLabel.text = [NSString stringWithFormat:@"Утверждено цитат всего: %@\nсегодня: %@\nждyт очереди в Бездне: %@", self.quoteGetter.statsArray[0], self.quoteGetter.statsArray[1], self.quoteGetter.statsArray[2]];
            }
            else self.prototypeCell2.textLabel.text = [NSString stringWithFormat:@"Цитат в базе: %lu", (unsigned long)self.numberOfObjectsInDB];
            
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
                self.prototypeCell3.width   = self.cellWidth;
                self.prototypeCell3.originX = self.cellOriginX;
                self.prototypeCell3.quote   = quote;
                
                [self.prototypeCell3 layoutSubviews];
                height = self.prototypeCell3.height;
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














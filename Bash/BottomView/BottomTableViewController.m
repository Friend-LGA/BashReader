//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "BottomTableViewController.h"
#import "BottomView.h"
#import "BottomTableView.h"
#import "BottomTableViewSectionHeader.h"
#import "BottomTableViewSectionFooter.h"
#import "BottomTableViewCellStandart.h"
#import "BottomTableViewCellMulti.h"
#import "BottomTableViewCellAdded.h"
#import "BottomTableViewCellLoading.h"
#import "BottomTableViewCellAddedColors.h"
#import "AppDelegate.h"
#import "TopView.h"
#import "LGKit.h"
#import "Settings.h"
#import "LGChapter.h"
#import "LGInAppPurchases.h"
#import "LGCloud.h"
#import "LGDocuments.h"
#import "LGVkontakte.h"
#import "LGGoogleAnalytics.h"
#import "QuoteGetter.h"
#import "InfoViewController.h"
#import "LGCoreData.h"
#import "BottomThemeObject.h"
#import "TopThemeObject.h"
#import "PrerenderedImages.h"

#pragma mark - Private

@interface BottomTableViewController ()

@property (strong, nonatomic) NSArray           *headers;
@property (strong, nonatomic) NSMutableArray    *openedCells;
@property (strong, nonatomic) NSMutableArray    *cells;
@property (strong, nonatomic) NSArray           *cellsFull;
@property (strong, nonatomic) NSArray           *cellsAddFull;
@property (assign, nonatomic) BOOL              isAllNewLoading;

@property (assign, nonatomic) NSUInteger rowThemeTop;
@property (assign, nonatomic) NSUInteger rowThemeBottom;
@property (assign, nonatomic) NSUInteger rowIndentVertical;
@property (assign, nonatomic) NSUInteger rowIndentHorizontal;

@end

#pragma mark - Implementation

@implementation BottomTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    LOG(@"");
    
    self = [super initWithStyle:style];
    if (self)
    {
        BottomTableView *tableView = [[BottomTableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        self.tableView = tableView;
        
        [tableView registerClass:[BottomTableViewCellStandart class] forCellReuseIdentifier:@"cellStandart"];
        [tableView registerClass:[BottomTableViewCellMulti class] forCellReuseIdentifier:@"cellMulti"];
        [tableView registerClass:[BottomTableViewCellAdded class] forCellReuseIdentifier:@"cellAdded"];
        [tableView registerClass:[BottomTableViewCellLoading class] forCellReuseIdentifier:@"cellLoading"];
        [tableView registerClass:[BottomTableViewCellAddedColors class] forCellReuseIdentifier:@"cellAddedColors"];
        
        _openedCells = @[[NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO],
                         [NSNumber numberWithBool:NO]].mutableCopy;
        
        _headers = @[@"РАЗДЕЛЫ",
                     @"ЗАГРУЗКА ЦИТАТ",
                     @"НАСТРОЙКИ",
                     @"ПОКУПКИ",
                     @"ДОПОЛНИТЕЛЬНО"];
        
        _cellsFull = @[// РАЗДЕЛЫ
                       @[@"новые",
                         @"лучшие",
                         @"по рейтингу",
                         @"Бездна",
                         @"топ Бездны",
                         @"лучшие Бездны",
                         @"случайные",
                         @"поиск",
                         @"Избранные"],
                       
                       // ЗАГРУЗКА ЦИТАТ
                       @[@"Из интернета",
                         @"Из локальной базы",
                         @"Загрузить все новые"],
                       
                       // НАСТРОЙКИ
                       @[@"iCloud",
                         @"Размер шрифта",
                         @"Выбрать оформление",
                         @"Настроить оформление",
                         @"Цветовая схема",
                         @"Отправка в соц. сети",
                         @"Информация о цитате",
                         @"Меню цитаты",
                         @"Автоблокировка",
                         @"Ориентация",
                         @"Боковые поля",
                         @"Кэш",
                         @"ВКонтакте"],
                       
                       // ПОКУПКИ
                       @[@"Удалить рекламу | 33р",
                         @"Отправить 33р",
                         @"Отправить 66р",
                         @"Отправить 99р",
                         @"Восстановить покупки"],
                       
                       // ДОПОЛНИТЕЛЬНО
                       @[@"Наши приложения",
                         @"Оценить в AppStore",
                         @"Поддержка",
                         @"Новости обновления",
                         @"Инфо"]];
        
        _cells = @[[NSMutableArray arrayWithArray:_cellsFull[LGIndexPathSectionChapters]],
                   [NSMutableArray arrayWithArray:_cellsFull[LGIndexPathSectionLoading]],
                   [NSMutableArray arrayWithArray:_cellsFull[LGIndexPathSectionSettings]],
                   [NSMutableArray arrayWithArray:_cellsFull[LGIndexPathSectionPurchases]],
                   [NSMutableArray arrayWithArray:_cellsFull[LGIndexPathSectionExtra]]].mutableCopy;
        
        _cellsAddFull = @[// iCLOUD
                          @[@"•  Включить",
                            @"•  Выключить"],
                          
                          // РАЗМЕР ШРИФТА
                          @[@"•  12",
                            @"•  13",
                            @"•  14",
                            @"•  15",
                            @"•  16",
                            @"•  17",
                            @"•  18"],
                          
                          // ВЫБРАТЬ ОФОРМЛЕНИЕ
                          @[@"•  Светлая тема",
                            @"•  Темная тема"],
                          
                          // НАСТРОИТЬ ОФОРМЛЕНИЕ
                          @[@"•  Тема экрана цитат",
                            @"•  Bash.im",
                            @"•  Светлая 1",
                            @"•  Светлая 2",
                            @"•  Темная 1",
                            @"•  Темная 2",
                            @"•  Тема экрана меню",
                            @"•  Светлая",
                            @"•  Темная"],
                          
                          // ЦВЕТОВАЯ СХЕМА
                          @[@"•  ",
                            @"•  ",
                            @"•  ",
                            @"•  ",
                            @"•  ",
                            @"•  ",
                            @"•  ",
                            @"•  ",
                            @"•  ",
                            @"•  ",
                            @"•  ",
                            @"•  "],
                          
                          // ОТПРАВКА В СОЦ. СЕТИ
                          @[@"•  Текстом",
                            @"•  Картинкой"],
                          
                          // ИНФОРМАЦИЯ О ЦИТАТЕ
                          @[@"•  Показывать",
                            @"•  Скрывать"],
                          
                          // МЕНЮ ЦИТАТЫ
                          @[@"•  Скрывать после исп.",
                            @"•  Не скрывать"],
                          
                          // АВТОБЛОКИРОВКА
                          @[@"•  Включить",
                            @"•  Выключить"],
                          
                          // ОРИЕНТАЦИЯ
                          @[@"•  Авто",
                            @"•  Вертикальная",
                            @"•  Горизонтальная"],
                          
                          // БОКОВЫЕ ПОЛЯ
                          @[@"•  Вертикальная ориент.",
                            @"•  Нет",
                            @"•  Маленькие",
                            @"•  Средние",
                            @"•  Большие",
                            @"•  Горизонтальная ориент.",
                            @"•  Нет",
                            @"•  Маленькие",
                            @"•  Средние",
                            @"•  Большие"],
                          
                          // КЭШ
                          @[@"•  Очистить"],
                          
                          // ВКОНТАКТЕ
                          @[@"•  Выйти из учетной записи"]];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
        {
            [self selectSavedCells];
        });
    }
    return self;
}

- (void)selectSavedCells
{
    LOG(@"");
    
    NSIndexPath *index;
    
    // ------------------------------------------------
    
    index = [NSIndexPath indexPathForRow:kLGChapter.row inSection:LGIndexPathSectionChapters];
    
    [self.tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    // ------------------------------------------------
    
    if (kSettings.loadingFrom == 1)
        index = [NSIndexPath indexPathForRow:LGIndexPathRowLoadingFromInternet inSection:LGIndexPathSectionLoading];
    else if (kSettings.loadingFrom == 2)
        index = [NSIndexPath indexPathForRow:LGIndexPathRowLoadingFromLocal inSection:LGIndexPathSectionLoading];
    
    [self.tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Table View data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _headers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)_cells[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BottomTableViewCell *cell_;
    
    if (indexPath.section == LGIndexPathSectionLoading && indexPath.row == LGIndexPathRowLoadingAllNew)
    {
        BottomTableViewCellLoading *cell = [tableView dequeueReusableCellWithIdentifier:@"cellLoading"];
        
        cell.textLabel.text = _cells[indexPath.section][indexPath.row];
        
        if (!_isAllNewLoading)
        {
            cell.userInteractionEnabled = YES;
            cell.textLabel.text = @"Загрузить все новые";
            [cell.indicator stopAnimating];
        }
        else
        {
            cell.userInteractionEnabled = NO;
            cell.textLabel.text = @"Загрузка...";
            [cell.indicator startAnimating];
        }
        
        cell_ = cell;
    }
    else if (indexPath.section == LGIndexPathSectionSettings)
    {
        if ([_cellsFull[LGIndexPathSectionSettings] containsObject:_cells[LGIndexPathSectionSettings][indexPath.row]])
        {
            BottomTableViewCellMulti *cell = [tableView dequeueReusableCellWithIdentifier:@"cellMulti"];
            
            cell.textLabel.text = _cells[indexPath.section][indexPath.row];
            
            cell_ = cell;
        }
        else if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsColorSchema] boolValue]) // цветовая схема
        {
            BottomTableViewCellAddedColors *cell = [tableView dequeueReusableCellWithIdentifier:@"cellAddedColors"];
            
            cell.textLabel.text = _cells[indexPath.section][indexPath.row];
            
            if (indexPath.row == LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema1)        cell.color = kColorSchemaWhite;
            else if (indexPath.row == LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema2)   cell.color = kColorSchemaBlue1;
            else if (indexPath.row == LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema3)   cell.color = kColorSchemaBlue2;
            else if (indexPath.row == LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema4)   cell.color = kColorSchemaDutchTeal;
            else if (indexPath.row == LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema5)   cell.color = kColorSchemaAquamarine;
            else if (indexPath.row == LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema6)   cell.color = kColorSchemaGreenBlue;
            else if (indexPath.row == LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema7)   cell.color = kColorSchemaGreen;
            else if (indexPath.row == LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema8)   cell.color = kColorSchemaPurple;
            else if (indexPath.row == LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema9)   cell.color = kColorSchemaYellow;
            else if (indexPath.row == LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema10)  cell.color = kColorSchemaOrange;
            else if (indexPath.row == LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema11)  cell.color = kColorSchemaRedPink;
            else if (indexPath.row == LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema12)  cell.color = kColorSchemaPink;
            
            cell_ = cell;
        }
        else
        {
            BottomTableViewCellAdded *cell = [tableView dequeueReusableCellWithIdentifier:@"cellAdded"];
            
            if (([_openedCells[LGIndexPathRowSettingsSetTheme] boolValue] &&
                 (indexPath.row == LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsTopTheme ||
                  indexPath.row == LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsBottomTheme)) ||
                ([_openedCells[LGIndexPathRowSettingsIndent] boolValue] &&
                 (indexPath.row == LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentVertical ||
                  indexPath.row == LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentHorizontal)))
                cell.userInteractionEnabled = NO;
            else
                cell.userInteractionEnabled = YES;
            
            cell.textLabel.text = _cells[indexPath.section][indexPath.row];

            cell_ = cell;
        }
    }
    else
    {
        BottomTableViewCellStandart *cell = [tableView dequeueReusableCellWithIdentifier:@"cellStandart"];
        
        cell.textLabel.text = _cells[indexPath.section][indexPath.row];
        
        cell_ = cell;
    }
    
    cell_.isFirstCell = (indexPath.row == 0);
    
    return cell_;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    BottomTableViewSectionHeader *header = [BottomTableViewSectionHeader new];
    
    header.titleLabel.text = _headers[section];
    header.isFirstSection = (section == 0);
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    BottomTableViewSectionFooter *footer = [BottomTableViewSectionFooter new];

    return footer;
}

#pragma mark - Table View delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (kSystemVersion < 7 && indexPath.row == 0 ? 43.f : 44.f); // Костыль для iOS6
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0 ? 44.f : 43.f); // Костыль для iOS6 и iOS7
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
{
    [view removeFromSuperview];
    view = nil;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section
{
    [view removeFromSuperview];
    view = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([kTopView navBarViewSearchFieldIsFirstResponder]) [kTopView navBarViewSearchFieldResignFirstResponder];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"BottomTableViewController: %@ - cell did selected", cell.textLabel.text);
    
    if (indexPath.section == LGIndexPathSectionChapters) // разделы
    {
        kNavController.view.userInteractionEnabled = NO;
        
        kLGKit.pagesAmount = nil;
        kLGKit.pagesAbyssAmount = nil;
        kLGKit.currentPage = nil;
        kLGKit.currentAbyssPage = nil;
        
        BottomTableViewCellStandart *cell = (BottomTableViewCellStandart *)[tableView cellForRowAtIndexPath:indexPath];
        
        [kTopView tableViewCancelLoading];
        
        [self tableView:tableView unselectRowsInSection:indexPath.section except:indexPath];
        
        kLGChapter.name = cell.textLabel.text;
        
        [kTopView reload];
        
        [kNavController openCloseMenuAction];
        
        [kLGKit animationWithCrossDissolveView:kTopView completionHandler:^(BOOL complete)
         {
             if (complete) kNavController.view.userInteractionEnabled = YES;
         }];
    }
    else if (indexPath.section == LGIndexPathSectionLoading) // Загрузка цитат
    {
        if (indexPath.row == LGIndexPathRowLoadingFromInternet || indexPath.row == LGIndexPathRowLoadingFromLocal)
        {
            kNavController.view.userInteractionEnabled = NO;
            
            [kTopView tableViewCancelLoading];
            
            [self tableView:tableView unselectRowsInSection:indexPath.section except:indexPath];
            
            if (indexPath.row == LGIndexPathRowLoadingFromInternet)
            {
                kSettings.loadingFrom = 1;
                NSLog(@"BottomTableViewController: Загружать из интернета");
            }
            else if (indexPath.row == LGIndexPathRowLoadingFromLocal)
            {
                kSettings.loadingFrom = 2;
                NSLog(@"BottomTableViewController: Загружать из локальной базы");
            }
            
            [kTopView reload];
            
            [kNavController openCloseMenuAction];
            
            [kLGKit animationWithCrossDissolveView:kTopView completionHandler:^(BOOL complete)
             {
                 if (complete) kNavController.view.userInteractionEnabled = YES;
             }];
        }
        else if (indexPath.row == LGIndexPathRowLoadingAllNew)
        {
            BottomTableViewCellLoading *cell = (BottomTableViewCellLoading *)[tableView cellForRowAtIndexPath:indexPath];
            
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            
            if (kInternetStatusWithMessage)
            {
                cell.userInteractionEnabled = NO;
                
                _isAllNewLoading = YES;
                
                cell.textLabel.text = @"Загрузка...";
                [cell.indicator startAnimating];
                
                [UIView transitionWithView:cell.textLabel
                                  duration:0.3
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:nil
                                completion:nil];
                
                [UIView animateWithDuration:0.3
                                 animations:^(void)
                 {
                     cell.indicator.alpha = 1;
                 }];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void)
                               {
                                   [[QuoteGetter new] getQuotesForChapter:[LGChapter chapterWithType:LGChapterTypeNew]
                                                        completionHandler:^(NSError *error, NSMutableArray *quotesArray)
                                   {
                                       [[QuoteGetter new] getQuotesForChapter:[LGChapter chapterWithType:LGChapterTypeBest]
                                                            completionHandler:^(NSError *error, NSMutableArray *quotesArray)
                                       {
                                           [[QuoteGetter new] getQuotesForChapter:[LGChapter chapterWithType:LGChapterTypeRating]
                                                                completionHandler:^(NSError *error, NSMutableArray *quotesArray)
                                            {
                                               [[QuoteGetter new] getQuotesForChapter:[LGChapter chapterWithType:LGChapterTypeAbyss]
                                                                    completionHandler:^(NSError *error, NSMutableArray *quotesArray)
                                                {
                                                   [[QuoteGetter new] getQuotesForChapter:[LGChapter chapterWithType:LGChapterTypeAbyssTop]
                                                                        completionHandler:^(NSError *error, NSMutableArray *quotesArray)
                                                    {
                                                       [[QuoteGetter new] getQuotesForChapter:[LGChapter chapterWithType:LGChapterTypeAbyssBest]
                                                                            completionHandler:^(NSError *error, NSMutableArray *quotesArray)
                                                        {
                                                           [[QuoteGetter new] getQuotesForChapter:[LGChapter chapterWithType:LGChapterTypeRandom]
                                                                                completionHandler:^(NSError *error, NSMutableArray *quotesArray)
                                                            {
                                                                dispatch_async(dispatch_get_main_queue(), ^(void)
                                                                               {
                                                                                   _isAllNewLoading = NO;
                                                                                   
                                                                                   [kInfoVC showInfoWithText:@"Загрузка всех новых цитат в базу завершена."];
                                                                                   
                                                                                   BottomTableViewCellLoading *cell = (BottomTableViewCellLoading *)[tableView cellForRowAtIndexPath:indexPath];
                                                                                   
                                                                                   cell.textLabel.text = @"Загрузить все новые";
                                                                                   
                                                                                   [UIView transitionWithView:cell.textLabel
                                                                                                     duration:0.3
                                                                                                      options:UIViewAnimationOptionTransitionCrossDissolve
                                                                                                   animations:nil
                                                                                                   completion:nil];
                                                                                   
                                                                                   [UIView animateWithDuration:0.3 animations:^(void)
                                                                                    {
                                                                                        cell.indicator.alpha = 0;
                                                                                    }
                                                                                                    completion:^(BOOL finished)
                                                                                    {
                                                                                        cell.userInteractionEnabled = YES;
                                                                                        [cell.indicator stopAnimating];
                                                                                    }];
                                                                               });
                                                           }];
                                                       }];
                                                   }];
                                               }];
                                           }];
                                       }];
                                   }];
                               });
            }
            
            [kLGGoogleAnalytics sendEventWithCategory:@"Загрузить все новые цитаты" action:nil label:nil value:nil];
        }
    }
    else if (indexPath.section == LGIndexPathSectionSettings) // настройки
    {
        if (indexPath.row == LGIndexPathRowSettingsCloud) // iCloud
        {
            if (kLGCloud.isEnabledOnDevice)
            {
                [tableView beginUpdates];
                
                [self tableView:tableView unselectRowsInSection:indexPath.section except:indexPath];
                
                [self collapseMultiCellAtNumber:(int)indexPath.row];
                
                [tableView endUpdates];
                
                if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsCloud] boolValue])
                {
                    NSUInteger *indexRow = 0;
                    
                    if (kSettings.isCloudEnabled)
                        indexRow = indexPath.row+LGIndexPathRowSettingsCloudOn;
                    else
                        indexRow = indexPath.row+LGIndexPathRowSettingsCloudOff;
                    
                    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:indexRow inSection:LGIndexPathSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
            else
            {
                [self tableView:tableView unselectRowsInSection:indexPath.section];
                
                [kInfoVC showInfoWithText:[NSString stringWithFormat:@"%@", kLGCloud.statusDescription]];
            }
        }
        else if ([self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsCloud capacity:LGBottomMultiCellCapacityCloud])
        {
            [self tableView:tableView unselectAddRowsInSection:indexPath.section except:indexPath];
            
            kSettings.syncType = LGSyncBoth;
            [kStandartUserDefaults setInteger:kSettings.syncType forKey:@"syncType"];
            
            if (indexPath.row == LGIndexPathRowSettingsCloud + LGIndexPathRowSettingsCloudOn)
            {
                kSettings.isCloudEnabled = YES;
                
                [kLGCloud initialize];
                [kLGCloud sync];
            }
            else if (indexPath.row == LGIndexPathRowSettingsCloud + LGIndexPathRowSettingsCloudOff)
            {
                kSettings.isCloudEnabled = NO;
                kLGCloud.status = LGCloudStatusDisabled;
                kLGCloud.statusDescription = @"iCloud отключен.";
            }
            
            NSLog(@"BottomTableViewController: iCloud - %i", kSettings.isCloudEnabled);
        }
        else if (indexPath.row == [self getCurrentRowNumberFor:LGIndexPathRowSettingsFontSize]) // Размер Шрифта
        {
            [tableView beginUpdates];
            
            [self tableView:tableView unselectRowsInSection:indexPath.section except:indexPath];
            
            [self collapseMultiCellAtNumber:LGIndexPathRowSettingsFontSize];
            
            [tableView endUpdates];
            
            if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsFontSize] boolValue])
            {
                NSUInteger *indexRow = 0;
                
                if (kSettings.fontSize == 12)      indexRow = LGIndexPathRowSettingsFontSize + LGIndexPathRowSettingsFontSize12;
                else if (kSettings.fontSize == 13) indexRow = LGIndexPathRowSettingsFontSize + LGIndexPathRowSettingsFontSize13;
                else if (kSettings.fontSize == 14) indexRow = LGIndexPathRowSettingsFontSize + LGIndexPathRowSettingsFontSize14;
                else if (kSettings.fontSize == 15) indexRow = LGIndexPathRowSettingsFontSize + LGIndexPathRowSettingsFontSize15;
                else if (kSettings.fontSize == 16) indexRow = LGIndexPathRowSettingsFontSize + LGIndexPathRowSettingsFontSize16;
                else if (kSettings.fontSize == 17) indexRow = LGIndexPathRowSettingsFontSize + LGIndexPathRowSettingsFontSize17;
                else if (kSettings.fontSize == 18) indexRow = LGIndexPathRowSettingsFontSize + LGIndexPathRowSettingsFontSize18;
                
                [tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:indexRow inSection:LGIndexPathSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if ([self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsFontSize capacity:LGBottomMultiCellCapacityFontSize])
        {
            [self tableView:tableView unselectAddRowsInSection:indexPath.section except:indexPath];
            
            kNavController.view.userInteractionEnabled = NO;
            
            if (indexPath.row == LGIndexPathRowSettingsFontSize + LGIndexPathRowSettingsFontSize12)      kSettings.fontSize = 12;
            else if (indexPath.row == LGIndexPathRowSettingsFontSize + LGIndexPathRowSettingsFontSize13) kSettings.fontSize = 13;
            else if (indexPath.row == LGIndexPathRowSettingsFontSize + LGIndexPathRowSettingsFontSize14) kSettings.fontSize = 14;
            else if (indexPath.row == LGIndexPathRowSettingsFontSize + LGIndexPathRowSettingsFontSize15) kSettings.fontSize = 15;
            else if (indexPath.row == LGIndexPathRowSettingsFontSize + LGIndexPathRowSettingsFontSize16) kSettings.fontSize = 16;
            else if (indexPath.row == LGIndexPathRowSettingsFontSize + LGIndexPathRowSettingsFontSize17) kSettings.fontSize = 17;
            else if (indexPath.row == LGIndexPathRowSettingsFontSize + LGIndexPathRowSettingsFontSize18) kSettings.fontSize = 18;
            
            NSLog(@"BottomTableViewController: Размер шрифта %lu", (unsigned long)kSettings.fontSize);
            
            [kNavController openCloseMenuAction];
            
            [kTopView tableViewReloadWithCompletionHandler:^(void)
             {
                 [kLGKit redrawViewAndSubviews:kTopView];
                 
                 [kLGKit animationWithCrossDissolveView:kTopView completionHandler:^(BOOL complete)
                  {
                      if (complete) kNavController.view.userInteractionEnabled = YES;
                  }];
             }];
        }
        else if (indexPath.row == [self getCurrentRowNumberFor:LGIndexPathRowSettingsChooseTheme]) // Выбор оформления
        {
            [tableView beginUpdates];
            
            [self tableView:tableView unselectRowsInSection:indexPath.section except:indexPath];
            
            [self collapseMultiCellAtNumber:LGIndexPathRowSettingsChooseTheme];
            
            [tableView endUpdates];
            
            if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsChooseTheme] boolValue])
            {
                NSUInteger *indexRow = 0;
                
                if (kBottomTheme.type == BottomThemeTypeLight && kTopTheme.type == TopThemeTypeLightIndent)
                    indexRow = LGIndexPathRowSettingsChooseTheme + LGIndexPathRowSettingsThemeLight;
                else if (kBottomTheme.type == BottomThemeTypeDark && kTopTheme.type == TopThemeTypeDarkIndent)
                    indexRow = LGIndexPathRowSettingsChooseTheme + LGIndexPathRowSettingsThemeDark;
                else
                    indexRow = LGIndexPathRowSettingsChooseTheme;
                
                [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexRow inSection:LGIndexPathSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if ([self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsChooseTheme capacity:LGBottomMultiCellCapacityChooseTheme])
        {
            [self tableView:tableView unselectAddRowsInSection:indexPath.section except:indexPath];
            
            kNavController.view.userInteractionEnabled = NO;
            
            if (indexPath.row == LGIndexPathRowSettingsChooseTheme + LGIndexPathRowSettingsThemeLight)
            {
                kBottomTheme.type = BottomThemeTypeLight;
                kTopTheme.type    = TopThemeTypeLightIndent;
                
                NSLog(@"BottomTableViewController: Выбрано оформление - Светлая тема");
            }
            else if (indexPath.row == LGIndexPathRowSettingsChooseTheme + LGIndexPathRowSettingsThemeDark)
            {
                kBottomTheme.type = BottomThemeTypeDark;
                kTopTheme.type    = TopThemeTypeDarkIndent;
                
                NSLog(@"BottomTableViewController: Выбрано оформление - Темная тема");
            }
            
            [kPrerenderedImages updateMainViewImages];
            [kPrerenderedImages updateMenuViewImages];
            
            [kTopView tableViewReloadWithCompletionHandler:^(void)
             {
                 [kLGKit redrawViewAndSubviews:kTopView];
                 [kLGKit redrawViewAndSubviews:kBottomView];
                 
                 if (kSystemVersion >= 7 && !kSettings.isNavBarHidden)
                     [[UIApplication sharedApplication] setStatusBarStyle:(kTopTheme.isColorConflict ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent) animated:YES];
                 
                 __block BOOL topViewRedrawComplete = NO;
                 __block BOOL bottomViewRedrawComplete = NO;
                 
                 [kLGKit animationWithCrossDissolveView:kTopView completionHandler:^(BOOL complete)
                  {
                      if (complete)
                      {
                          topViewRedrawComplete = YES;
                          
                          if (topViewRedrawComplete && bottomViewRedrawComplete) kNavController.view.userInteractionEnabled = YES;
                      }
                  }];
                 
                 [kLGKit animationWithCrossDissolveView:kBottomView completionHandler:^(BOOL complete)
                  {
                      if (complete)
                      {
                          bottomViewRedrawComplete = YES;
                          
                          if (topViewRedrawComplete && bottomViewRedrawComplete) kNavController.view.userInteractionEnabled = YES;
                      }
                  }];
             }];
        }
        else if (indexPath.row == [self getCurrentRowNumberFor:LGIndexPathRowSettingsSetTheme]) // Настроить оформление
        {
            [tableView beginUpdates];
            
            [self tableView:tableView unselectRowsInSection:indexPath.section except:indexPath];
            
            [self collapseMultiCellAtNumber:LGIndexPathRowSettingsSetTheme];
            
            [tableView endUpdates];
            
            if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsSetTheme] boolValue])
            {
                if (kTopTheme.type == TopThemeTypeBash)             _rowThemeTop = LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsTopThemeBash;
                else if (kTopTheme.type == TopThemeTypeLightEntire) _rowThemeTop = LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsTopThemeLightEntire;
                else if (kTopTheme.type == TopThemeTypeLightIndent) _rowThemeTop = LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsTopThemeLightIndent;
                else if (kTopTheme.type == TopThemeTypeDarkEntire)  _rowThemeTop = LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsTopThemeDarkEntire;
                else if (kTopTheme.type == TopThemeTypeDarkIndent)  _rowThemeTop = LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsTopThemeDarkIndent;
                
                [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_rowThemeTop inSection:LGIndexPathSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionNone];
                
                if (kBottomTheme.type == BottomThemeTypeLight)      _rowThemeBottom = LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsBottomThemeLight;
                else if (kBottomTheme.type == BottomThemeTypeDark)  _rowThemeBottom = LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsBottomThemeDark;
                
                [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_rowThemeBottom inSection:LGIndexPathSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if ([self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsSetTheme capacity:LGBottomMultiCellCapacitySetTheme])
        {
            kNavController.view.userInteractionEnabled = NO;
            
            TopThemeType topThemeType_ = kTopTheme.type;
            BottomThemeType bottomThemeType_ = kBottomTheme.type;
            
            if (indexPath.row == LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsTopThemeBash)               kTopTheme.type = TopThemeTypeBash;
            else if (indexPath.row == LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsTopThemeLightEntire)   kTopTheme.type = TopThemeTypeLightEntire;
            else if (indexPath.row == LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsTopThemeLightIndent)   kTopTheme.type = TopThemeTypeLightIndent;
            else if (indexPath.row == LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsTopThemeDarkEntire)    kTopTheme.type = TopThemeTypeDarkEntire;
            else if (indexPath.row == LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsTopThemeDarkIndent)    kTopTheme.type = TopThemeTypeDarkIndent;
            
            else if (indexPath.row == LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsBottomThemeLight)      kBottomTheme.type = BottomThemeTypeLight;
            else if (indexPath.row == LGIndexPathRowSettingsSetTheme + LGIndexPathRowSettingsBottomThemeDark)       kBottomTheme.type = BottomThemeTypeDark;
            
            if (kTopTheme.type != topThemeType_)
            {
                [kPrerenderedImages updateMainViewImages];
                
                [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:_rowThemeTop inSection:LGIndexPathSectionSettings] animated:NO];
                _rowThemeTop = indexPath.row;
                
                [kNavController openCloseMenuAction];
                
                [kTopView tableViewReloadWithCompletionHandler:^(void)
                 {
                     [kLGKit redrawViewAndSubviews:kTopView];
                     
                     if (kSystemVersion >= 7 && !kSettings.isNavBarHidden)
                         [[UIApplication sharedApplication] setStatusBarStyle:(kTopTheme.isColorConflict ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent) animated:YES];
                     
                     [kLGKit animationWithCrossDissolveView:kTopView completionHandler:^(BOOL complete)
                      {
                          if (complete) kNavController.view.userInteractionEnabled = YES;
                      }];
                 }];
                
                NSLog(@"BottomTableViewController: Тема верхнего экрана - %@", kTopTheme.name);
            }
            else if (kBottomTheme.type != bottomThemeType_)
            {
                [kPrerenderedImages updateMenuViewImages];
                
                [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:_rowThemeBottom inSection:LGIndexPathSectionSettings] animated:NO];
                _rowThemeBottom = indexPath.row;
                
                [kLGKit redrawViewAndSubviews:kBottomView];
                
                [kLGKit animationWithCrossDissolveView:kBottomView completionHandler:^(BOOL complete)
                 {
                     if (complete) kNavController.view.userInteractionEnabled = YES;
                 }];
                
                NSLog(@"BottomTableViewController: Тема нижнего экрана - %@", kBottomTheme.name);
            }
        }
        else if (indexPath.row == [self getCurrentRowNumberFor:LGIndexPathRowSettingsColorSchema]) // Цветовая схема
        {
            [tableView beginUpdates];
            
            [self tableView:tableView unselectRowsInSection:indexPath.section except:indexPath];
            
            [self collapseMultiCellAtNumber:LGIndexPathRowSettingsColorSchema];
            
            [tableView endUpdates];
            
            if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsColorSchema] boolValue])
            {
                NSUInteger *indexRow = 0;
                
                if ([kSettings.colorMain isEqual:kColorSchemaWhite])              indexRow = LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema1;
                else if ([kSettings.colorMain isEqual:kColorSchemaBlue1])         indexRow = LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema2;
                else if ([kSettings.colorMain isEqual:kColorSchemaBlue2])         indexRow = LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema3;
                else if ([kSettings.colorMain isEqual:kColorSchemaDutchTeal])     indexRow = LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema4;
                else if ([kSettings.colorMain isEqual:kColorSchemaAquamarine])    indexRow = LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema5;
                else if ([kSettings.colorMain isEqual:kColorSchemaGreenBlue])     indexRow = LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema6;
                else if ([kSettings.colorMain isEqual:kColorSchemaGreen])         indexRow = LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema7;
                else if ([kSettings.colorMain isEqual:kColorSchemaPurple])        indexRow = LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema8;
                else if ([kSettings.colorMain isEqual:kColorSchemaYellow])        indexRow = LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema9;
                else if ([kSettings.colorMain isEqual:kColorSchemaOrange])        indexRow = LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema10;
                else if ([kSettings.colorMain isEqual:kColorSchemaRedPink])       indexRow = LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema11;
                else if ([kSettings.colorMain isEqual:kColorSchemaPink])          indexRow = LGIndexPathRowSettingsColorSchema + LGIndexPathRowSettingsColorSchema12;
                
                [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexRow inSection:LGIndexPathSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if ([self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsColorSchema capacity:LGBottomMultiCellCapacityColorSchema])
        {
            BottomTableViewCellStandart *cell = (BottomTableViewCellStandart *)[tableView cellForRowAtIndexPath:indexPath];
            
            kNavController.view.userInteractionEnabled = NO;
            
            [self tableView:tableView unselectAddRowsInSection:indexPath.section except:indexPath];
            
            kSettings.colorMain = [(BottomTableViewCellAddedColors *)cell color];
            
            NSLog(@"BottomTableViewController: Цветовая схема - %@", kSettings.colorMain);
            
            [kTopTheme update];
            [kBottomTheme update];
            [kPrerenderedImages updateMainViewImages];
            [kPrerenderedImages updateMenuViewImages];
            
            [kLGKit redrawViewAndSubviews:kTopView];
            [kLGKit redrawViewAndSubviews:kBottomView];
            
            if (kSystemVersion >= 7 && !kSettings.isNavBarHidden)
                [[UIApplication sharedApplication] setStatusBarStyle:(kTopTheme.isColorConflict ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent) animated:YES];
            
            __block BOOL isTopAnimationComplete = NO;
            __block BOOL isBottomAnimationComplete = NO;
            
            [kLGKit animationWithCrossDissolveView:kTopView completionHandler:^(BOOL complete)
             {
                 isTopAnimationComplete = YES;
                 
                 if (isTopAnimationComplete && isBottomAnimationComplete) kNavController.view.userInteractionEnabled = YES;
             }];
            
            [kLGKit animationWithCrossDissolveView:kBottomView completionHandler:^(BOOL complete)
             {
                 isBottomAnimationComplete = YES;
                 
                 if (isTopAnimationComplete && isBottomAnimationComplete) kNavController.view.userInteractionEnabled = YES;
             }];
        }
        else if (indexPath.row == [self getCurrentRowNumberFor:LGIndexPathRowSettingsPosting]) // Отправка в соц сети
        {
            [tableView beginUpdates];
            
            [self tableView:tableView unselectRowsInSection:indexPath.section except:indexPath];
            
            [self collapseMultiCellAtNumber:LGIndexPathRowSettingsPosting];
            
            [tableView endUpdates];
            
            if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsPosting] boolValue])
            {
                NSUInteger *indexRow = 0;
                
                if (kSettings.postingType == LGPostingByText)         indexRow = LGIndexPathRowSettingsPosting + LGIndexPathRowSettingsPostingText;
                else if (kSettings.postingType == LGPostingByPicture) indexRow = LGIndexPathRowSettingsPosting + LGIndexPathRowSettingsPostingPicture;
                
                [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexRow inSection:LGIndexPathSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if ([self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsPosting capacity:LGBottomMultiCellCapacityPosting])
        {
            [self tableView:tableView unselectAddRowsInSection:indexPath.section except:indexPath];
            
            if (indexPath.row == LGIndexPathRowSettingsPosting + LGIndexPathRowSettingsPostingText)         kSettings.postingType = LGPostingByText;
            else if (indexPath.row == LGIndexPathRowSettingsPosting + LGIndexPathRowSettingsPostingPicture) kSettings.postingType = LGPostingByPicture;
        }
        else if (indexPath.row == [self getCurrentRowNumberFor:LGIndexPathRowSettingsQuoteInfo]) // Информация о цитате
        {
            [tableView beginUpdates];
            
            [self tableView:tableView unselectRowsInSection:indexPath.section except:indexPath];
            
            [self collapseMultiCellAtNumber:LGIndexPathRowSettingsQuoteInfo];
            
            [tableView endUpdates];
            
            if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsQuoteInfo] boolValue])
            {
                NSUInteger *indexRow = 0;
                
                if (kSettings.quoteInfoVisibility == LGQuoteInfoVisibilityShow)       indexRow = LGIndexPathRowSettingsQuoteInfo + LGIndexPathRowSettingsQuoteInfoShow;
                else if (kSettings.quoteInfoVisibility == LGQuoteInfoVisibilityHide)  indexRow = LGIndexPathRowSettingsQuoteInfo + LGIndexPathRowSettingsQuoteInfoHide;
                
                [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexRow inSection:LGIndexPathSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if ([self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsQuoteInfo capacity:LGBottomMultiCellCapacityQuoteInfo])
        {
            [self tableView:tableView unselectAddRowsInSection:indexPath.section except:indexPath];
            
            if (indexPath.row == LGIndexPathRowSettingsQuoteInfo + LGIndexPathRowSettingsQuoteInfoShow)         kSettings.quoteInfoVisibility = LGQuoteInfoVisibilityShow;
            else if (indexPath.row == LGIndexPathRowSettingsQuoteInfo + LGIndexPathRowSettingsQuoteInfoHide)    kSettings.quoteInfoVisibility = LGQuoteInfoVisibilityHide;
            
            [kNavController openCloseMenuAction];
            
            [kTopView tableViewReloadWithCompletionHandler:^(void)
             {
                 [kLGKit redrawViewAndSubviews:kTopView];
                 
                 [kLGKit animationWithCrossDissolveView:kTopView completionHandler:^(BOOL complete)
                  {
                      if (complete) kNavController.view.userInteractionEnabled = YES;
                  }];
             }];
        }
        else if (indexPath.row == [self getCurrentRowNumberFor:LGIndexPathRowSettingsQuoteMenu]) // Меню цитаты
        {
            [tableView beginUpdates];
            
            [self tableView:tableView unselectRowsInSection:indexPath.section except:indexPath];
            
            [self collapseMultiCellAtNumber:LGIndexPathRowSettingsQuoteMenu];
            
            [tableView endUpdates];
            
            if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsQuoteMenu] boolValue])
            {
                NSUInteger *indexRow = 0;
                
                if (kSettings.quoteMenuAction == LGQuoteMenuActionClose)       indexRow = LGIndexPathRowSettingsQuoteMenu + LGIndexPathRowSettingsQuoteMenuActionClose;
                else if (kSettings.quoteMenuAction == LGQuoteMenuActionNone)   indexRow = LGIndexPathRowSettingsQuoteMenu + LGIndexPathRowSettingsQuoteMenuActionNone;
                
                [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexRow inSection:LGIndexPathSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if ([self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsQuoteMenu capacity:LGBottomMultiCellCapacityQuoteMenu])
        {
            [self tableView:tableView unselectAddRowsInSection:indexPath.section except:indexPath];
            
            if (indexPath.row == LGIndexPathRowSettingsQuoteMenu + LGIndexPathRowSettingsQuoteMenuActionClose)      kSettings.quoteMenuAction = LGQuoteMenuActionClose;
            else if (indexPath.row == LGIndexPathRowSettingsQuoteMenu + LGIndexPathRowSettingsQuoteMenuActionNone)  kSettings.quoteMenuAction = LGQuoteMenuActionNone;
        }
        else if (indexPath.row == [self getCurrentRowNumberFor:LGIndexPathRowSettingsAutoLock]) // Автоблокировка
        {
            [tableView beginUpdates];
            
            [self tableView:tableView unselectRowsInSection:indexPath.section except:indexPath];
            
            [self collapseMultiCellAtNumber:LGIndexPathRowSettingsAutoLock];
            
            [tableView endUpdates];
            
            if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsAutoLock] boolValue])
            {
                NSUInteger *indexRow = 0;
                
                if (kSettings.isAutoLockOn == YES)        indexRow = LGIndexPathRowSettingsAutoLock + LGIndexPathRowSettingsAutoLockOn;
                else if (kSettings.isAutoLockOn == NO)    indexRow = LGIndexPathRowSettingsAutoLock + LGIndexPathRowSettingsAutoLockOff;
                
                [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexRow inSection:LGIndexPathSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if ([self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsAutoLock capacity:LGBottomMultiCellCapacityAutoLock])
        {
            [self tableView:tableView unselectAddRowsInSection:indexPath.section except:indexPath];
            
            if (indexPath.row == LGIndexPathRowSettingsAutoLock + LGIndexPathRowSettingsAutoLockOn)         kSettings.isAutoLockOn = YES;
            else if (indexPath.row == LGIndexPathRowSettingsAutoLock + LGIndexPathRowSettingsAutoLockOff)   kSettings.isAutoLockOn = NO;
            
            [[UIApplication sharedApplication] setIdleTimerDisabled:!kSettings.isAutoLockOn];
        }
        else if (indexPath.row == [self getCurrentRowNumberFor:LGIndexPathRowSettingsOrientation]) // Ориентация
        {
            [tableView beginUpdates];
            
            [self tableView:tableView unselectRowsInSection:indexPath.section except:indexPath];
            
            [self collapseMultiCellAtNumber:LGIndexPathRowSettingsOrientation];
            
            [tableView endUpdates];
            
            if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsOrientation] boolValue])
            {
                NSUInteger *indexRow = 0;
                
                if (kSettings.orientation == LGOrientationAuto)             indexRow = LGIndexPathRowSettingsOrientation + LGIndexPathRowSettingsOrientationAuto;
                else if (kSettings.orientation == LGOrientationPortrait)    indexRow = LGIndexPathRowSettingsOrientation + LGIndexPathRowSettingsOrientationVertical;
                else if (kSettings.orientation == LGOrientationLandscape)   indexRow = LGIndexPathRowSettingsOrientation + LGIndexPathRowSettingsOrientationHorizontal;
                
                [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexRow inSection:LGIndexPathSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if ([self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsOrientation capacity:LGBottomMultiCellCapacityOrientation])
        {
            [self tableView:tableView unselectAddRowsInSection:indexPath.section except:indexPath];
            
            if (indexPath.row == LGIndexPathRowSettingsOrientation + LGIndexPathRowSettingsOrientationAuto)
                kSettings.orientation = LGOrientationAuto;
            else
            {
                UIInterfaceOrientation orientation = 0;
                CGSize size = CGSizeZero;
                
                if (indexPath.row == LGIndexPathRowSettingsOrientation + LGIndexPathRowSettingsOrientationVertical)
                {
                    kSettings.orientation = LGOrientationPortrait;
                    
                    orientation = UIInterfaceOrientationPortrait;
                    
                    size = CGSizeMake(kMainScreenSideMin, kMainScreenSideMax);
                }
                else if (indexPath.row == LGIndexPathRowSettingsOrientation + LGIndexPathRowSettingsOrientationHorizontal)
                {
                    kSettings.orientation = LGOrientationLandscape;
                    
                    orientation = UIInterfaceOrientationLandscapeLeft;
                    
                    size = CGSizeMake(kMainScreenSideMax, kMainScreenSideMin);
                }
                
                [[UIApplication sharedApplication] setStatusBarOrientation:orientation];
                [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
                
                if (!CGSizeEqualToSize(size, kNavController.view.bounds.size))
                {
                    [kNavController resizeViewsToSize:size];
                    [kNavController updateMainViewAfterRotate];
                }
            }
        }
        else if (indexPath.row == [self getCurrentRowNumberFor:LGIndexPathRowSettingsIndent]) // Боковые поля
        {
            [tableView beginUpdates];
            
            [self tableView:tableView unselectRowsInSection:indexPath.section except:indexPath];
            
            [self collapseMultiCellAtNumber:LGIndexPathRowSettingsIndent];
            
            [tableView endUpdates];
            
            if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsIndent] boolValue])
            {
                if (kSettings.indentVertical == LGIndentNone)           _rowIndentVertical = LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentVerticalNone;
                else if (kSettings.indentVertical == LGIndentSmall)     _rowIndentVertical = LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentVerticalSmall;
                else if (kSettings.indentVertical == LGIndentLarge)     _rowIndentVertical = LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentVerticalLarge;
                
                [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_rowIndentVertical inSection:LGIndexPathSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionNone];
                
                if (kSettings.indentHorizontal == LGIndentNone)         _rowIndentHorizontal = LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentHorizontalNone;
                else if (kSettings.indentHorizontal == LGIndentSmall)   _rowIndentHorizontal = LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentHorizontalSmall;
                else if (kSettings.indentHorizontal == LGIndentLarge)   _rowIndentHorizontal = LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentHorizontalLarge;
                
                [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_rowIndentHorizontal inSection:LGIndexPathSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
        else if ([self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsIndent capacity:LGBottomMultiCellCapacityIndent])
        {
            kNavController.view.userInteractionEnabled = NO;
            
            LGIndent indentVertical_ = kSettings.indentVertical;
            LGIndent indentHorizontal_ = kSettings.indentHorizontal;
            
            if (indexPath.row == LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentVerticalNone)           kSettings.indentVertical = LGIndentNone;
            else if (indexPath.row == LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentVerticalSmall)     kSettings.indentVertical = LGIndentSmall;
            else if (indexPath.row == LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentVerticalMedium)    kSettings.indentVertical = LGIndentMedium;
            else if (indexPath.row == LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentVerticalLarge)     kSettings.indentVertical = LGIndentLarge;
            
            else if (indexPath.row == LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentHorizontalNone)    kSettings.indentHorizontal = LGIndentNone;
            else if (indexPath.row == LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentHorizontalSmall)   kSettings.indentHorizontal = LGIndentSmall;
            else if (indexPath.row == LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentHorizontalMedium)  kSettings.indentHorizontal = LGIndentMedium;
            else if (indexPath.row == LGIndexPathRowSettingsIndent + LGIndexPathRowSettingsIndentHorizontalLarge)   kSettings.indentHorizontal = LGIndentLarge;
            
            if (kSettings.indentVertical != indentVertical_)
            {
                [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:_rowIndentVertical inSection:LGIndexPathSectionSettings] animated:NO];
                _rowIndentVertical = indexPath.row;
            }
            else if (kSettings.indentHorizontal != indentHorizontal_)
            {
                [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:_rowIndentHorizontal inSection:LGIndexPathSectionSettings] animated:NO];
                _rowIndentHorizontal = indexPath.row;
            }
            
            [kNavController openCloseMenuAction];
            
            [kTopView tableViewReloadWithCompletionHandler:^(void)
             {
                 [kLGKit redrawViewAndSubviews:kTopView];
                 
                 [kLGKit animationWithCrossDissolveView:kTopView completionHandler:^(BOOL complete)
                  {
                      if (complete) kNavController.view.userInteractionEnabled = YES;
                  }];
             }];
        }
        else if (indexPath.row == [self getCurrentRowNumberFor:LGIndexPathRowSettingsCash]) // Кэш
        {
            [tableView beginUpdates];
            
            [self tableView:tableView unselectRowsInSection:indexPath.section except:indexPath];
            
            [self collapseMultiCellAtNumber:LGIndexPathRowSettingsCash];
            
            [tableView endUpdates];
        }
        else if ([self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsCash capacity:LGBottomMultiCellCapacityCash])
        {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            
            [kInfoVC showInfoWithText:[NSString stringWithFormat:@"В кэше находится %i цитат общим размером %@.\n\nУверены что хотите очистить кэш?", [kLGCoreData getNumberOfQuotesInCash], [kLGCoreData getSizeOfQuotesInCash]]
                                 type:LGInfoViewTypeCashClean];
        }
        else if (indexPath.row == [self getCurrentRowNumberFor:LGIndexPathRowSettingsVk]) // Вконтакте logout
        {
            [tableView beginUpdates];
            
            [self tableView:tableView unselectRowsInSection:indexPath.section except:indexPath];
            
            [self collapseMultiCellAtNumber:LGIndexPathRowSettingsVk];
            
            [tableView endUpdates];
        }
        else if ([self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsVk capacity:LGBottomMultiCellCapacityVk])
        {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            
            if ([kLGVkontakte logout]) [kInfoVC showInfoWithText:@"Выход из учетной записи завершен."];
            else [kInfoVC showInfoWithText:@"Сначала нужно войти."];
        }
    }
    else if (indexPath.section == LGIndexPathSectionPurchases) // покупки
    {
        [self tableView:tableView unselectRowsInSection:indexPath.section];
        
        if (kInternetStatusWithMessage)
        {
            if ([kLGInAppPurchases canMakePurchases])
            {
                if ([kLGInAppPurchases isStoreLoadedWithMessage])
                {
                    if (indexPath.row == LGIndexPathRowPurchasesRemoveAds)
                    {
                        [kLGInAppPurchases purchaseProduct:@"ru.ApogeeStudio.Bash.RemoveAds33"];
                        [kLGGoogleAnalytics sendEventWithCategory:@"Покупки" action:@"Удалить рекламу (33р)" label:nil value:nil];
                    }
                    else if (indexPath.row == LGIndexPathRowPurchasesDonate33)
                    {
                        [kLGInAppPurchases purchaseProduct:@"ru.ApogeeStudio.Bash.Donate33"];
                        [kLGGoogleAnalytics sendEventWithCategory:@"Покупки" action:@"Отправить 33р" label:nil value:nil];
                    }
                    else if (indexPath.row == LGIndexPathRowPurchasesDonate66)
                    {
                        [kLGInAppPurchases purchaseProduct:@"ru.ApogeeStudio.Bash.Donate66"];
                        [kLGGoogleAnalytics sendEventWithCategory:@"Покупки" action:@"Отправить 66р" label:nil value:nil];
                    }
                    else if (indexPath.row == LGIndexPathRowPurchasesDonate99)
                    {
                        [kLGInAppPurchases purchaseProduct:@"ru.ApogeeStudio.Bash.Donate99"];
                        [kLGGoogleAnalytics sendEventWithCategory:@"Покупки" action:@"Отправить 99р" label:nil value:nil];
                    }
                    else if (indexPath.row == LGIndexPathRowPurchasesRestore)
                    {
                        [kLGInAppPurchases restoreCompletedTransactions];
                        [kLGGoogleAnalytics sendEventWithCategory:@"Покупки" action:@"Restore completed transactions" label:nil value:nil];
                    }
                }
            }
        }
    }
    else if (indexPath.section == LGIndexPathSectionExtra) // дополнительно
    {
        [self tableView:tableView unselectRowsInSection:indexPath.section];
        
        if (indexPath.row == LGIndexPathRowExtraApps || indexPath.row == LGIndexPathRowExtraRate)
        {
            if (kInternetStatusWithMessage)
            {
                if (indexPath.row == LGIndexPathRowExtraApps) // наши приложения
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.com/apps/ApogeeStudio"]];
                    [kLGGoogleAnalytics sendEventWithCategory:@"Наши приложения" action:nil label:nil value:nil];
                }
                else if (indexPath.row == LGIndexPathRowExtraRate) // оценить
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", kAppStoreId]]];
                    [kLGGoogleAnalytics sendEventWithCategory:@"Оценить в AppStore" action:nil label:nil value:nil];
                }
            }
        }
        else if (indexPath.row == LGIndexPathRowExtraSupport) // поддержка
        {
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *mailer = [MFMailComposeViewController new];
                mailer.mailComposeDelegate = self;
                [mailer setSubject:@"Проблемы с приложением Bash.Reader"];
                
                NSArray *toRecipients = [NSArray arrayWithObjects:@"ApogeeStudio.ru@gmail.com", nil];
                [mailer setToRecipients:toRecipients];
                
                if (kIsDevicePad) mailer.modalPresentationStyle = UIModalPresentationFormSheet;
                
                [kNavController presentViewController:mailer animated:YES completion:nil];
            }
            else [kInfoVC showInfoWithText:@"У вас не настроена почта.\n•   •   •\nEmail поддержки: ApogeeStudio.ru@gmail.com"];
            
            [kLGGoogleAnalytics sendEventWithCategory:@"Обращение в техподдержку" action:nil label:nil value:nil];
        }
        else if (indexPath.row == LGIndexPathRowExtraUpdateInfo) // новости обновления
        {
            [kNavController showUpdateInfo];
        }
        else if (indexPath.row == LGIndexPathRowExtraInfo) // инфо
        {
            [kInfoVC showInfoWithText:[NSString stringWithFormat:@"Bash.Reader %@\n•   •   •\nДанное приложение предоставляет пользователю информацию, взятую с сайта bash.im.\nАвтор программы не несет ответственности за содержание материалов сайта.\nПравообладатель контента bash.im.", kAppVersion]
                                 type:LGInfoViewTypeCopyrightInfo];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self compareIndexPath:indexPath withOpenedMultiRowsInSection:LGIndexPathSectionSettings capacity:LGBottomSectionCapacitySettings])
        [self collapseMultiCellAtNumber:(int)indexPath.row];
    else
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Unselect основных строк в секции

- (void)tableView:(UITableView *)tableView unselectRowsInSection:(NSInteger)section except:(NSIndexPath *)excepted
{
    NSArray *array = [tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in array)
        if (indexPath.section == section && indexPath.row != excepted.row)
        {
            if ([self compareIndexPath:indexPath withOpenedMultiRowsInSection:LGIndexPathSectionSettings capacity:LGBottomSectionCapacitySettings])
                [self collapseMultiCellAtNumber:(int)indexPath.row];
            
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
}

- (void)tableView:(UITableView *)tableView unselectRowsInSection:(NSInteger)section
{
    NSArray *array = [tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in array)
        if (indexPath.section == section)
        {
            if ([self compareIndexPath:indexPath withOpenedMultiRowsInSection:LGIndexPathSectionSettings capacity:LGBottomSectionCapacitySettings])
                [self collapseMultiCellAtNumber:(int)indexPath.row];
            
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
}

#pragma mark Unselect дополнительных строк в секции

- (void)tableView:(UITableView *)tableView unselectAddRowsInSection:(NSInteger)section except:(NSIndexPath *)excepted
{
    NSArray *array = [tableView indexPathsForSelectedRows];
    
    for (NSIndexPath *indexPath in array)
    {
        if (indexPath.section == section && indexPath.row != excepted.row && section == LGIndexPathSectionSettings &&
            ([self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsCloud         capacity:LGBottomMultiCellCapacityCloud] ||
             [self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsFontSize      capacity:LGBottomMultiCellCapacityFontSize] ||
             [self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsChooseTheme   capacity:LGBottomMultiCellCapacityChooseTheme] ||
             [self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsSetTheme      capacity:LGBottomMultiCellCapacitySetTheme] ||
             [self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsColorSchema   capacity:LGBottomMultiCellCapacityColorSchema] ||
             [self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsPosting       capacity:LGBottomMultiCellCapacityPosting] ||
             [self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsQuoteInfo     capacity:LGBottomMultiCellCapacityQuoteInfo] ||
             [self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsQuoteMenu     capacity:LGBottomMultiCellCapacityQuoteMenu] ||
             [self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsAutoLock      capacity:LGBottomMultiCellCapacityAutoLock] ||
             [self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsOrientation   capacity:LGBottomMultiCellCapacityOrientation] ||
             [self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsIndent        capacity:LGBottomMultiCellCapacityIndent] ||
             [self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsCash          capacity:LGBottomMultiCellCapacityCash] ||
             [self compareIndexPath:indexPath withAddedRowsInOpenedMultiRow:LGIndexPathRowSettingsVk            capacity:LGBottomMultiCellCapacityVk]))
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - Свертка/развертка дополнительных строк

- (void)collapseMultiCellAtNumber:(int)num
{
    NSMutableArray *indexArray = [NSMutableArray new];
    
    UITableViewRowAnimation anim = UITableViewRowAnimationTop;
    
    if ([_openedCells[num] boolValue])
    {
        for (int i=0; i<[(NSArray *)_cellsAddFull[num] count]; i++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i+1+num inSection:LGIndexPathSectionSettings];
            [indexArray addObject:indexPath];
            
            [_cells[LGIndexPathSectionSettings] removeObjectAtIndex:num+1];
        }
        
        [_openedCells replaceObjectAtIndex:num withObject:[NSNumber numberWithBool:NO]];
        [self.tableView deleteRowsAtIndexPaths:indexArray withRowAnimation:anim];
    }
    else
    {
        for (int i=0; i<[(NSArray *)_cellsAddFull[num] count]; i++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i+1+num inSection:LGIndexPathSectionSettings];
            [indexArray addObject:indexPath];
            
            [_cells[LGIndexPathSectionSettings] insertObject:[_cellsAddFull[num] objectAtIndex:i] atIndex:num+1+i];
        }
        
        [_openedCells replaceObjectAtIndex:num withObject:[NSNumber numberWithBool:YES]];
        [self.tableView insertRowsAtIndexPaths:indexArray withRowAnimation:anim];
    }
}

#pragma mark -

- (BOOL)compareIndexPath:(NSIndexPath *)indexPath withAddedRowsInOpenedMultiRow:(int)multiRow capacity:(int)capacity
{
    if ([_openedCells[multiRow] boolValue])
        for (int i=1; i<=capacity; i++)
            if (indexPath.row == multiRow + i) return YES;
    
    return NO;
}

- (BOOL)compareIndexPath:(NSIndexPath *)indexPath withOpenedMultiRowsInSection:(int)section capacity:(int)capacity
{
    if (indexPath.section == section)
        for (int i=0; i<capacity; i++)
            if ([[_openedCells objectAtIndex:i] boolValue] && indexPath.row == i) return YES;
    
    return NO;
}

#pragma mark -

- (int)getCurrentRowNumberFor:(int)row
{
    LGBottomMultiCellCapacity cellCapacityCloud = 0;
    LGBottomMultiCellCapacity cellCapacityFontSize = 0;
    LGBottomMultiCellCapacity cellCapacityChooseTheme = 0;
    LGBottomMultiCellCapacity cellCapacitySetTheme = 0;
    LGBottomMultiCellCapacity cellCapacityColorSchema = 0;
    LGBottomMultiCellCapacity cellCapacityPosting = 0;
    LGBottomMultiCellCapacity cellCapacityQuoteInfo = 0;
    LGBottomMultiCellCapacity cellCapacityQuoteMenu = 0;
    LGBottomMultiCellCapacity cellCapacityAutoLock = 0;
    LGBottomMultiCellCapacity cellCapacityOrientation = 0;
    LGBottomMultiCellCapacity cellCapacityIndent = 0;
    LGBottomMultiCellCapacity cellCapacityCash = 0;
    LGBottomMultiCellCapacity cellCapacityVk = 0;
    
    if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsCloud] boolValue])           cellCapacityCloud       = LGBottomMultiCellCapacityCloud;
    if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsFontSize] boolValue])        cellCapacityFontSize    = LGBottomMultiCellCapacityFontSize;
    if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsChooseTheme] boolValue])     cellCapacityChooseTheme = LGBottomMultiCellCapacityChooseTheme;
    if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsSetTheme] boolValue])        cellCapacitySetTheme    = LGBottomMultiCellCapacitySetTheme;
    if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsColorSchema] boolValue])     cellCapacityColorSchema = LGBottomMultiCellCapacityColorSchema;
    if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsPosting] boolValue])         cellCapacityPosting     = LGBottomMultiCellCapacityPosting;
    if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsQuoteInfo] boolValue])       cellCapacityQuoteInfo   = LGBottomMultiCellCapacityQuoteInfo;
    if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsQuoteMenu] boolValue])       cellCapacityQuoteMenu   = LGBottomMultiCellCapacityQuoteMenu;
    if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsAutoLock] boolValue])        cellCapacityAutoLock    = LGBottomMultiCellCapacityAutoLock;
    if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsOrientation] boolValue])     cellCapacityOrientation = LGBottomMultiCellCapacityOrientation;
    if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsIndent] boolValue])          cellCapacityIndent      = LGBottomMultiCellCapacityIndent;
    if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsCash] boolValue])            cellCapacityCash        = LGBottomMultiCellCapacityCash;
    if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsVk] boolValue])              cellCapacityVk          = LGBottomMultiCellCapacityVk;
    
    NSArray *array = [NSArray arrayWithObjects:
                      [NSNumber numberWithInt:cellCapacityCloud],
                      [NSNumber numberWithInt:cellCapacityFontSize],
                      [NSNumber numberWithInt:cellCapacityChooseTheme],
                      [NSNumber numberWithInt:cellCapacitySetTheme],
                      [NSNumber numberWithInt:cellCapacityColorSchema],
                      [NSNumber numberWithInt:cellCapacityPosting],
                      [NSNumber numberWithInt:cellCapacityQuoteInfo],
                      [NSNumber numberWithInt:cellCapacityQuoteMenu],
                      [NSNumber numberWithInt:cellCapacityAutoLock],
                      [NSNumber numberWithInt:cellCapacityOrientation],
                      [NSNumber numberWithInt:cellCapacityIndent],
                      [NSNumber numberWithInt:cellCapacityCash],
                      [NSNumber numberWithInt:cellCapacityVk], nil];
    
    int result = row;
    
    for (int i=0; i<row; i++)
        result = result + [[array objectAtIndex:i] intValue];
    
    return result;
}

- (void)setCloudSettingsTo:(BOOL)k
{
    if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsCloud] boolValue])
    {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:LGIndexPathRowSettingsCloud+LGIndexPathRowSettingsCloudOn inSection:LGIndexPathSectionSettings] animated:NO];
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:LGIndexPathRowSettingsCloud+LGIndexPathRowSettingsCloudOff inSection:LGIndexPathSectionSettings] animated:NO];
        
        if (k == YES) [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:LGIndexPathRowSettingsCloud+LGIndexPathRowSettingsCloudOn inSection:LGIndexPathSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionNone];
        else [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:LGIndexPathRowSettingsCloud+LGIndexPathRowSettingsCloudOff inSection:LGIndexPathSectionSettings] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)collapseCloudSettings
{
    if ([[_openedCells objectAtIndex:LGIndexPathRowSettingsCloud] boolValue])
    {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:LGIndexPathRowSettingsCloud inSection:LGIndexPathSectionSettings] animated:NO];
        [self collapseMultiCellAtNumber:LGIndexPathRowSettingsCloud];
    }
}

#pragma mark - Mail Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    [kNavController dismissViewControllerAnimated:YES completion:nil];
}

@end








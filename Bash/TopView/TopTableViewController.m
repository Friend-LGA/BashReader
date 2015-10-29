//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "TopTableViewController.h"
#import "TopTableViewCellStandartFull.h"
#import "TopTableViewCellStandartShort.h"
#import "TopTableViewCellStandartText.h"
#import "TopTableViewCellStandartFavourite.h"
#import "TopTableViewCellInfo.h"
#import "TopTableViewCellLoading.h"
#import "TopTableViewCellObject.h"
#import "TopView.h"
#import "TopTableView.h"
#import "BashCashQuotesEntity.h"
#import "BashCashQuoteObject.h"
#import "AppDelegate.h"
#import "LGKit.h"
#import "Settings.h"
#import "LGChapter.h"
#import "LGCoreData.h"
#import "QuoteGetter.h"
#import "InfoViewController.h"
#import "LGCloud.h"

@interface TopTableViewController ()

@property (strong, nonatomic) NSMutableArray    *dataArray;
@property (strong, nonatomic) QuoteGetter       *quoteGetter;
@property (strong, nonatomic) NSIndexPath       *tappedIndexPath;
@property (strong, nonatomic) NSMutableArray    *backgroundDataArray;
@property (strong, nonatomic) NSString          *errorMessage;
@property (assign, nonatomic) BOOL              isNeedsToLoadQuotes;
@property (assign, nonatomic) BOOL              isCancelled;
@property (assign, nonatomic) BOOL              isInfoRowsAdded;
@property (assign, nonatomic) BOOL              isBackgroundLoading;
@property (assign, nonatomic) BOOL              isQuotesLoading;
@property (assign, nonatomic) NSUInteger        quotesAmount;
@property (assign, nonatomic) NSUInteger        numberOfObjectsInDB;

@property (assign, nonatomic) CGFloat           cellWidth;
@property (assign, nonatomic) CGFloat           cellOriginX;

@property (strong, nonatomic) TopTableViewCellLoading       *prototypeCell1;
@property (strong, nonatomic) TopTableViewCellInfo          *prototypeCell2;
@property (strong, nonatomic) TopTableViewCellStandartFull  *prototypeCell3;
@property (strong, nonatomic) TopTableViewCellStandartShort *prototypeCell4;
@property (strong, nonatomic) TopTableViewCellStandartText  *prototypeCell5;

@end

@implementation TopTableViewController

- (id)init
{
    LOG(@"");
    
    TopTableView *tableView = [TopTableView new];
    
    self = [super initWithTableView:tableView isAsyncCalculatingHeightForRows:YES];
    if (self)
    {
        if (kSettings.loadingFrom != LGLoadingFromLocal && kLGChapter.type != LGChapterTypeFavourites && kLGChapter.type != LGChapterTypeSearch)
            self.tableView.refreshViewEnabled = YES;
        
        self.showPlaceholderAtAppear = NO;
        self.reloadTableViewAnimationsEnabled = NO;
        
        [self.tableView registerClass:[TopTableViewCellStandartFull class]  forCellReuseIdentifier:@"cellFull"];
        [self.tableView registerClass:[TopTableViewCellStandartShort class] forCellReuseIdentifier:@"cellShort"];
        [self.tableView registerClass:[TopTableViewCellStandartText class]  forCellReuseIdentifier:@"cellText"];
        [self.tableView registerClass:[TopTableViewCellInfo class]          forCellReuseIdentifier:@"cellInfo"];
        [self.tableView registerClass:[TopTableViewCellInfo class]          forCellReuseIdentifier:@"cellError"];
        [self.tableView registerClass:[TopTableViewCellLoading class]       forCellReuseIdentifier:@"cellLoading"];
        
        // -------------------------------------
        
        if (kLGChapter.type == LGChapterTypeSearch && kSettings.loadingFrom == LGLoadingFromInternet && !kLGKit.searchText.length)
            _dataArray = [NSMutableArray new];
        else
            _dataArray = @[@"cellLoading"].mutableCopy;
        
        if (kSettings.loadingFrom == LGLoadingFromInternet)
            _quoteGetter = [QuoteGetter new];
        
        // Gestures ----------------------------
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        doubleTapGesture.numberOfTouchesRequired = 1;
        [self.tableView addGestureRecognizer:doubleTapGesture];
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGesture:)];
        singleTapGesture.numberOfTapsRequired = 1;
        singleTapGesture.numberOfTouchesRequired = 1;
        [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
        [self.tableView addGestureRecognizer:singleTapGesture];
        
        //
        
        _prototypeCell1 = [[TopTableViewCellLoading alloc]          initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
        _prototypeCell2 = [[TopTableViewCellInfo alloc]             initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
        _prototypeCell3 = [[TopTableViewCellStandartFull alloc]     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
        _prototypeCell4 = [[TopTableViewCellStandartShort alloc]    initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
        _prototypeCell5 = [[TopTableViewCellStandartText alloc]     initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
    }
    return self;
}

- (void)dealloc
{
    LOG(@"");
    
    [self cancelLoading];
}

- (void)refreshTableViewDataWithCompletionHandler:(void (^)())completionHandler
{
    [self cancelLoading];
    
    if (kLGChapter.type == LGChapterTypeSearch && kSettings.loadingFrom == LGLoadingFromInternet && !kLGKit.searchText.length)
        _dataArray = [NSMutableArray new];
    else
        _dataArray = @[@"cellLoading"].mutableCopy;
    
    if (kSettings.loadingFrom == LGLoadingFromInternet)
        _quoteGetter = [QuoteGetter new];
    
    [super refreshTableViewDataWithCompletionHandler:completionHandler];
}

#pragma mark - Table View data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

#pragma mark - Table View delegate

- (void)reloadTableViewDataAnimated:(BOOL)animated completionHandler:(void (^)())completionHandler
{
    BOOL isPortrait = (kNavController.view.bounds.size.width < kNavController.view.bounds.size.height);
    
    CGFloat width = self.tableView.frame.size.width;
    
    _cellWidth = width;
    _cellOriginX = 0.f;
    
    if ((isPortrait && kSettings.indentVertical == LGIndentSmall) || (!isPortrait && kSettings.indentHorizontal == LGIndentSmall))
    {
        _cellOriginX = width*0.05;
        _cellWidth = width*0.9;
    }
    else if ((isPortrait && kSettings.indentVertical == LGIndentMedium) || (!isPortrait && kSettings.indentHorizontal == LGIndentMedium))
    {
        _cellOriginX = width*0.1;
        _cellWidth = width*0.8;
    }
    else if ((isPortrait && kSettings.indentVertical == LGIndentLarge) || (!isPortrait && kSettings.indentHorizontal == LGIndentLarge))
    {
        _cellOriginX = width*0.15;
        _cellWidth = width*0.7;
    }
    
    if (_cellWidth < 280.f)
    {
        _cellWidth = 280.f;
        _cellOriginX = (width-_cellWidth)/2;
    }
    
    [super reloadTableViewDataAnimated:animated completionHandler:completionHandler];
}

#pragma mark - Scroll View delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > scrollView.contentSize.height-2000.f)
        [self loadQuotes];
}

#pragma mark - Gesture Recognizers

- (void)singleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    LOG(@"");
    
    if ([kTopView navBarViewSearchFieldIsFirstResponder]) [kTopView navBarViewSearchFieldResignFirstResponder];
    else
    {
        CGPoint location = [gestureRecognizer locationInView:self.tableView];
        _tappedIndexPath = [self.tableView indexPathForRowAtPoint:location];
        
        TopTableViewCellStandartFull *cell = (TopTableViewCellStandartFull *)[self.tableView cellForRowAtIndexPath:_tappedIndexPath];
        
        if (([cell.reuseIdentifier isEqualToString:@"cellShort"] && [cell isKindOfClass:[TopTableViewCellStandartShort class]]) ||
            ([cell.reuseIdentifier isEqualToString:@"cellText"] && [cell isKindOfClass:[TopTableViewCellStandartText class]]) ||
            ([cell.reuseIdentifier isEqualToString:@"cellFavourite"] && [cell isKindOfClass:[TopTableViewCellStandartFavourite class]]))
        {
            location = [gestureRecognizer locationInView:cell];
            
            if (CGRectContainsPoint(CGRectMake(cell.bgView.frame.origin.x, cell.textLabel.frame.origin.y, cell.bgView.frame.size.width, cell.textLabel.frame.size.height), location))
            {
                NSMutableArray *stringsArray = [NSMutableArray new];
                if (cell.quote.number)              [stringsArray addObject:[NSString stringWithFormat:@"Цитата номер:  #%lu", (unsigned long)cell.quote.number]];
                if (cell.quote.date.length)         [stringsArray addObject:[NSString stringWithFormat:@"Дата:  %@", cell.quote.date]];
                if (cell.quote.ratingString.length) [stringsArray addObject:[NSString stringWithFormat:@"Рейтинг:  %@", cell.quote.ratingString]];
                NSString *string = [stringsArray componentsJoinedByString:@"\n"];
                
                [kInfoVC showInfoWithText:string
                                     type:(kLGChapter.type == LGChapterTypeFavourites ? LGInfoViewTypeButtonsFavourites : LGInfoViewTypeButtonsMain)
                              chapterType:kLGChapter.type
                                    quote:cell.quote
                                     cell:cell];
            }
            else if (([cell.reuseIdentifier isEqualToString:@"cellShort"] && [cell isKindOfClass:[TopTableViewCellStandartShort class]]) &&
                     CGRectContainsPoint(cell.favouriteImageView.frame, location))
            {
                [cell selectFavouriteButtonWithAction:YES];
            }
        }
        else if ([cell.reuseIdentifier isEqualToString:@"cellFull"] && [cell isKindOfClass:[TopTableViewCellStandartFull class]])
        {
            location = [gestureRecognizer locationInView:cell];
            
            if (CGRectContainsPoint(CGRectMake(cell.bgView.frame.origin.x, cell.textLabel.frame.origin.y, cell.bgView.frame.size.width, cell.textLabel.frame.size.height), location))
            {
                NSMutableArray *stringsArray = [NSMutableArray new];
                if (cell.quote.number)              [stringsArray addObject:[NSString stringWithFormat:@"Цитата номер:  #%lu", (unsigned long)cell.quote.number]];
                if (cell.quote.date.length)         [stringsArray addObject:[NSString stringWithFormat:@"Дата:  %@", cell.quote.date]];
                if (cell.quote.ratingString.length) [stringsArray addObject:[NSString stringWithFormat:@"Рейтинг:  %@", cell.quote.ratingString]];
                NSString *string = [stringsArray componentsJoinedByString:@"\n"];
                
                [kInfoVC showInfoWithText:string
                                     type:(kLGChapter.type == LGChapterTypeFavourites ? LGInfoViewTypeButtonsFavourites : LGInfoViewTypeButtonsMain)
                              chapterType:kLGChapter.type
                                    quote:cell.quote
                                     cell:cell];
            }
            else if (CGRectContainsPoint(cell.plusImageView.frame, location))
            {
                [cell setPlusButtonSelected:YES];
            }
            else if (CGRectContainsPoint(cell.minusImageView.frame, location))
            {
                [cell setMinusButtonSelected:YES];
            }
            else if (CGRectContainsPoint(cell.bayanImageView.frame, location))
            {
                [cell setBayanButtonSelected:YES];
            }
            else if (CGRectContainsPoint(cell.favouriteImageView.frame, location))
            {
                [cell selectFavouriteButtonWithAction:YES];
            }
        }
        else if ([cell.reuseIdentifier isEqualToString:@"cellError"] && [cell isKindOfClass:[TopTableViewCellInfo class]])
        {
            _errorMessage = nil;
            
            [self.dataArray removeLastObject];
            [self.dataArray addObject:@"cellLoading"];
            
            __weak typeof(self) wself = self;
            
            [self reloadTableViewDataAfterIndex:self.dataArray.count-1 animated:NO completionHandler:^(void)
            {
                if (wself)
                {
                    __strong typeof(wself) self = wself;
                    
                    NSLog(@"TopTableViewController: Quotes loading BEGIN - touch");
                    
                    [self loadQuotes];
                }
            }];
        }
    }
}

- (void)doubleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    LOG(@"");
    
    [kTopView doubleTapGesture:gestureRecognizer];
}

#pragma mark -

- (void)deleteTappedRow
{
    if (_tappedIndexPath)
    {
        _quotesAmount--;
        _numberOfObjectsInDB--;
        [self.dataArray removeObjectAtIndex:_tappedIndexPath.row];
        [self removeCellsAtIndexes:[NSIndexSet indexSetWithIndex:_tappedIndexPath.row] completionHandler:nil];
    }
}

- (void)cancelLoading
{
    LOG(@"");
    
    _isCancelled = YES;
    
    if (_quoteGetter)
    {
        [_quoteGetter cancell];
        _quoteGetter = nil;
    }
    
    _backgroundDataArray = nil;
    
    _isQuotesLoading = NO;
    
    _isNeedsToLoadQuotes = NO;
    
    _isBackgroundLoading = NO;
    
    _isInfoRowsAdded = NO;
    
    _quotesAmount = 0;
    
    _numberOfObjectsInDB = 0;
}

- (BOOL)isCancelled:(int)point
{
    if (_isCancelled)
    {
        NSLog(@"TopTableViewController: Остановка потока %i", point);
        
        return YES;
    }
    else return NO;
}

- (void)loadQuotes
{
    NSLog(@"");
    
    if (kNavController.isLaunched && !_isQuotesLoading &&
        !(kLGChapter.type == LGChapterTypeFavourites && kLGCloud.status == LGCloudStatusSyncing) &&
        !(kLGChapter.type == LGChapterTypeSearch && kSettings.loadingFrom == LGLoadingFromInternet && !kLGKit.searchText.length) &&
        ([_dataArray.lastObject isKindOfClass:[NSString class]] && [_dataArray.lastObject isEqualToString:@"cellLoading"]))
    {
        LOG(@"");
        
        __weak typeof(self) wself = self;
        __weak typeof(self.quoteGetter) wquoteGetter = self.quoteGetter;
        
        _isQuotesLoading = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void)
                       {
                           if (kSettings.loadingFrom == LGLoadingFromInternet && kLGChapter.type != LGChapterTypeFavourites)
                           {
                               // загрузка из сети
                               
                               if (_backgroundDataArray) [self loadQuotesDoneFromInternetWithQuotesArray:_backgroundDataArray];
                               else if (_isBackgroundLoading) _isNeedsToLoadQuotes = YES;
                               else if (wquoteGetter)
                               {
                                   [_quoteGetter getQuotesForChapter:kLGChapter completionHandler:^(NSError *error, NSMutableArray *quotesArray)
                                    {
                                        if (wself && wquoteGetter)
                                        {
                                            __strong typeof(wself) self = wself;
                                            
                                            if (!error) [self loadQuotesDoneFromInternetWithQuotesArray:quotesArray];
                                            else
                                            {
                                                self.isQuotesLoading = NO;
                                                
                                                self.errorMessage = error.domain;
                                                
                                                self.isBackgroundLoading = NO;
                                                
                                                [self.dataArray removeLastObject];
                                                [self.dataArray addObject:@"cellError"];
                                                
                                                [self reloadTableViewDataAfterIndex:self.dataArray.count-1 animated:NO completionHandler:nil];
                                            }
                                        }
                                    }];
                               }
                           }
                           else
                           {
                               // загрузка из базы
                               
                               NSSortDescriptor *sortDescriptor;
                               if (kLGChapter.type == LGChapterTypeNew || kLGChapter.type == LGChapterTypeAbyssBest || kLGChapter.type == LGChapterTypeSearch)
                                   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:NO];
                               else if (kLGChapter.type == LGChapterTypeBest || kLGChapter.type == LGChapterTypeRandom || kLGChapter.type == LGChapterTypeAbyss)
                                   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sequence" ascending:YES];
                               else if (kLGChapter.type == LGChapterTypeRating)
                                   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rating" ascending:NO];
                               else if (kLGChapter.type == LGChapterTypeAbyssTop)
                                   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
                               else if (kLGChapter.type == LGChapterTypeFavourites)
                                   sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:NO];
                               
                               NSArray *quotesArray;
                               
                               if (kLGChapter.type == LGChapterTypeFavourites)
                                   quotesArray = [kLGCoreData getArrayOfBashFavouriteQuotesDataBaseWithSortDescriptor:sortDescriptor start:_quotesAmount limit:50];
                               else
                                   quotesArray = [kLGCoreData getArrayOfBashCashQuotesDataBaseWithEntity:kLGChapter.entity sortDescriptor:sortDescriptor start:_quotesAmount limit:50];
                               
                               [self loadQuotesDoneFromLocalWithQuotesArray:quotesArray];
                           }
                       });
    }
}

- (void)loadQuotesDoneFromLocalWithQuotesArray:(NSArray *)quotesArray
{
    LOG(@"");
    
    _quotesAmount += quotesArray.count;
    
    BOOL isAllQuotesLoaded = (quotesArray.count < 50);
    
    //NSLog(@"TopTableViewController: Quotes added from DB ALL - %lu", (unsigned long)self.quotesAmount);
    //NSLog(@"TopTableViewController: Quotes added from DB NOW - %lu", (unsigned long)quotesArray.count);
    
    NSMutableArray *newQuotesArray = [NSMutableArray new];
    
    for (NSUInteger i=0; i<quotesArray.count; i++)
    {
        BashCashQuotesEntity *quote = quotesArray[i];
        
        BashCashQuoteObject *quoteObject = [BashCashQuoteObject new];
        quoteObject.date        = quote.date;
        quoteObject.text        = quote.text;
        if ([quote isKindOfClass:[BashCashQuotesEntity class]])
        {
            quoteObject.number      = quote.number.integerValue;
            quoteObject.sequence    = quote.sequence.integerValue;
            if (quote.rating)
            {
                NSUInteger rating = [quote.rating integerValue];
                quoteObject.rating          = rating;
                quoteObject.ratingString    = (rating > 0 ? [NSString stringWithFormat:@"%lu", (unsigned long)rating] : @"???");
            }
        }
        quoteObject.source      = quote.source;
        quoteObject.isFavourite = [kLGCoreData isQuoteInFavourites:quote];
        
        [newQuotesArray addObject:quoteObject];
    }
    
    [self loadQuotesDoneWithQuotesArray:newQuotesArray isAllQuotesLoaded:isAllQuotesLoaded];
}

- (void)loadQuotesDoneFromInternetWithQuotesArray:(NSMutableArray *)quotesArray
{
    //NSLog(@"TopTableViewController: Quotes loaded from Bash ALL - %lu", (unsigned long)self.quoteGetter.quotesAmount);
    //NSLog(@"TopTableViewController: Quotes loaded from Bash NOW - %lu", (unsigned long)quotesArray.count);
    
    [self loadQuotesDoneWithQuotesArray:quotesArray isAllQuotesLoaded:NO];
}

- (void)loadQuotesDoneWithQuotesArray:(NSMutableArray *)quotesArray isAllQuotesLoaded:(BOOL)isAllQuotesLoaded
{
    LOG(@"");
    
    if (kSettings.loadingFrom == LGLoadingFromInternet)
        NSLog(@"TopTableViewController: Quotes added ALL - %lu", (unsigned long)self.quoteGetter.quotesAmount);
    else
        NSLog(@"TopTableViewController: Quotes added ALL - %lu", (unsigned long)self.quotesAmount);
    NSLog(@"TopTableViewController: Quotes added NOW - %lu", (unsigned long)quotesArray.count);
    
    __weak typeof(self) wself = self;
    __weak typeof(self.quoteGetter) wquoteGetter = self.quoteGetter;
    
    // Add info rows
    
    if (!self.isInfoRowsAdded)
    {
        self.isInfoRowsAdded = YES;
        
        if (!quotesArray.count || kLGChapter.type == LGChapterTypeFavourites || kLGChapter.type == LGChapterTypeSearch || (kSettings.loadingFrom == LGLoadingFromLocal && kLGChapter.type != LGChapterTypeBest && kLGChapter.type != LGChapterTypeAbyssTop) || (kSettings.loadingFrom == LGLoadingFromInternet && kLGChapter.type == LGChapterTypeNew))
        {
            [quotesArray insertObject:@"cellInfo" atIndex:0];
        }
        else if (kLGChapter.type == LGChapterTypeBest)
        {
            NSUInteger tempRating = 0;
            
            NSUInteger mostRatingQuote = 0;
            NSUInteger repeatedQuote = 0;
            
            NSMutableArray *tempArray = [NSMutableArray new];
            
            for (NSUInteger i=0; i<quotesArray.count; i++)
            {
                BashCashQuoteObject *quote = quotesArray[i];
                
                if (!repeatedQuote)
                    for (NSNumber *number in tempArray)
                        if (quote.number == number.integerValue)
                        {
                            repeatedQuote = i;
                            break;
                        }
                
                if (quote.rating > tempRating)
                {
                    tempRating = quote.rating;
                    mostRatingQuote = i;
                }
                
                [tempArray addObject:[NSNumber numberWithInteger:quote.number]];
            }
            
            [quotesArray insertObject:@"cellInfo" atIndex:0];
            
            if (mostRatingQuote != 0 || repeatedQuote != 0)
            {
                NSUInteger index = MIN(mostRatingQuote, repeatedQuote);
                if (index == 0) index = MAX(mostRatingQuote, repeatedQuote);
                
                [quotesArray insertObject:@"cellInfo" atIndex:index+1];
            }
        }
    }
    
    // Добавление cellLoading
    if (kLGChapter.type != LGChapterTypeBest && kLGChapter.type != LGChapterTypeAbyssTop && kLGChapter.type != LGChapterTypeSearch &&
        !((kSettings.loadingFrom == LGLoadingFromLocal || kLGChapter.type == LGChapterTypeFavourites) && isAllQuotesLoaded))
        [quotesArray addObject:@"cellLoading"];
    
    if (kSettings.loadingFrom == LGLoadingFromInternet && !wquoteGetter) return;
    
    if ([self.dataArray.lastObject isKindOfClass:[NSString class]] && [self.dataArray.lastObject isEqualToString:@"cellLoading"])
        [self.dataArray removeLastObject];
    
    NSUInteger index = self.dataArray.count;

    [self.dataArray addObjectsFromArray:quotesArray];
    
    if (self.backgroundDataArray) self.backgroundDataArray = nil;
    
    if (kSettings.loadingFrom == LGLoadingFromInternet && !wquoteGetter) return;
    
    if (!_numberOfObjectsInDB)
    {
        if (kLGChapter.type == LGChapterTypeFavourites)
            _numberOfObjectsInDB = [kLGCoreData getNumberOfObjectsInFavouriteDataBase];
        else
            _numberOfObjectsInDB = [kLGCoreData getNumberOfObjectsInCashDataBaseWithEntity:kLGChapter.entity];
    }
    
    [self reloadTableViewDataAfterIndex:index animated:NO completionHandler:^(void)
    {
        if (wself)
        {
            __strong typeof(wself) self = wself;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
            {
                if (kSettings.loadingFrom == LGLoadingFromInternet && kLGChapter.type != LGChapterTypeBest && kLGChapter.type != LGChapterTypeAbyssTop && kLGChapter.type != LGChapterTypeFavourites && kLGChapter.type != LGChapterTypeSearch && wquoteGetter)
                {
                    NSLog(@"TopTableViewController: Quotes loading BEGIN - background");
                    
                    self.isBackgroundLoading = YES;
                    
                    [self.quoteGetter getQuotesForChapter:kLGChapter completionHandler:^(NSError *error, NSMutableArray *quotesArray)
                     {
                         if (wself && wquoteGetter)
                         {
                             __strong typeof(wself) self = wself;
                             
                             if (!error)
                             {
                                 if (self.isNeedsToLoadQuotes)
                                 {
                                     self.isNeedsToLoadQuotes = NO;
                                     
                                     self.isBackgroundLoading = NO;
                                     
                                     [self loadQuotesDoneWithQuotesArray:quotesArray isAllQuotesLoaded:isAllQuotesLoaded];
                                 }
                                 else
                                 {
                                     self.backgroundDataArray = quotesArray;
                                     
                                     self.isBackgroundLoading = NO;
                                 }
                             }
                             else
                             {
                                 self.isQuotesLoading = NO;
                                 
                                 self.errorMessage = error.domain;
                                 
                                 self.isBackgroundLoading = NO;
                                 
                                 [self.dataArray removeLastObject];
                                 [self.dataArray addObject:@"cellError"];
                                 
                                 [self reloadTableViewDataAfterIndex:self.dataArray.count-1 animated:NO completionHandler:nil];
                             }
                         }
                     }];
                }
             
                self.isQuotesLoading = NO;
                
                [UIView setAnimationsEnabled:YES]; // почему-то иногда пропадают анимации
                
                NSLog(@"TopTableViewController: Quotes loading END");
            });
        }
    }];
}

@end














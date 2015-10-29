//
//  Created by Grigory Lutkov on 22.11.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "QuoteGetter.h"
#import "HTMLReader.h"
#import "AppDelegate.h"
#import "LGKit.h"
#import "Settings.h"
#import "LGChapter.h"
#import "LGCoreData.h"
#import "TopView.h"
#import "BashCashQuotesEntity.h"
#import "BashCashQuoteObject.h"

#pragma mark - Private

@interface QuoteGetter ()

@property (strong, nonatomic) LGChapter         *chapter;
@property (strong, nonatomic) NSMutableArray    *loadedQuotes;
@property (strong, nonatomic) NSDate            *start;
@property (strong, nonatomic) NSString          *quoteAmount;
@property (strong, nonatomic) NSString          *quoteText;
@property (strong, nonatomic) NSString          *quoteNumber;
@property (strong, nonatomic) NSString          *quoteDate;
@property (strong, nonatomic) NSString          *quoteRating;
//@property (strong, nonatomic) NSString          *wantMore;
@property (assign, nonatomic) NSUInteger        pagesAmount;
@property (assign, nonatomic) NSUInteger        currentPage;
@property (strong, nonatomic) NSDate            *currentDate;
@property (strong, nonatomic) void              (^completionHandler)(NSError *error, NSMutableArray *quotesArray);
@property (assign, nonatomic) BOOL              isCancelled;
@property (strong, nonatomic) NSMutableArray    *numbersArrayFull;
@property (assign, nonatomic) BOOL              isCashCleared;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

#pragma mark - Implementation

@implementation QuoteGetter

- (id)init
{
    LOG(@"");
    
    if ((self = [super init]))
    {
        NSLog(@"QuoteGetter: Initialising...");
    }
    return self;
}

- (void)dealloc
{
    LOG(@"");
    
    [kNotificationCenter removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
}

#pragma mark -

- (void)getQuotesForChapter:(LGChapter *)chapter completionHandler:(void(^)(NSError *error, NSMutableArray *quotesArray))completionHandler
{
    LOG(@"");
    
    if ([self isCancelled:0]) return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                   {
                       _chapter = [LGChapter chapterWithChapter:(chapter ? chapter : kLGChapter)];
                       _completionHandler = completionHandler;
                       _loadedQuotes = [NSMutableArray new];
                       
                       NSString *htmlAddress;
                       
                       if (_chapter.type == LGChapterTypeNew)
                       {
                           if (!_currentPage) htmlAddress = @"http://bash.im";
                           else htmlAddress = [NSString stringWithFormat:@"http://bash.im/index/%lu", (unsigned long)_currentPage];
                       }
                       else if (_chapter.type == LGChapterTypeBest)
                           htmlAddress = @"http://bash.im/best";
                       else if (_chapter.type == LGChapterTypeRating)
                       {
                           if (!_currentPage) _currentPage = 1;
                           htmlAddress = [NSString stringWithFormat:@"http://bash.im/byrating/%lu", (unsigned long)_currentPage];
                       }
                       else if (_chapter.type == LGChapterTypeAbyss)
                       {
                           NSDate *end = [NSDate date];
                           if (_start != nil && [end compare:_start] == NSOrderedAscending) sleep(10);
                           _start = [NSDate dateWithTimeIntervalSinceNow:10];
                           
                           htmlAddress = @"http://bash.im/abyss";
                       }
                       else if (_chapter.type == LGChapterTypeAbyssTop)
                           htmlAddress = @"http://bash.im/abysstop";
                       else if (_chapter.type == LGChapterTypeAbyssBest)
                       {
                           if (!_currentDate) htmlAddress = @"http://bash.im/abyssbest";
                           else
                           {
                               NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                               [dateFormatter setDateFormat:@"yyyyMMdd"];
                               NSString *currentDateString = [dateFormatter stringFromDate:_currentDate];
                               
                               htmlAddress = [NSString stringWithFormat:@"http://bash.im/abyssbest/%@", currentDateString];
                           }
                       }
                       else if (_chapter.type == LGChapterTypeRandom)
                       {
                           NSDate *end = [NSDate date];
                           if (_start != nil && [end compare:_start] == NSOrderedAscending) sleep(10);
                           
                           _start = [NSDate dateWithTimeIntervalSinceNow:10];
                           
                           htmlAddress = @"http://bash.im/random";
                       }
                       else if (_chapter.type == LGChapterTypeSearch)
                       {
                           htmlAddress = [NSString stringWithFormat:@"http://bash.im/index?text=%@", kLGKit.searchText];
                       }
                       
                       if ([self isCancelled:1]) return;
                       
                       // Проверяем интернет соединение --------------------------------------------------------------
                       
                       if (!kInternetStatus)
                       {
                           NSLog(@"QuoteGetter: Загрузка прервана по причине отсутствия интернет соединения");
                           
                           if (completionHandler) completionHandler([NSError errorWithDomain:@"Отсутствует подключение к интернету\nНажмите для повтора" code:1000 userInfo:nil], nil);
                           
                           return;
                       }
                       
                       if ([self isCancelled:2]) return;
                       
                       // Пробуем загрузить HTML ---------------------------------------------------------------------
                       
                       NSLog(@"QuoteGetter: BEGIN loading, URL - %@ | _chapter - %@", htmlAddress, _chapter.name);
                       
                       NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:htmlAddress] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:20];
                       NSURLResponse *response;
                       NSError *error;
                       
                       NSData *data = [NSURLConnection sendSynchronousRequest:requestURL returningResponse:&response error:&error];
                       
                       if (error || !data)
                       {
                           NSLog(@"QuoteGetter: Во время загрузки страницы произошла ошибка - %@", (error ? error : @"Data is NULL"));
                           
                           if (completionHandler) completionHandler([NSError errorWithDomain:@"Во время загрузки произошла ошибка\nНажмите для повтора" code:1100 userInfo:nil], nil);
                           
                           return;
                       }
                       
                       if ([self isCancelled:3]) return;
                       
                       // Распарсиваем -------------------------------------------------------------------------------
                       
                       NSMutableArray *textsArray = [NSMutableArray new];
                       NSMutableArray *datesArray = [NSMutableArray new];
                       NSMutableArray *numbersArray = [NSMutableArray new];
                       NSMutableArray *ratingsArray = [NSMutableArray new];
                       
                       NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSWindowsCP1251StringEncoding];
                       HTMLDocument *document = [HTMLDocument documentWithString:htmlString];
                       
                       NSArray *inputNodesDiv = [document nodesMatchingSelector:@"div"];
                       
                       if (!_pagesAmount && (_chapter.type == LGChapterTypeNew || _chapter.type == LGChapterTypeRating))
                       {
                           // ищем колчество сраниц --------------------------------------------------------------------------
                           
                           for (HTMLElement *element in inputNodesDiv)
                               if ([element.attributes[@"class"] isEqualToString:@"pager"])
                               {
                                   NSArray *inputNodes2 = [element nodesMatchingSelector:@"form"];
                                   
                                   for (HTMLElement *element in inputNodes2)
                                       if ([element.attributes[@"method"] isEqualToString:@"post"])
                                       {
                                           NSArray *inputNodes3 = [element nodesMatchingSelector:@"span"];
                                           
                                           for (HTMLElement *element in inputNodes3)
                                               if ([element.attributes[@"class"] isEqualToString:@"current"])
                                               {
                                                   NSArray *inputNodes4 = [element nodesMatchingSelector:@"input"];
                                                   HTMLElement *resultElement = inputNodes4[0];
                                                   
                                                   _pagesAmount = [resultElement.attributes[@"max"] integerValue];
                                                   kLGKit.pagesAmount = _pagesAmount;
                                                   _currentPage = _pagesAmount;
                                                   if (!kLGKit.currentPage) kLGKit.currentPage = _pagesAmount;
                                                   
                                                   //NSLog(@"QuoteGetter: Pages amount = %lu", (unsigned long)_pagesAmount);
                                                   break;
                                               }
                                           
                                           if (_pagesAmount) break;
                                       }
                                   
                                   if (_pagesAmount) break;
                               }
                           
                           if (_chapter.type == LGChapterTypeNew)
                           {
                               // ищем статистику --------------------------------------------------------------------------------
                               
                               _statsArray = [NSMutableArray new];
                               
                               for (HTMLElement *element in inputNodesDiv)
                                   if ([element.attributes[@"id"] isEqualToString:@"stats"])
                                   {
                                       NSArray *inputNodes2 = [element nodesMatchingSelector:@"b"];
                                       
                                       for (HTMLElement *element in inputNodes2)
                                       {
                                           NSString *parsedString = element.textContent;
                                           [_statsArray addObject:parsedString];
                                           
                                           //NSLog(@"QuoteGetter: Stats = %@", parsedString);
                                       }
                                   }
                           }
                       }
                       
                       // тексты цитат -----------------------------------------------------------------------------------
                       
                       for (HTMLElement *element in inputNodesDiv)
                           if ([element.attributes[@"class"] isEqualToString:@"text"])
                           {
                               NSMutableString *parsedString = [NSMutableString stringWithString:element.innerHTML];
                               
                               while ([[parsedString substringWithRange:NSMakeRange(0, 1)] rangeOfString:@"\n"].location != NSNotFound) [parsedString deleteCharactersInRange:NSMakeRange(0, 1)];
                               while ([[parsedString substringWithRange:NSMakeRange(0, 4)] rangeOfString:@"<br>"].location != NSNotFound) [parsedString deleteCharactersInRange:NSMakeRange(0, 4)];
                               while ([[parsedString substringWithRange:NSMakeRange(parsedString.length-1, 1)] rangeOfString:@"\n"].location != NSNotFound) [parsedString deleteCharactersInRange:NSMakeRange(parsedString.length-1, 1)];
                               while ([[parsedString substringWithRange:NSMakeRange(parsedString.length-4, 4)] rangeOfString:@"<br>"].location != NSNotFound) [parsedString deleteCharactersInRange:NSMakeRange(parsedString.length-4, 4)];
                               
                               [parsedString replaceOccurrencesOfString:@"<br>" withString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, parsedString.length)];
                               [parsedString replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSCaseInsensitiveSearch range:NSMakeRange(0, parsedString.length)];
                               [parsedString replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(0, parsedString.length)];
                               [parsedString replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, parsedString.length)];
                               
                               [textsArray addObject:parsedString];
                               
                               //NSLog(@"QuoteGetter: Text = \n%@\n\n", parsedString);
                           }
                       
                       // номера, даты, рейтинги цитат -------------------------------------------------------------------
                       
                       for (HTMLElement *element in inputNodesDiv)
                           if ([element.attributes[@"class"] isEqualToString:@"quote"])
                           {
                               NSArray *inputNodes2 = [element nodesMatchingSelector:@"div"];
                               
                               for (HTMLElement *element in inputNodes2)
                                   if ([element.attributes[@"class"] isEqualToString:@"actions"])
                                   {
                                       NSArray *inputNodes3;
                                       NSString *elementAttribute;
                                       NSString *elementAttributeValue;
                                       
                                       // номера -------------------------------------------------------------------------
                                       
                                       if (_chapter.type == LGChapterTypeAbyssBest || _chapter.type == LGChapterTypeAbyss)
                                       {
                                           inputNodes3 = [element nodesMatchingSelector:@"span"];
                                           elementAttribute = @"class";
                                           elementAttributeValue = @"id";
                                       }
                                       else if (_chapter.type == LGChapterTypeAbyssTop)
                                       {
                                           inputNodes3 = [element nodesMatchingSelector:@"span"];
                                           elementAttribute = @"class";
                                           elementAttributeValue = @"abysstop";
                                       }
                                       else
                                       {
                                           inputNodes3 = [element nodesMatchingSelector:@"a"];
                                           elementAttribute = @"class";
                                           elementAttributeValue = @"id";
                                       }
                                       
                                       for (HTMLElement *element in inputNodes3)
                                           if ([element.attributes[elementAttribute] isEqualToString:elementAttributeValue])
                                           {
                                               NSString *parsedString;
                                               if (_chapter.type == LGChapterTypeAbyssBest)
                                                   parsedString = [element.textContent substringFromIndex:4];
                                               else
                                                   parsedString = [element.textContent substringFromIndex:1];
                                               
                                               if (!_quoteAmount) _quoteAmount = parsedString;
                                               //self._quoteNumber = parsedString;
                                               
                                               [numbersArray addObject:[NSNumber numberWithInt:parsedString.intValue]];
                                               
                                               //NSLog(@"QuoteGetter: Number = %@", parsedString);
                                           }
                                       
                                       // даты ----------------------------------------------------------------------------
                                       
                                       if (_chapter.type != LGChapterTypeAbyssTop)
                                       {
                                           inputNodes3 = [element nodesMatchingSelector:@"span"];
                                           elementAttribute = @"class";
                                           elementAttributeValue = @"date";
                                       }
                                       else
                                       {
                                           inputNodes3 = [element nodesMatchingSelector:@"span"];
                                           elementAttribute = @"class";
                                           elementAttributeValue = @"abysstop-date";
                                       }
                                       
                                       for (HTMLElement *element in inputNodes3)
                                           if ([element.attributes[elementAttribute] isEqualToString:elementAttributeValue])
                                           {
                                               NSString *parsedString = element.textContent;
                                               //_quoteDate = parsedString;
                                               
                                               [datesArray addObject:parsedString];
                                               
                                               //NSLog(@"QuoteGetter: Date = %@", parsedString);
                                               
                                               if (!_currentDate)
                                               {
                                                   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                   [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm"];
                                                   _currentDate = [dateFormatter dateFromString:parsedString];
                                               }
                                           }
                                       
                                       // рейтинги ------------------------------------------------------------------------
                                       
                                       inputNodes3 = [element nodesMatchingSelector:@"span"];
                                       
                                       for (HTMLElement *element in inputNodes3)
                                           if ([element.attributes[@"class"] isEqualToString:@"rating-o"])
                                           {
                                               NSArray *inputNodes4 = [element nodesMatchingSelector:@"span"];
                                               
                                               for (HTMLElement *element in inputNodes4)
                                                   if ([element.attributes[@"class"] isEqualToString:@"rating"])
                                                   {
                                                       NSString *parsedString = element.textContent;
                                                       
                                                       [ratingsArray addObject:[NSNumber numberWithInt:parsedString.intValue]];
                                                       
                                                       //NSLog(@"QuoteGetter: Rating = %@\n\n", parsedString);
                                                   }
                                           }
                                   }
                           }
                       
                       if ([self isCancelled:4]) return;
                       
                       // -----------------------------------------------------------------------------------------------
                       
                       if (!_isCashCleared &&
                           (_chapter.type == LGChapterTypeBest ||
                            _chapter.type == LGChapterTypeAbyss ||
                            _chapter.type == LGChapterTypeAbyssTop ||
                            _chapter.type == LGChapterTypeRandom ||
                            _chapter.type == LGChapterTypeSearch))
                       {
                           [kLGCoreData clearBashCashQuotesDataBaseForEntity:_chapter.entity];
                           
                           _isCashCleared = YES;
                       }
                       
                       if ([self isCancelled:5]) return;
                       
                       // проверка на существующие цитаты -----------------------------------------------------------------
                       
                       _context = [NSManagedObjectContext new];
                       [_context setPersistentStoreCoordinator:[[kLGCoreData getContextOfBashCashQuotesDataBase] persistentStoreCoordinator]];
                       NSEntityDescription *entityDescription = [NSEntityDescription entityForName:_chapter.entity inManagedObjectContext:_context];
                       NSFetchRequest *requestFetch = [NSFetchRequest new];
                       [requestFetch setEntity:entityDescription];
                       
                       for (NSUInteger i=0; i<textsArray.count; i++)
                       {
                           NSString *quoteText = textsArray[i];
                           NSNumber *quoteNumber = numbersArray[i];
                           
                           NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(text = %@) OR (number = %@)", quoteText, quoteNumber];
                           [requestFetch setPredicate:predicate];
                           
                           NSArray *matchesArray = [_context executeFetchRequest:requestFetch error:&error];
                           
                           if (matchesArray.count)
                               for (BashCashQuotesEntity *quote in matchesArray)
                                   [_context deleteObject:quote];
                       }
                       
                       if ([self isCancelled:6]) return;
                       
                       // добавляем цитаты в базу -------------------------------------------------------------------------
                       
                       for (int i=0; i<numbersArray.count; i++)
                       {
                           _quotesAmount++;
                           
                           // Проверка на одинаковые цитаты после загрузки новой страницы ---------------------------------
                           
                           NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(self = %i)", [numbersArray[i] intValue]];
                           NSArray *matchesArray = [_numbersArrayFull filteredArrayUsingPredicate:predicate];
                           
                           if (!matchesArray.count)
                           {
                               [_numbersArrayFull addObject:numbersArray[i]];
                               
                               NSMutableString *chapterString = [NSMutableString stringWithString:_chapter.entity];
                               [chapterString setString:[chapterString stringByReplacingOccurrencesOfString:@"Entity" withString:@""]];
                               
                               // для сохранения в базу
                               
                               BashCashQuotesEntity *quote = [[BashCashQuotesEntity alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:_context];
                               quote.chapter       = chapterString;
                               quote.date          = datesArray[i];
                               quote.number        = numbersArray[i];
                               quote.text          = textsArray[i];
                               if (ratingsArray.count)
                                   quote.rating    = ratingsArray[i];
                               quote.sequence      = [NSNumber numberWithInteger:_quotesAmount];
                               quote.source        = @"Bash";
                               
                               // для вывода на экран
                               
                               BashCashQuoteObject *quoteObject = [BashCashQuoteObject new];
                               quoteObject.date        = datesArray[i];
                               quoteObject.number      = [numbersArray[i] integerValue];
                               quoteObject.text        = textsArray[i];
                               if (ratingsArray.count)
                               {
                                   NSUInteger rating = [ratingsArray[i] integerValue];
                                   quoteObject.rating          = rating;
                                   quoteObject.ratingString    = (rating > 0 ? [NSString stringWithFormat:@"%lu", (unsigned long)rating] : @"???");
                               }
                               quoteObject.sequence    = _quotesAmount;
                               quoteObject.source      = @"Bash";
                               quoteObject.isFavourite = [kLGCoreData isQuoteInFavourites:quote];
                               
                               [_loadedQuotes addObject:quoteObject];
                           }
                       }
                       
                       if ([self isCancelled:7]) return;
                       
                       // сохраняем базу ----------------------------------------------------------------------------------
                       
                       [kNotificationCenter addObserver:self selector:@selector(backgroundContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:_context];
                       
                       [_context save:&error];
                   });
}

- (void)backgroundContextDidSave:(NSNotification *)notification
{
    LOG(@"");
    
    if ([notification.object isEqual:_context])
    {
        [kNotificationCenter removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^(void)
                       {
                           [[kLGCoreData getContextOfBashCashQuotesDataBase] mergeChangesFromContextDidSaveNotification:notification];
                           
                           if ([self isCancelled:8]) return;
                           
                           // ------------------------------------------------------------------------------------
                           
                           if (!_loadedQuotes.count && (_chapter.type == LGChapterTypeAbyss || _chapter.type == LGChapterTypeRandom))
                               [self getQuotesForChapter:_chapter completionHandler:_completionHandler];
                           else
                           {
                               if (_chapter.type == LGChapterTypeNew)
                                   _currentPage--;
                               else if (_chapter.type == LGChapterTypeRating)
                                   _currentPage++;
                               else if (_chapter.type == LGChapterTypeAbyssBest)
                                   _currentDate = [_currentDate dateByAddingTimeInterval:-60*60*24];
                           }
                           
                           NSLog(@"QuoteGetter: END loading, chapter - %@, quotes - %lu", _chapter.name, (unsigned long)_loadedQuotes.count);
                           
                           if ([self isCancelled:9]) return;
                           
                           if (!_isCancelled && _completionHandler) _completionHandler(nil, _loadedQuotes);
                       });
    }
}

#pragma mark -

- (void)cancell
{
    _isCancelled = YES;
    _completionHandler = nil;
}

- (BOOL)isCancelled:(int)point
{
    if (_isCancelled)
    {
        NSLog(@"QuoteGetter: Остановка потока %i", point);
        
        return YES;
    }
    else return NO;
}

@end















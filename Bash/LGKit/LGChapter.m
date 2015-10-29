//
//  LGChapter.m
//  Bash
//
//  Created by Friend_LGA on 24.01.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import "LGChapter.h"
#import "LGKit.h"

@interface LGChapter ()

@end

@implementation LGChapter

- (id)initWithType:(LGChapterType)type
{
    self = [super init];
    if (self)
    {
        self.type = type;
    }
    return self;
}

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        self.name = name;
    }
    return self;
}

- (id)initWithChapter:(LGChapter *)chapter
{
    self = [super init];
    if (self)
    {
        self.type = chapter.type;
    }
    return self;
}

#pragma mark -

+ (LGChapter *)chapterWithType:(LGChapterType)type
{
    LOG(@"");
    
    return [[self alloc] initWithType:type];
}

+ (LGChapter *)chapterWithName:(NSString *)name
{
    LOG(@"");
    
    return [[self alloc] initWithName:name];
}

+ (LGChapter *)chapterWithChapter:(LGChapter *)chapter
{
    LOG(@"");
    
    return [[self alloc] initWithChapter:chapter];
}

#pragma mark -

- (void)setType:(LGChapterType)type
{
    _type = type;
    
    _name = [self getNameAtIndex:_type];
    _entity = [self getEntityAtIndex:_type];
    _row = _type;
}

- (void)setName:(NSString *)name
{
    _name = name;
    
    if ([name isEqualToString:@"новые"])               _type = LGChapterTypeNew;
    else if ([name isEqualToString:@"лучшие"])         _type = LGChapterTypeBest;
    else if ([name isEqualToString:@"по рейтингу"])    _type = LGChapterTypeRating;
    else if ([name isEqualToString:@"Бездна"])         _type = LGChapterTypeAbyss;
    else if ([name isEqualToString:@"топ Бездны"])     _type = LGChapterTypeAbyssTop;
    else if ([name isEqualToString:@"лучшие Бездны"])  _type = LGChapterTypeAbyssBest;
    else if ([name isEqualToString:@"случайные"])      _type = LGChapterTypeRandom;
    else if ([name isEqualToString:@"поиск"])          _type = LGChapterTypeSearch;
    else if ([name isEqualToString:@"Избранные"])      _type = LGChapterTypeFavourites;
    
    _entity = [self getEntityAtIndex:_type];
    _row = _type;
}

#pragma mark -

- (NSString *)getNameAtIndex:(NSUInteger)index
{
    return [@[@"новые",
              @"лучшие",
              @"по рейтингу",
              @"Бездна",
              @"топ Бездны",
              @"лучшие Бездны",
              @"случайные",
              @"поиск",
              @"Избранные"] objectAtIndex:index];
}

- (NSString *)getEntityAtIndex:(NSUInteger)index
{
    return [@[@"NewEntity",
              @"BestEntity",
              @"RatingEntity",
              @"AbyssEntity",
              @"AbyssTopEntity",
              @"AbyssBestEntity",
              @"RandomEntity",
              @"SearchEntity",
              @"Entity"] objectAtIndex:index];
}

@end

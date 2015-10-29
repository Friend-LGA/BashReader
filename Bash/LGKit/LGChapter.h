//
//  LGChapter.h
//  Bash
//
//  Created by Friend_LGA on 24.01.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGChapter : NSObject

typedef enum
{
    LGChapterTypeNew = 0,
    LGChapterTypeBest = 1,
    LGChapterTypeRating = 2,
    LGChapterTypeAbyss = 3,
    LGChapterTypeAbyssTop = 4,
    LGChapterTypeAbyssBest = 5,
    LGChapterTypeRandom = 6,
    LGChapterTypeSearch = 7,
    LGChapterTypeFavourites = 8,
}
LGChapterType;

@property (nonatomic, assign) LGChapterType type;
@property (nonatomic, assign) int           row;
@property (nonatomic, strong) NSString      *name;
@property (nonatomic, strong) NSString      *entity;

- (id)initWithType:(LGChapterType)type;
- (id)initWithName:(NSString *)name;
- (id)initWithChapter:(LGChapter *)chapter;
+ (LGChapter *)chapterWithType:(LGChapterType)type;
+ (LGChapter *)chapterWithName:(NSString *)name;
+ (LGChapter *)chapterWithChapter:(LGChapter *)chapter;

@end

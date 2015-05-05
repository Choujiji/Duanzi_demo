//
//  DuanziContentLoader.m
//  Duanzi
//
//  Created by mac on 15/4/29.
//  Copyright (c) 2015年 jiji. All rights reserved.
//

#import "DuanziContentLoader.h"
#import "Duanzi.h"
#import "MyDuanzi.h"

static DuanziContentLoader *instance = nil;

@interface DuanziContentLoader ()

@property (nonatomic, strong) FMDatabaseQueue *queue;

/**
 *  解析并获取所有段子
 *
 *  @return 段子字符串数组
 */
+ (NSArray *)getDuanziContent;

@end

@implementation DuanziContentLoader

#pragma mark - 初始化方法

+ (DuanziContentLoader *)duanziLoader
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DuanziContentLoader alloc] init];
    });
    
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
        NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = pathArray[0];
        NSString *dbPath = [documentPath stringByAppendingPathComponent:@"content.db"];
        
        _queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return self;
}

- (void)createDatabaseAndSaveDefaultData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.queue inDatabase:^(FMDatabase *db) {
            //打开数据库
            if (![db open])
            {
                NSLog(@"create db error!!");
                
                return;
            }
            
            
            //创建表
            if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS Duanzi (ID integer PRIMARY KEY, Content text, Like boolean, Dislike boolean, Favourite boolean)"])
            {
                NSLog(@"create table Duanzi error: %@", [db lastError]);
                
                [db close];
                return;
            }
            
            
            //插入所有数据
            NSArray *allContentArray = [DuanziContentLoader getDuanziContent];
            
            for (NSDictionary *duanziDic in allContentArray)
            {
                
                [db executeUpdate:@"INSERT INTO Duanzi VALUES (?, ?, ?, ?, ?)",[duanziDic allKeys][0], [duanziDic allValues][0], @NO, @NO, @NO];
            }
            
            //创建个人段子表
            if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS MyDuanzi (ID integer PRIMARY KEY AUTOINCREMENT, Content text, TimeStamp REAL)"])
            {
                NSLog(@"create table MyDuanzi error: %@", [db lastError]);
                
                [db close];
                return;
            }
            
            [db close];
        }];
    });
}

+ (NSArray *)getDuanziContent
{
    NSString *contentPath = [[NSBundle mainBundle] pathForResource:@"DuanziContent" ofType:@"json"];
    NSData *contentData = [NSData dataWithContentsOfFile:contentPath];
    
    NSError *error = nil;
    
    NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:contentData options:0 error:&error];
    
    NSMutableArray *resultDataArray = [NSMutableArray new];
    [dataArray enumerateObjectsUsingBlock:^(NSString *content, NSUInteger idx, BOOL *stop){
        
        NSDictionary *dic = @{@(idx): content};
        [resultDataArray addObject:dic];
    }];
    
    return resultDataArray;
}


#pragma mark - 系统默认段子功能

- (void)loadNewDefaultData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.queue inDatabase:^(FMDatabase *db) {
            
            [DuanziContentLoader getDuanziContent];
            
            //打开数据库
            if (![db open])
            {
                NSLog(@"create db error!!");
                
                return;
            }
            
            NSArray *allContentArray = [DuanziContentLoader getDuanziContent];
            
            NSUInteger count = [db intForQuery:@"SELECT COUNT(*) FROM Duanzi"];
            
            //有新数据
            if (count < allContentArray.count)
            {
                //插入所有数据
                
                for (NSDictionary *duanziDic in allContentArray)
                {
                    
                    [db executeUpdate:@"INSERT INTO Duanzi VALUES (?, ?, ?, ?, ?)",[duanziDic allKeys][0], [duanziDic allValues][0], @NO, @NO, @NO];
                }
            }
            
            [db close];
        }];
        
    });
}

- (void)queryDuanziWithKeyString:(NSString *)keyString completion:(void(^)(NSArray *resultArray))completion
{
    NSMutableArray *dataArray = [NSMutableArray new];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.queue inDatabase:^(FMDatabase *db) {
            
            //打开数据库
            if (![db open])
            {
                NSLog(@"create db error!!");
                
                return;
            }
            
            
            
            FMResultSet *resultSet = nil;
            if (keyString.length == 0)
            {
                resultSet = [db executeQuery:@"SELECT * FROM Duanzi"];
            }
            else
            {
                NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Duanzi WHERE Content LIKE '%%%@%%'", keyString];

                resultSet = [db executeQuery:sql];
            }
            
            
            while (resultSet.next)
            {
                Duanzi *duanzi = [Duanzi new];
                
                duanzi.ID = [resultSet intForColumn:@"ID"];
                duanzi.content = [resultSet stringForColumn:@"Content"];
                duanzi.like = [resultSet boolForColumn:@"Like"];
                duanzi.dislike = [resultSet boolForColumn:@"Dislike"];
                duanzi.favourite = [resultSet boolForColumn:@"Favourite"];
                
                [dataArray addObject:duanzi];
            }
            
            [db close];
            
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(dataArray);
        });
    });
}

- (void)queryMyFavouriteDuanziCompletion:(void(^)(NSArray *resultArray))completion
{
    NSMutableArray *resultArray = [NSMutableArray new];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.queue inDatabase:^(FMDatabase *db) {
            
            if (![db open])
            {
                NSLog(@"create db error!!");
                return;
            }
            
            
            FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM Duanzi WHERE Favourite = ?", @YES];
            
            while (resultSet.next)
            {
                Duanzi *duanzi = [Duanzi new];
                duanzi.content = [resultSet stringForColumn:@"Content"];
                duanzi.ID = [resultSet intForColumn:@"ID"];
                duanzi.like = [resultSet boolForColumn:@"Like"];
                duanzi.dislike = [resultSet boolForColumn:@"Dislike"];
                duanzi.favourite = [resultSet boolForColumn:@"Favourite"];
                
                [resultArray insertObject:duanzi atIndex:0];
            }
            
            
            [db close];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(resultArray);
        });
    });
}


- (void)updateDuanziInfoWithDuanzi:(Duanzi *)duanzi
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.queue inDatabase:^(FMDatabase *db) {
            //打开数据库
            if (![db open])
            {
                NSLog(@"create db error!!");
                
                return;
            }
            
            if (![db executeUpdate:@"UPDATE Duanzi SET Favourite = ?, Like = ?, Dislike = ? WHERE Content = ?", @(duanzi.favourite), @(duanzi.like), @(duanzi.dislike), duanzi.content])
            {
                NSLog(@"insert error: %@", db.lastError);
            }
            
            [db close];
        }];
    });
}

#pragma mark - 个人创建段子功能

- (void)saveNewMyDuanzi:(MyDuanzi *)myDuanzi
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.queue inDatabase:^(FMDatabase *db) {
            //打开数据库
            if (![db open])
            {
                NSLog(@"create db error!!");
                
                return;
            }
            
            if (![db executeUpdate:@"INSERT INTO MyDuanzi VALUES (NULL, ?, ?)", myDuanzi.content, [NSDate date]])
            {
                NSLog(@"insert error: %@", db.lastError);
            }
            
            [db close];
        }];
    });
}


- (void)deleteMyDuanzi:(MyDuanzi *)myDuanzi
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.queue inDatabase:^(FMDatabase *db) {
            //打开数据库
            if (![db open])
            {
                NSLog(@"create db error!!");
                
                return;
            }
            
            if (![db executeUpdate:@"DELETE FROM MyDuanzi WHERE Content = ?", myDuanzi.content])
            {
                NSLog(@"delete error: %@", [db lastError]);
            }
            
            [db close];
        }];
    });
}


- (void)getAllMyDuanziWithCompletion:(void(^)(NSArray *resultArray))completion;
{
    NSMutableArray *resultArray = [NSMutableArray new];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.queue inDatabase:^(FMDatabase *db) {
            //打开数据库
            if (![db open])
            {
                NSLog(@"create db error!!");
                
                return;
            }
            
            FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM MyDuanzi"];
            
            while (resultSet.next)
            {
                MyDuanzi *myDuanzi = [MyDuanzi new];
                myDuanzi.ID = [resultSet intForColumn:@"ID"];
                myDuanzi.content = [resultSet stringForColumn:@"Content"];
                myDuanzi.createDate = [resultSet dateForColumn:@"TimeStamp"];
                
                [resultArray insertObject:myDuanzi atIndex:0];
            }
            
            [db close];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(resultArray);
        });
    });
}

@end

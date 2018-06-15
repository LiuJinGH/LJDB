//
//  LJDBServer.m
//  LJDB
//
//  Created by 刘瑾 on 2018/5/24.
//  Copyright © 2018年 LuckyLiu. All rights reserved.
//

#import "LJDBServer.h"

#define LJDBName @"LJDB.sqlite"

@implementation LJDBServer

+(instancetype)defaultDBServer{

    static LJDBServer *defaultServer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultServer = [[LJDBServer alloc] initDBServer];
    });
    return defaultServer;

}

-(instancetype)initDBServer{
    NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:LJDBName];
    NSLog(@"DB Path: %@", dbPath);
    return [self initDBServerWithPath:dbPath];
}

-(instancetype)initDBServerWithPath:(NSString *)dbPath{
    if (self = [super init]) {
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return self;
}

-(BOOL)executeUpdateInDatabase:(NSString *)SQLStatement{
    __block BOOL result = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:SQLStatement];
    }];
    return result;
}

-(BOOL)executeUpdateInDatabase:(NSString *)SQLStatement withArgumentsInArray:(nonnull NSArray *)array{
    __block BOOL result = NO;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:SQLStatement withArgumentsInArray:array];
    }];
    return result;
}

-(BOOL)executeUpdateInTransaction:(NSString *)SQLStatement{
    __block BOOL result = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        result = [db executeUpdate:SQLStatement];
    }];
    return result;
}

-(BOOL)executeUpdateInTransaction:(NSString *)SQLStatement withArgumentsInArray:(nonnull NSArray *)array{
    __block BOOL result = NO;
    [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        result = [db executeUpdate:SQLStatement withArgumentsInArray:array];
    }];
    return result;
}

-(FMResultSet *)selectTableInDataBase:(NSString *)SQLStatement{
    __block FMResultSet *resultSet;
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        resultSet = [db executeQuery:SQLStatement];
        while ([resultSet next]) {
            
        }
    }];
    return resultSet;
}

#pragma mark —————— DB Log ——————

static bool _showingLog = YES;

+(BOOL)showingLog{
    return _showingLog;
}

+(void)setShowingLog:(BOOL)showingLog{
    _showingLog = showingLog;
}

@end

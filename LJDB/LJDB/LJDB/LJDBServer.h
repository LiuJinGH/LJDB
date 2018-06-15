//
//  LJDBServer.h
//  LJDB
//
//  Created by 刘瑾 on 2018/5/24.
//  Copyright © 2018年 LuckyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface LJDBServer : NSObject

@property (nonatomic, strong, readonly) FMDatabaseQueue *dbQueue;

+(instancetype)defaultDBServer;

-(instancetype)initDBServer;
-(instancetype)initDBServerWithPath:(NSString *)dbPath;

-(BOOL)executeUpdateInDatabase:(NSString *)SQLStatement;
-(BOOL)executeUpdateInDatabase:(NSString *)SQLStatement withArgumentsInArray:(nonnull NSArray *)array;
-(BOOL)executeUpdateInTransaction:(NSString *)SQLStatement;
-(BOOL)executeUpdateInTransaction:(NSString *)SQLStatement withArgumentsInArray:(nonnull NSArray *)array;

-(BOOL)createTableInDatabase:(NSString *)SQLStatement;
-(BOOL)createTableInTransaction:(NSString *)SQLStatement;

-(FMResultSet *)selectTableInDataBase:(NSString *)SQLStatement;

#pragma mark —————— LJDBModel Log ——————

/**
 是否显示数据库操作日记
 */
@property(nonatomic, class) BOOL showingLog;

/**
 是否将数据库操作日记写到文档中
 */
@property(nonatomic, class) BOOL recordLog;

@end

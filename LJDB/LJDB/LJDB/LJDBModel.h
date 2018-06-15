//
//  LJDBModel.h
//  LJDB
//
//  Created by 刘瑾 on 2018/5/23.
//  Copyright © 2018年 LuckyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYKit/YYClassInfo.h>
#import "LJDBServer.h"

@class LJDBPropertyInfo, LJDBSelectCondition;

@interface LJDBModel : NSObject



#pragma mark —————— LJDBModel ——————

/**
 数据模型的属性集
 */
+(NSArray<YYClassPropertyInfo *> *)properties;
+(NSArray<LJDBPropertyInfo *> *)dbProperties;

/**
 数据模型的主键值
 */
-(long)primaryKeyValue;

/**
 初始化设置主键名

 @return 主键名
 */
+(nonnull NSString *)setupPrimaryKey;

#pragma mark - ——————  增 删 查 改 ——————

-(BOOL)insertInDatabase;

/**
 插入数据

 @param db 数据库实例
 @return 插入是否成功
 */
-(BOOL)insertInDB:(FMDatabase * _Nonnull)db;

/**
 将当前数据模型从数据库中删除
 
 @param db 数据库实例
 @return 操作是否成功
 */
-(BOOL)deleteModel:(FMDatabase * _Nonnull)db;

/**
 更新数据模型
 
 如果数据当中没有这个数据模型，就插入
 
 @param db 数据库实例
 @return 操作是否成功
 */
-(BOOL)updateModel:(FMDatabase * _Nonnull)db;

/**
 从数据库中获取指定ID的数据信息
 
 @param primaryKey 主键 ID
 @param db 数据库实例
 @return 数据模型实例
 */
+(_Nullable instancetype)selectByPrimaryKey:(long)primaryKey inDB:( FMDatabase * _Nonnull )db;

+(NSArray * _Nonnull)selectModelWhere:(NSString * _Nonnull)selectCondition inDB:(FMDatabase * _Nonnull)db;

/**
 清空该模型所有数据

 @param db 数据库实例
 @return 是否删除成功
 */
+(BOOL)clearModel:(FMDatabase * _Nonnull)db;

/**
 从数据库中获取该模型所有的数据信息

 @param db 数据库实例
 @return 数据模型列表
 */
+(NSArray *_Nonnull)findAllInDB:(FMDatabase * _Nonnull)db;


/**
 从数据库中获取该模型所有的数据信息 并某个属性字段排序

 @param db 数据库实例
 @param orderKey 数据字段
 @param isASC 是否是升序
 @return 数据模型列表
 */
+(NSArray *_Nonnull)findAllInDB:(FMDatabase * _Nonnull)db OrderByKey:(NSString * _Nonnull)orderKey isASC:(BOOL)isASC;

@end

typedef NS_ENUM(NSUInteger, LJDBSQLiteType) {
    LJDBSQLiteTypeBLOB,
    LJDBSQLiteTypeText,
    LJDBSQLiteTypeInteger,
    LJDBSQLiteTypeReal
};

typedef NS_ENUM(NSUInteger, LJDBSelectConditionType) {
    // 0x 0000 0000 0000 0000
    LJDBSelectConditionUnequal = 0, // 不等于
    LJDBSelectConditionEqual = 1, // 等于  0000 0000 0000 0001
    LJDBSelectConditionLess = 1 << 1, // 小于  0000 0000 0000 0010 2
    LJDBSelectConditionGreater = 1 << 2, // 大于 0000 0000 0000 0100 4
};

@interface LJDBSelectCondition:NSObject

@property(nonatomic, strong) NSString * name;

@property(nonatomic, assign) LJDBSelectConditionType selectCondition;

@end

@interface LJDBPropertyInfo:NSObject

-(instancetype)initPropertyInfo:(YYClassPropertyInfo *) propertyInfo isPrimaryKey:(BOOL)isPrimaryKey;

/**
 SQL 列名
 */
@property(nonatomic, strong, readonly) NSString * name;

/**
 SQL 类型
 */
@property(nonatomic, assign, readonly) LJDBSQLiteType type;

/**
 是否是主键
 */
@property(nonatomic, assign, readonly) BOOL isPrimaryKey;

/**
 能否为空
 */
@property(nonatomic, assign, readonly) BOOL canBeNull;

/**
 属性的类
 */
@property (nonatomic, strong, readonly) Class cls;

@end



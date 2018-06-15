//
//  LJDBModel.m
//  LJDB
//
//  Created by 刘瑾 on 2018/5/23.
//  Copyright © 2018年 LuckyLiu. All rights reserved.
//

#import "LJDBModel.h"
#import <objc/runtime.h>

#define LJDB_PRIMARY_KEY @"LJDB_PRIMARY_KEY"

#define TABLE_NAME (NSStringFromClass([self class]))

#define CREATE_TABLE_SQL @"CREATE TABLE IF NOT EXISTS %@(%@);"

#define DELETE_TABLE_SQL @"DELETE FROM %@;"

#define DELETE_MODEL_SQL @"DELETE FROM %@ WHERE %@ = %lu;"

// insert into StuList(sid, user_id, realname, avatar_url, isyjmember) values(?,?,?,?,?)
#define INSERT_TABLE_SQL @"INSERT INTO %@(%@) VALUES(%@)"

#define UPDATE_MODEL_SQL @"UPDATE %@ SET %@ WHERE %@ = %lu;"

// 文本字符
#define SQL_TYPE_TEXT     @"TEXT"
// 整型数值
#define SQL_TYPE_INTEGER  @"INTEGER"
// 浮点数值
#define SQL_TYPE_REAL     @"REAL"
// 泛类型
#define SQL_TYPE_BLOB     @"BLOB"
// 空值
#define SQL_TYPE_NULL     @"NULL"

@implementation LJDBModel

// 初始化时创建表
+ (void)initialize
{
    if (self != [LJDBModel self]) {
        [[LJDBServer defaultDBServer] executeUpdateInDatabase:[self createTable_SQLStatement]];
    }
}

-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

+(NSString *)createTable_SQLStatement{
    NSString *tableName = NSStringFromClass([self class]);
    NSMutableString *tableColumn = [NSMutableString new];
    for (LJDBPropertyInfo *property in [self dbProperties]) {
        [tableColumn appendFormat:@"%@,", property];
    }
    [tableColumn deleteCharactersInRange:NSMakeRange(tableColumn.length - 1, 1)];
    NSString *str = [NSString stringWithFormat:CREATE_TABLE_SQL, tableName, tableColumn];
    NSLog(@"%@", str);
    return str;
}

+(NSString *)primaryKey{
    return [self  setupPrimaryKey];
}

-(long)primaryKeyValue{
    NSString *primaryKey = [[self class] primaryKey];
    NSNumber *key = [self valueForKey:primaryKey];
    return key.longValue;
}

+(nonnull NSString *)setupPrimaryKey{
    return LJDB_PRIMARY_KEY;
}

+(NSArray<YYClassPropertyInfo *> *)properties{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableArray *temp = [NSMutableArray new];
    for (int i=0; i<count; i++) {
        objc_property_t property = properties[i];
        YYClassPropertyInfo *YYPropertyInfo = [[YYClassPropertyInfo alloc] initWithProperty:property];
        [temp addObject:YYPropertyInfo];
    }
    return temp;
}

+(NSArray<LJDBPropertyInfo *> *)dbProperties{
    NSMutableArray *temp2 = [NSMutableArray new];
    for (YYClassPropertyInfo *YYPropertyInfo in [self properties]) {
        LJDBPropertyInfo *DBPropertyInfo = [[LJDBPropertyInfo alloc] initPropertyInfo:YYPropertyInfo isPrimaryKey:[YYPropertyInfo.name isEqualToString:[self setupPrimaryKey]]];
        [temp2 addObject:DBPropertyInfo];
    }
    return temp2;
}

#pragma mark - ——————  增 删 查 改 ——————

+(NSString *)propertySQLStr{
    NSMutableString *tableColumn = [NSMutableString new];
    for (LJDBPropertyInfo *property in [self dbProperties]) {
        [tableColumn appendFormat:@"%@,", property.name];
    }
    [tableColumn deleteCharactersInRange:NSMakeRange(tableColumn.length - 1, 1)];
    return tableColumn;
}

+(NSString *)propertyValueSQLStr{
    NSMutableString *tableValueColumn = [NSMutableString new];
    for (int i = 0; i < [self dbProperties].count; i++) {
        [tableValueColumn appendFormat:@"?,"];
    }
    [tableValueColumn deleteCharactersInRange:NSMakeRange(tableValueColumn.length - 1, 1)];
    return tableValueColumn;
}

-(NSArray *)propertyValueList{
    NSMutableArray *propertyValueList = [NSMutableArray new];
    for (LJDBPropertyInfo *property in [[self class] dbProperties]) {
        id value = [self valueForKey:property.name];
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *array = value;
            if (array.count > 0) {
                NSMutableString *temp = [NSMutableString new];
                for (int i = 0; i < array.count; i++) {
                    if ([array[i] isKindOfClass:[LJDBModel class]]) {
                        if (i == 0) {
                            [temp appendFormat:@"%@:", NSStringFromClass([array[i] class])];
                        }
                        LJDBModel *dbModel = array[i];
                        [temp appendFormat:@"%ld ", [dbModel primaryKeyValue]];
                    }
                }
                value = temp;
            }
        }else if([value isKindOfClass:[NSDictionary class]]){
            
        }else if ([value isKindOfClass:[LJDBModel class]]){
            LJDBModel *dbModel = value;
            value = [NSString stringWithFormat:@"%@:%ld", NSStringFromClass([value class]), [dbModel primaryKeyValue]];
        }
        if ([value isKindOfClass:[NSString class]]) {
            value = [NSString stringWithFormat:@"'%@'", value];
        }
        if (value) {
            [propertyValueList addObject:value];
        }else{
            [propertyValueList addObject:[NSObject new]];
        }
        ;
    }
    return propertyValueList;
}

-(NSString *)insertSQLStatement{
    
    NSString *propertySQLStr = [[self class] propertySQLStr];
    NSString *propertyValueSQLStr = [[self class] propertyValueSQLStr];
    NSString *insertSQLStatement = [NSString stringWithFormat:INSERT_TABLE_SQL, TABLE_NAME, propertySQLStr, propertyValueSQLStr];
    
    return insertSQLStatement;
}

-(BOOL)insertInDatabase{
    return [[LJDBServer defaultDBServer] executeUpdateInDatabase:[self insertSQLStatement] withArgumentsInArray:[self propertyValueList]];
}

-(BOOL)insertInDB:(FMDatabase *)db{
    // 先判断数据里面是否已经存储过该数据
    LJDBModel *model = [self.class selectByPrimaryKey:self.primaryKeyValue inDB:db];
    if (model) {
        // 已经存储过该数据
        return NO;
    }else{
        // 还没存储过该数据
        return [db executeUpdate:[self insertSQLStatement] withArgumentsInArray:[self propertyValueList]];
    }
}

-(BOOL)updateModel:(FMDatabase *)db{
    // 当这个数据模型还未存储在数据库当中
    if (![self.class selectByPrimaryKey:self.primaryKeyValue inDB:db]) return [self insertInDB:db];
    
    NSMutableString *tableColumn = [NSMutableString new];
    for (int i=0; i<[self.class dbProperties].count; i++) {
        NSString *name = [self.class dbProperties][i].name;
        Class class = [self.class dbProperties][i].class;
        if ([name isEqualToString:[self.class primaryKey]]) continue;
        // 当子属性是LJDBModel的情况
        if ([class isSubclassOfClass:[LJDBModel class]]) {
            LJDBModel *value = [self valueForKey:name];
            [value updateModel:db];
        }
        // 当子属性是LJDBModel数组的情况
        if ([class isSubclassOfClass:[NSArray class]]) {
            // LJDBModel 数据属性里面的元素 一定也是LJDBModel
            NSArray *subModels = [self valueForKey:name];
            for (LJDBModel *subModel in subModels) {
                [subModel updateModel:db];
            }
        }
        NSString *value = [self propertyValueList][i];
        [tableColumn appendFormat:@"%@=%@,", name, value];
    }
    [tableColumn deleteCharactersInRange:NSMakeRange(tableColumn.length - 1, 1)];
    NSString *SQLStatement = [NSString stringWithFormat:UPDATE_MODEL_SQL, TABLE_NAME, tableColumn, [self.class primaryKey], self.primaryKeyValue];
    return [db executeUpdate:SQLStatement];
}

+(BOOL)clearModel:(FMDatabase *)db{
    NSString *SQLStatement = [NSString stringWithFormat:DELETE_TABLE_SQL, TABLE_NAME];
    return [db executeUpdate:SQLStatement];
}

-(BOOL)deleteModel:(FMDatabase *)db{
    NSString *SQLStatement = [NSString stringWithFormat:DELETE_MODEL_SQL, TABLE_NAME, [self.class primaryKey], self.primaryKeyValue];
    return [db executeUpdate:SQLStatement];
}

+(NSArray *)findAllInDB:(FMDatabase *)db{
    NSMutableArray *list = [NSMutableArray new];
    FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", TABLE_NAME]];
    while ([resultSet next]) {
        [list addObject:[self setUpDBModel:[self.class new] resultSet:resultSet]];
    }
    return list;
}

+(NSArray *)findAllInDB:(FMDatabase *)db OrderByKey:(NSString *)orderKey isASC:(BOOL)isASC{
    NSMutableArray *list = [NSMutableArray new];
    FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ %@", TABLE_NAME, orderKey, (isASC ? @"ASC":@"DESC")]];
    while ([resultSet next]) {
        [list addObject:[self setUpDBModel:[self.class new] resultSet:resultSet]];
    }
    return list;
}

+(instancetype)selectByPrimaryKey:(long)primaryKey inDB:(FMDatabase *)db{
    
    FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%ld", TABLE_NAME, [self setupPrimaryKey],primaryKey]];
    LJDBModel *model = nil;
    while ([resultSet next]) {
        model = [self setUpDBModel:[self.class new] resultSet:resultSet];
    }
    return model;
}

+(instancetype)selectByPrimaryKey:(long)primaryKey{
    
    FMResultSet *resultSet = [[LJDBServer defaultDBServer] selectTableInDataBase:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=%ld", TABLE_NAME, [self setupPrimaryKey],primaryKey]];
    LJDBModel *model = nil;
    while ([resultSet next]) {
        model = [self setUpDBModel:[self.class new] resultSet:resultSet];
        
    }
    return model;
}

+(NSArray *)selectModelWhere:(NSString *)selectCondition inDB:(FMDatabase *)db{
    FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", TABLE_NAME, selectCondition]];
    NSMutableArray *list = [NSMutableArray new];
    while ([resultSet next]) {
        LJDBModel *model = [self setUpDBModel:[self.class new] resultSet:resultSet];
        [list addObject:model];
    }
    return list;
}

+(LJDBModel *)setUpDBModel:(LJDBModel *)model resultSet:(FMResultSet *)resultSet{

    for (LJDBPropertyInfo *dbProperty in [self dbProperties]) {
        NSString *propertyKey = dbProperty.name;
        switch (dbProperty.type) {
            case LJDBSQLiteTypeInteger:
                [model setValue:[NSNumber numberWithLong:[resultSet longForColumn:propertyKey]] forKey:propertyKey];
                break;
            case LJDBSQLiteTypeReal:{
                [model setValue:[NSNumber numberWithDouble:[resultSet doubleForColumn:propertyKey]] forKey:propertyKey];
            }
                break;
            case LJDBSQLiteTypeText:{
                [model setValue:[resultSet stringForColumn:propertyKey] forKey:propertyKey];
            }
                break;
            case LJDBSQLiteTypeBLOB:{
                NSString *temp = [resultSet stringForColumn:propertyKey];
                NSArray *list = [self parseArrayPropertyModel:temp];
                if (list.count > 0) {
                    if ([dbProperty.cls isSubclassOfClass:[NSArray class]]) {
                        [model setValue:list forKey:propertyKey];
                    }else if ([dbProperty.cls isSubclassOfClass:[LJDBModel class]]){
                        [model setValue:list.firstObject forKey:propertyKey];
                    }
                }
            }
                break;
            default:
                break;
        }
    }
    return model;
}

+(NSArray *)parseArrayPropertyModel:(NSString *)propertyStr {
    NSMutableArray *list = [NSMutableArray new];
    NSArray *array = [propertyStr componentsSeparatedByString:@":"];
    if (array.count == 2) {
        Class cls = NSClassFromString(array[0]);
        if ([cls isSubclassOfClass:[LJDBModel class]]) {
            NSArray *array2 = [array[1] componentsSeparatedByString:@" "];
            for (NSString *primaryKey in array2) {
                if (primaryKey.length > 0) {
                    long pk = primaryKey.longLongValue;
                    LJDBModel *properytModel = [cls selectByPrimaryKey:pk];
                    [list addObject:properytModel];
                    NSLog(@"temp: %@", properytModel);
                }
            }
        }
    }
    return list;
}

@end

@implementation LJDBSelectCondition


@end

@implementation LJDBPropertyInfo

-(NSString *)description{
    NSMutableString *d = [NSMutableString stringWithFormat:@"%@ ", _name];
    switch (_type) {
        case LJDBSQLiteTypeText:
            [d appendString:SQL_TYPE_TEXT];
            break;
        case LJDBSQLiteTypeInteger:
            [d appendString:SQL_TYPE_INTEGER];
            break;
        case LJDBSQLiteTypeReal:
            [d appendString:SQL_TYPE_REAL];
            break;
        case LJDBSQLiteTypeBLOB:
            [d appendFormat:SQL_TYPE_BLOB];
            break;
    }
    if (self.isPrimaryKey) {
        [d appendString:@" PRIMARY KEY"];
    }
    if (!self.canBeNull) {
        [d appendString:@" NOT NULL"];
    }
    return d;
}

-(instancetype)initPropertyInfo:(YYClassPropertyInfo *)propertyInfo isPrimaryKey:(BOOL)isPrimaryKey{
    if (self = [super init]) {
        // 存在 实例变量 可作为数据存储
        if (propertyInfo.ivarName) {
            _name = propertyInfo.name;
            _isPrimaryKey = isPrimaryKey;
            _canBeNull = YES;
            _cls = propertyInfo.cls;
//            YYEncodingType pType = propertyInfo.type & YYEncodingTypePropertyWeak;
            
            YYEncodingType type =  propertyInfo.type & YYEncodingTypeMask;
            
            switch (type) {
                case YYEncodingTypeBool:
                case YYEncodingTypeInt8:
                case YYEncodingTypeUInt8:
                case YYEncodingTypeInt16:
                case YYEncodingTypeUInt16:
                case YYEncodingTypeInt32:
                case YYEncodingTypeUInt32:
                case YYEncodingTypeInt64:
                case YYEncodingTypeUInt64:
                    _type = LJDBSQLiteTypeInteger;
                    break;
                    
                case YYEncodingTypeFloat:
                case YYEncodingTypeDouble:
                case YYEncodingTypeLongDouble:
                    _type = LJDBSQLiteTypeReal;
                    break;
                    
                case YYEncodingTypeObject:
                    if (propertyInfo.cls) {
                        if ([propertyInfo.cls isSubclassOfClass:[NSString class]]) {
                            _type = LJDBSQLiteTypeText;
                        }
                    }
                    break;
                    
                default:
                    break;
            }
            
        }
        
        
    }
    return self;
}

@end

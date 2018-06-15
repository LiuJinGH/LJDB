# LJDB

## 项目介绍
基于FMDB和YYModel的一个便捷的数据库模型框架。

1. 根据模型自动建表
2. 基于自然语法执行SQL语句

## 软件架构
软件架构说明


## 安装教程

1. xxxx
2. xxxx
3. xxxx

## 使用说明

先创建数据库服务，基于数据库服务再去进行数据模型的操作。

可以对数据模型自动创建数据库表。这个数据模型必须是LJDBModel的子类。

### LJDBServer 数据库操作

#### defaultDBServer

默认提供了一个数据库服务，创建的数据库名为：LJDB.sqlite，文件路径为：/Documents/LJDB.sqlite。

### LJDBModel 数据模型操作

对数据模型有以下几点规范要求：
1. 数据模型中，数组属性里面的元素只能是LJDBModel以及其子类的实例。

#### 插入数据

将当前数据模型实例插入数据库db实例中。

如果发现数据库db中已经存在该数据，将自动转为更新数据操作。

```
-(BOOL)insertInDB:(FMDatabase * _Nonnull)db;
```
实例：
```
[s1 insertInDB:db];
```

#### 删除数据

```
-(BOOL)deleteModel:(FMDatabase * _Nonnull)db;
```
示例
```
[s1 deleteModel:db];
```

#### 更新数据

将当前数据模型实例更新入数据库db实例中

如果发现数据库db中还没存储该数据，将自动转为插入数据操作。

```
-(BOOL)updateModel:(FMDatabase * _Nonnull)db;
```
示例
```
[s1 updateModel:db];
```

#### 查询数据

查询数据的操作都是类方法。

1. 通过主键进行查询
2. 通过自己写的Where条件进行查询
3. 获取该数据模型所有数据
4. 获取该数据模型所有数据，并按照某个属性字段排序
```
+(_Nullable instancetype)selectByPrimaryKey:(long)primaryKey inDB:( FMDatabase * _Nonnull )db;
+(NSArray * _Nonnull)selectModelWhere:(NSString * _Nonnull)selectCondition inDB:(FMDatabase * _Nonnull)db;
+(NSArray *_Nonnull)findAllInDB:(FMDatabase * _Nonnull)db;
+(NSArray *_Nonnull)findAllInDB:(FMDatabase * _Nonnull)db OrderByKey:(NSString * _Nonnull)orderKey isASC:(BOOL)isASC;
```
示例
```
[LJStudentModel selectByPrimaryKey:200001 inDB:db];
```

## 参与贡献

1. Fork 本项目
2. 新建 Feat_xxx 分支
3. 提交代码
4. 新建 Pull Request


## 码云特技

1. 使用 Readme\_XXX.md 来支持不同的语言，例如 Readme\_en.md, Readme\_zh.md
2. 码云官方博客 [blog.gitee.com](https://blog.gitee.com)
3. 你可以 [https://gitee.com/explore](https://gitee.com/explore) 这个地址来了解码云上的优秀开源项目
4. [GVP](https://gitee.com/gvp) 全称是码云最有价值开源项目，是码云综合评定出的优秀开源项目
5. 码云官方提供的使用手册 [http://git.mydoc.io/](http://git.mydoc.io/)
6. 码云封面人物是一档用来展示码云会员风采的栏目 [https://gitee.com/gitee-stars/](https://gitee.com/gitee-stars/)

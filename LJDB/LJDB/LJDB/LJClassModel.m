//
//  LJClassModel.m
//  LJDB
//
//  Created by Lucky on 2018/5/27.
//  Copyright © 2018年 LuckyLiu. All rights reserved.
//

#import "LJClassModel.h"

@implementation LJClassModel

+(NSString *)setupPrimaryKey{
    return @"classID";
}

-(NSMutableArray<LJStudentModel *> *)students{
    if (!_students) {
        _students = [NSMutableArray new];
    }
    return _students;
}

@end

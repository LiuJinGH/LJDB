//
//  LJClassModel.h
//  LJDB
//
//  Created by Lucky on 2018/5/27.
//  Copyright © 2018年 LuckyLiu. All rights reserved.
//

#import "LJDBModel.h"
#import "LJStudentModel.h"

@interface LJClassModel : LJDBModel

@property (nonatomic, assign) long classID;

@property (nonatomic, strong) NSString *className;

@property (nonatomic, strong) NSMutableArray<LJStudentModel *> *students;

@end

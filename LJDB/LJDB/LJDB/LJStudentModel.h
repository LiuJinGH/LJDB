//
//  LJStudentModel.h
//  LJDB
//
//  Created by Lucky on 2018/5/27.
//  Copyright © 2018年 LuckyLiu. All rights reserved.
//

#import "LJDBModel.h"

@interface LJStudentModel : LJDBModel

@property (nonatomic, assign) long studentID;
@property(nonatomic, strong) NSString * name;
@property(nonatomic, assign) uint age;
@property(nonatomic, assign) float weight;
@property(nonatomic, assign) float height;

@end

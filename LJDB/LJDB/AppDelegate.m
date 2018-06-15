//
//  AppDelegate.m
//  LJDB
//
//  Created by 刘瑾 on 2018/5/23.
//  Copyright © 2018年 LuckyLiu. All rights reserved.
//

#import "AppDelegate.h"
#import "LJStudentModel.h"
#import "LJClassModel.h"
#import "LJDBServer.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    LJStudentModel *s1 = [LJStudentModel new];
    s1.studentID = 2000001;
    s1.name = @"小明";
    s1.weight = 120;
    s1.age = 20;
    s1.height = 170;
    
    [[LJDBServer defaultDBServer].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [s1 updateModel:db];
        [LJStudentModel selectModelWhere:[LJDBSelectCondition new] inDB:db];
    }];
    
//    NSLog(@"开始插入数据");
//    [[LJDBServer defaultDBServer].dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
//        for (int i=0 ; i<5000; i++) {
//            s1.studentID ++;
//            [s1 insertInDB:db];
//        }
//    }];
//    NSLog(@"插入完成");
//    NSLog(@"开始查数据");
//    [[LJDBServer defaultDBServer].dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
//        NSArray *temp = [LJStudentModel findAllInDB:db];
//        NSLog(@"list count: %ld", temp.count);
//    }];
    
//    [[LJDBServer defaultDBServer].dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
//        NSArray *temp = [LJStudentModel findAllInDB:db];
//        NSLog(@"list count: %ld", temp.count);
//    }];
    
//    NSLog(@"开始插入数据");
//
//    for (int i=0; i<5000; i++) {
//        s1.studentID += i;
//        [s1 insertInDatabase];
//    }
//    NSLog(@"结束插入数据");
    
//
//    LJClassModel *c1 = [LJClassModel new];
//    c1.classID = 20001;
//    c1.className = @"Runwise";
//
//
//    LJStudentModel *s2 = [LJStudentModel new];
//    s2.studentID = 10001;
//    s2.name = @"小红";
//    s2.age = 18;
//    s2.weight = 100;
//    s2.height = 168;
//    [c1.students addObject:s1];
//    [c1.students addObject:s2];
//    [c1 insertInDatabase];
//    [s2 insertInDatabase];
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

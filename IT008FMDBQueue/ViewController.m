//
//  ViewController.m
//  IT008FMDBQueue
//
//  Created by lwx on 16/7/25.
//  Copyright © 2016年 lwx. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"

@interface ViewController ()

@property (nonatomic, retain) FMDatabase *database;

//在使用FMDatabase的时候需要考虑到线程问题，而是用FMDatabaseQueue则无需我们考虑
@property (nonatomic, retain) FMDatabaseQueue *fmQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
        self.database = [FMDatabase databaseWithPath:[self getPath]];
    
        [self.database open];
    
        [self.database executeUpdate:@"CREATE TABLE IF NOT EXISTS stu (id integer PRIMARY KEY AUTOINCREMENT,name text,age integer)"];
    //
    //    [self.database close];
    
    
    
    self.fmQueue = [FMDatabaseQueue databaseQueueWithPath:[self getPath]];
    
    //使用该方法无需我们打开数据库，
    [self.fmQueue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS people (id integer PRIMARY KEY AUTOINCREMENT,name text,age integer)"];
        
    }];
    
    
    
    
    
    
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapG:)];
    [self.view addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tapD = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDG:)];
    tapD.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapD];
    
}

- (void)tapDG:(UITapGestureRecognizer *)sender {
    
    for (NSInteger i = 0; i < 10000; i++) {
        [self insertToQueue];
    }
}

- (void)insertToQueue {
    
    [self.fmQueue inDatabase:^(FMDatabase *db) {
        NSString *name = [NSString stringWithFormat:@"someone%d",arc4random()%100];
        
        NSNumber *age = @(arc4random()%100);
        
        [db executeUpdate:@"INSERT INTO people(name,age) VALUES(?,?)",name,age];
    }];
    
}


- (IBAction)buttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
            [self tapG:nil];
            break;
        case 1:
            [self tapDG:nil];
            break;
        case 2:
            [self testInTransaction];
            break;
        default:
            break;
    }
}


- (void)tapG:(UITapGestureRecognizer *)sender {
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    for (NSInteger i = 0; i < 10000; i++) {
     
        [self insertToDB];

    }

}


- (void)insertToDB {
    
    NSString *name = [NSString stringWithFormat:@"someone%d",arc4random()%100];
    
    NSNumber *age = @(arc4random()%100);
    
    @synchronized(self) {
        [self.database executeUpdate:@"INSERT INTO stu(name,age) VALUES(?,?)",name,age];
    }

}




- (NSString *)getPath {
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/fmdb.sqlite"];
    
    NSLog(@"%@",path);
    
    return path;
}




#pragma mark - inTransaction
- (void)testInTransaction {
    
    [self.fmQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        //事务
        //rollback用来回滚
        for (NSInteger i = 0; i < 10000; i++) {
            NSString *name = [NSString stringWithFormat:@"someone%d",arc4random()%100];
            
            NSNumber *age = @(arc4random()%100);
            
            [db executeUpdate:@"INSERT INTO people(name,age) VALUES(?,?)",name,age];
        }
    }];
}






@end

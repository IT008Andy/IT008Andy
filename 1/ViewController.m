//
//  ViewController.m
//  1
//
//  Created by Mac on 16/7/25.
//  Copyright © 2016年 Andy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    
    NSInteger index;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
//    1.创建组队列。
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        
//        进入组队列。
        dispatch_group_enter(group);
        
        sleep(5);
//        发送请求1
        NSLog(@"1");
        
//        离开组队列。
        dispatch_group_leave(group);
        
    });
    
    dispatch_group_async(group, queue, ^{
        
//        进入组队列。
        dispatch_group_enter(group);
        
        sleep(5);
//        发送请求2
        NSLog(@"2");
        
//        离开组队列。
        dispatch_group_leave(group);
        
    });
    
//    ...
    
    
//    获取结束时的状态
    
//    方法一：
//    该方法最好不要在主线程里面使用，因为阻塞主线程有风险，会导致死循环。实在要用就在外围用一个异步线程。
//    阻塞主线程。最好不要这么做。
//    参数二：永久阻塞
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//    NSLog(@"所有请求完成");
    
    
//    方法二：
//    该方法不会运用线程，也不会阻塞。
//    组通知，获取结果
    dispatch_group_notify(group, queue, ^{
        
        NSLog(@"所有请求完成");
        
    });
    
    NSLog(@"这是主通知的外面");
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

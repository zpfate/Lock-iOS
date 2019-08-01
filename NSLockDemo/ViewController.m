//
//  ViewController.m
//  NSLockDemo
//
//  Created by Twisted Fate on 2018/10/16.
//  Copyright © 2018 TwistedFate. All rights reserved.
//

#import "ViewController.h"


#define LogInfo(format, ...) NSLog(@"%s " format, __FUNCTION__, ##__VA_ARGS__);


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)nslock:(id)sender {
    
    // NSLock 锁
    NSLock *lock = [[NSLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        LogInfo(@"线程1-----------------------------");
        [lock lock];
        LogInfo(@"线程1上锁成功-----------------------------");
        sleep(3);
        LogInfo(@"线程1解锁成功");
        [lock unlock];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        LogInfo(@"线程2-----------------------------");
        sleep(1);
        //        trylock不会主阻塞线程
        BOOL canLock = [lock tryLock];
        //        lockBeforeDate:在是时间前尝试加锁, 或导致线程阻塞
        //        BOOL canLock = [lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        if (canLock) {
            LogInfo(@"线程2上锁成功-----------------------------");
            [lock unlock];
            LogInfo(@"线程2解锁成功-----------------------------");
        } else {
            LogInfo(@"线程2上锁失败-----------------------------");
        }
    });
    
    /*
     输出结果:
     NSLockDemo[7130:2239432] 线程1-----------------------------
     NSLockDemo[7130:2239434] 线程2-----------------------------
     NSLockDemo[7130:2239432] 线程1上锁成功-----------------------------
     NSLockDemo[7130:2239432] 线程1解锁成功
     NSLockDemo[7130:2239434] 线程2上锁成功-----------------------------
     NSLockDemo[7130:2239434] 线程2解锁成功-----------------------------
     **/
    
    // 线程 1 中的 lock 锁上了，所以线程 2 中的 lock 加锁失败，阻塞线程 2，但 2 s 后线程 1 中的 lock 解锁，线程 2 就立即加锁成功，执行线程 2 中的后续代码
}

- (IBAction)conditionLock:(id)sender {
    
    // NSConditionLock 条件锁
    NSConditionLock *conditionLock = [[NSConditionLock alloc] initWithCondition:0];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [conditionLock lockWhenCondition:1];
        LogInfo(@"线程1--------");
        sleep(2);
        [conditionLock unlock];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 保证线程2的代码后执行
        sleep(1);
        if ([conditionLock tryLockWhenCondition:0]) {
            LogInfo(@"线程2");
            [conditionLock unlockWithCondition:2];
            LogInfo(@"线程2解锁成功");
        } else {
            LogInfo(@"线程2尝试加锁失败");
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);//以保证让线程2的代码后执行
        if ([conditionLock tryLockWhenCondition:2]) {
            LogInfo(@"线程3");
            [conditionLock unlock];
            LogInfo(@"线程3解锁成功");
        } else {
            LogInfo(@"线程3尝试加锁失败");
        }
    });
    
    //线程4
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(3);//以保证让线程2的代码后执行
        if ([conditionLock tryLockWhenCondition:2]) {
            LogInfo(@"线程4");
            [conditionLock unlockWithCondition:1];
            LogInfo(@"线程4解锁成功");
        } else {
            LogInfo(@"线程4尝试加锁失败");
        }
    });
}

- (IBAction)operationBlock:(id)sender {
    
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];


    [queue addOperations:@[] waitUntilFinished:YES];
    
    // 2.创建操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 模拟我们封装的那种 异步去请求数据的操作
            sleep(4);
            NSLog(@"1---%@", [NSThread currentThread]);
//        });
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 模拟我们封装的那种 异步去请求数据的操作
            sleep(6);
            NSLog(@"2---%@", [NSThread currentThread]);
//        });
    }];
    
//    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
//        NSLog(@"3---%@", [NSThread currentThread]);
//    }];
    // 3.添加依赖 (不能相互依赖)
//    [op3 addDependency:op1];
//    [op3 addDependency:op2];
    
    // 4.添加到操作队列
//    [queue addOperation:op1];
//    [queue addOperation:op2];
//
//    [queue addOperationWithBlock:^{
//        NSLog(@"12312321");
//    }];
//    [[NSOperationQueue mainQueue] addOperation:op3];
}

@end

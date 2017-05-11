//
//  ViewController.m
//  SFJBlockDemo
//
//  Created by 沙缚柩 on 2017/5/11.
//  Copyright © 2017年 沙缚柩. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"异步执行block global = %ld, main = %ld",[self globalNum],[self mainNum]);
    NSLog(@"同步执行block syncGlobalNum = %ld",[self syncGlobalNum]);
    NSLog(@"同步执行block Num = %ld",[self num]);
}

- (NSInteger)num{
    __block NSInteger i = 0;
    [self doSomethingSuccess:^{
        i = 10;
    }];
    return i;
}

- (NSInteger)globalNum{
    __block NSInteger i = 0;
    [self doSomethingInGlobalQueueSuccess:^{
        i = 10;
    }];
    return i;
}

- (NSInteger)mainNum{
    __block NSInteger i = 0;
    [self doSomethingInMainThreadSuccess:^{
        i = 10;
    }];
    return i;
}

- (NSInteger)syncGlobalNum{
    __block NSInteger i = 0;
    [self doSomethingSyncSuccess:^{
        i = 10;
    }];
    return i;
}
// 程序原本 就相当于是同步的，执行的时候总是等待上一个函数进行完成才进入下一个函数
- (void)doSomethingSuccess:(void (^) ())success{
    !success? : success();
}

// 异步并发队列
- (void)doSomethingInGlobalQueueSuccess:(void (^) ())success{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        !success? : success();
    });
}

- (void)doSomethingSyncSuccess:(void (^) ())success{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        !success? : success();
    });
}

// 主线程
- (void)doSomethingInMainThreadSuccess:(void (^) ())success{
    dispatch_async(dispatch_get_main_queue(), ^{
        !success? : success();
    });
}
/**
 总结： block内的函数的执行，是否等待取决于我们是同步还是一部执行的block

 - (NSInteger)syncGlobalNum{
    __block NSInteger i = 0;
    [self doSomethingSyncSuccess:^{
        i = 10;
    }];
    return i;
 }
所以当我们需要从block中去修改最终的返回值的时候，必须保证block是同步执行才能正确的返回值。
经过如上的验证可以看出跟我们block所处的队列是没关系的。
 
那么如何才算是同步执行的block呢？

 - (void)doSomethingSuccess:(void (^) ())success{
    !success? : success();
 }
 或
 - (void)doSomethingSyncSuccess:(void (^) ())success{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        !success? : success();
    });
 }
 */

/**
 所以当我们使用自己写的block来作这样的返回，我们很容易知道我们的block是异步还是同步，
 然后正确的采取返回措施，但是如果是用到系统的函数并且涉及到block的时候，我们就需要查看
 官方文档了，因为没有block的实现，我们不知道block是同步执行的还是异步执行的，无法正确
 的返回。
 */

@end

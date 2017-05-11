# SFJBlockDemo
如何正确的从block中返回函数返回值

### 可能有时候我们会写这样的函数，但是我们并不知道block是否等待然后执行
```Objective-c
- (NSInteger)num{
    __block NSInteger i = 0;
    [self doSomethingSuccess:^{
        i = 10;
    }];
    return i;
}
```

__block 是通过指针的方式去修改i的值，所以值可以修改这是没问题的，但是执行success这个block里面的语句
也就是 i = 10; 这句是否等待block执行完在执行return，还是会直接跳过 i = 10; 直接执行return。
这就引发了调用block做修改时的歧义。

demo里面 我们一共写了4个带有block的函数。
```Objective-c
/** 
  默认不做任何修饰
  
  默认不加任何线程与同步异步调用的方式（程序原本 就相当于是同步的，
  执行的时候总是等待上一个函数进行完成才进入下一个函数）-> 相当于是同步
*/
- (void)doSomethingSuccess:(void (^) ())success 
- (NSInteger)num

/**
  全局并发队列 同步调用block
*/ 
- (void)doSomethingSyncSuccess:(void (^) ())success
- (NSInteger)syncGlobalNum

/**
  全局并发队列 异步调用block
*/
- (void)doSomethingInGlobalQueueSuccess:(void (^) ())success
- (NSInteger)globalNum
/**
  主线程 异步
*/
- (void)doSomethingInMainThreadSuccess:(void (^) ())success
- (NSInteger)mainNum
```

也许你会有疑问，为什么没有 主线程 同步 的验证？
额、验证过了，同步队列，同步调用陷入线程等待，程序假死。
在每个带block的函数下面都有一个带

在每个带block的函数下面都有一个返回NSInterger的返回值的函数，函数的实现都是这样的
```Objective-c
- (NSInteger)num{
    __block NSInteger i = 0;
    [self doSomethingSuccess:^{
        i = 10;
    }];
    return i;
}
```
那么如果我们的值，通过block修改成功并最终返回的10；
具体输出大家可以去查看demo，同步的方式都能得到10，异步得到0 
下面进行总结

## 总结
block内的函数的执行，是否等待取决于我们是同步还是异步执行的block，
与队列无关。

```Objective-c
/**
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

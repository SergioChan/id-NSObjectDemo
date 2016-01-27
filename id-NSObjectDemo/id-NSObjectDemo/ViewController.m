//
//  ViewController.m
//  id-NSObjectDemo
//
//  这是一个博客的示例代码，保证跑不起来，所以不要想着build。看就好了。(手动doge)
//  Created by 叔 陈 on 1/27/16.
//  Copyright © 2016 叔 陈. All rights reserved.
//

#import "ViewController.h"

// 如果去掉这个import，那下面的所有对于fuck的方法调用全部都会报错
#import "TestObject.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 这里你可以看到，test是一个指向UIImage对象的id指针，你可以向他发送length消息
    // 然而如果他不是一个对象指针，而是一个对象，那么你向他发送length消息的话，在编译的时候编译器会无法编译，原因在下面有提到
    
    id test = [[UIImage alloc] init];
    [test length];
    
    NSObject *test1 = [[UIImage alloc]init];
    [test1 length];
    
    // 这里你可以看到，如果引入了TestObject的头文件，对于任意id类型的对象指针，你就可以向他发送TestObject能够响应的消息了
    // 无论这个id类型指针指向的对象是不是TestObject类型，编译器并不关心这个，也无法知道
    // 然而对于NSObject，他仍然不能响应这个fuck方法，因为向一个对象发送消息的时候，编译器会在对象声明类型的方法表中去判断这个对象是否能够响应这个消息
    // 而不是根据实际分配的对象类型
    
    id test3 = [[UIImage alloc]init];
    [test3 fuck];
    
    NSObject *test2 = [[TestObject alloc]init];
    [test2 fuck];
    
    // 所以其实NSObject很少手动声明，如果要声明具体的对象，则最好声明具体的类型，或者id动态类型
    // id之所以为动态类型，在于它所指向的对象类型是在运行时才确定的，因此使用起来更加的方便
    // NSObject 只能响应自己的一些简单的方法，例如 copy，hash之类
    
    [test2 hash];
    
    // 下面解释了为什么delegate要用id声明而不是用NSObject
    // @property (nonatomic,weak) id<TestDelegate> delegate;
    // @property (nonatomic,weak) NSObject<TestDelegate> *delegate;
    // 大部分delegate在实现的时候都需要像下面这个来调用，根据上文所说，因为delegate的方法表其实是运行时生成的，因此在编译时编译器是无法识别的
    // 因此这种调用方式也就不能成立，因此delegate要用第一种id的声明方式来声明
    
    NSObject *test4 = [[TestObject alloc]init];
    if([test4 respondsToSelector:@selector(fuck)])
    {
        [test4 fuck];
    }
    
    id test5 = [[TestObject alloc]init];
    if([test5 respondsToSelector:@selector(fuck)])
    {
        [test5 fuck];
    }
    
    // 当然如果id所指向的对象在运行时无法响应fuck方法，运行时就会报错
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


# 三件小事

事情是这样的。  
江南皮革厂倒闭了。于是最近有这三件小事一直困扰着我。  
一个是id和NSObject的解释，看过很多博客，但是却一直没有一个深刻的理解，现在醒悟过来觉得大概是看的那些博客本身就讲的含糊不清吧。所以我就用我最直白的语言和解释来说明一下我对于id和NSObject的一些小见解。一开始直接就是跟着代码写的，所以非常的直接。  
第二个是weak和assign的小事，为什么delegate需要声明weak而不是assign。  
第三个是关于这个`NS_DESIGNATED_INITIALIZER`宏的解释。
> 还是少看CocoaChina的论坛吧。

## id, NSObject 那些事

这里讲的关于id和NSObject的内容，最好打开你的Xcode，打开demo工程，然后就能看到一系列编译的警告。跟着警告往下看你就会对于id和NSObject的区别更加的理解了。

这里你可以看到，test是一个指向UIImage对象的id指针，你可以向他发送length消息。  
然而如果他不是一个对象指针，而是一个对象，那么你向他发送length消息的话，在编译的时候编译器会无法编译，原因在下面有提到。
    
```Objective-C
id test = [[UIImage alloc] init];
[test length];

NSObject *test1 = [[UIImage alloc]init];
[test1 length];
```

这里你可以看到，如果引入了TestObject的头文件，对于任意id类型的对象指针，你就可以向他发送TestObject能够响应的消息了。  
无论这个id类型指针指向的对象是不是TestObject类型，编译器并不关心这个，也无法知道。  
然而对于NSObject，他仍然不能响应这个fuck方法，因为向一个对象发送消息的时候，编译器会在对象声明类型的方法表中去判断这个对象是否能够响应这个消息，而不是根据实际分配的对象类型。
   
```Objective-C 
id test3 = [[UIImage alloc]init];
[test3 fuck];

NSObject *test2 = [[TestObject alloc]init];
[test2 fuck];
```

所以其实NSObject很少手动声明，如果要声明具体的对象，则最好声明具体的类型，或者id动态类型。  
id之所以为动态类型，在于它所指向的对象类型是在运行时才确定的，因此使用起来更加的方便。  
NSObject 只能响应自己的一些简单的方法，例如 copy，hash之类。

```Objective-C   
[test2 hash];
```
    
下面解释了为什么delegate要用id声明而不是用NSObject

```Objective-C 
@property (nonatomic,weak) id<TestDelegate> delegate;
@property (nonatomic,weak) NSObject<TestDelegate> *delegate;
```

大部分delegate在实现的时候都需要像下面这个来调用，根据上文所说，因为delegate的方法表其实是运行时才能知道的，在编译时编译器是无法识别的，所以这种调用方式也就不能成立，因此delegate要用第一种id的声明方式来声明：

```Objective-C 
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
```

当然如果id所指向的对象在运行时无法响应fuck方法，运行时就会报错。  
可以这么说吧： **NSObject声明的对象类型在编译时确定，id声明的对象类型在运行时确定**，因此在消息发送上会有一些区别。

## weak, assign 那些事
这个问题起源于这两种声明delegate的方式：

```Objective-C
@property (nonatomic, weak) id  <fuckDelegate> delegate; 
@property (nonatomic, assign) id  <fuckDelegate> delegate; 
```

首先第一种声明方式在我们的日常使用中十分的常见，可能都已经成为一种习惯了。但是例如已经被废弃的 `@property(nonatomic, assign) id< UISearchDisplayDelegate > delegate`，虽然在iOS8之后被废弃，然而它说明delegate也可以用第二种声明方式。

区别就在于weak和assign声明的属性虽然都是不会引起引用计数的增加，但是还是有很大不同。[weak的实现](http://www.cocoachina.com/ios/20150605/11990.html)决定了在属性的主人释放的时候，weak指针所对应的对象也会一起被释放，然而assign不会，因此这里有产生一个野delegate指针的风险。除非是在MRC的环境下，手动对delegate置为nil。这会需要额外的操作，因此后来系统的实现渐渐的也转向weak了。

参考[这里](http://stackoverflow.com/questions/9428500/whats-the-difference-between-weak-and-assign-in-delegate-property-declaratio)。

## NS_DESIGNATED_INITIALIZER
第一次看到这个的时候，心里想的是 “WTF 这是什么鬼”。

```Objective-C
-(instancetype)initWithName:(NSString *)name NS_DESIGNATED_INITIALIZER;
-(instancetype)init;
```

这时候看看Swift就明白了 =。= 这是objc为了配合Swift的特性而诞生的一个附加宏。Swift中有designated和convenience两种初始化方法，它要求我们初始化出来的实例对象尽量是属性完整的，即使使用了convenience的初始化方法，也会要求在这个初始化方法中调用同类的designated的初始化方法完成完整的初始化。

像这样：

```Objective-C
- (instancetype)init
{
    self = [self initWithName:@"fuck"];
    return self;
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    return self;
}
```

所以这只是一个Swift的特性的objc版本，也是为了更好的和Swift配合开发而加上的。

参考[这里](http://stackoverflow.com/questions/26185239/ios-designated-initializers-using-ns-designated-initializer)。
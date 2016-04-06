

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#pragma mark --- signal/信号 ---
    [self.username.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    /**
     *  代码解析:
     *  self.username.rac_textSignal:rac_textSignal是textField类目中的方法.有了信号才可以传递数据.
     *  subscribeNext: 这是一个方法簇,其中包含接收之后下一步干什么,接收之后下一步也干完了,那么要返回什么.在干活的过程中,如果出错了需要提示什么?
     *  总结:当接收的数据发生改变之后,那么就会触发block方法,block方法中又嵌套了一层block方法,最终达到的效果是:随着数据的改变而改变
     */

    
#pragma mark --- 过滤/filter ---
//    [[self.username.rac_textSignal filter:^BOOL(NSString *value) {
//        return value.length > 4;
//    }] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
    /**
     *  代码解析
     *  filter: 过滤器
     *  ^BOOL(NSString *valule):在textField中,数据是字符串,所以给与之对称的数据类型.
     *  return: 过滤条件
     *  总结: 如果过滤条件满足,才可以继续往下走方法.
     */

    
#pragma mark --- 映射/map ---
//    [[[self.username.rac_textSignal map:^id(NSString *value) {
//        return @(value.length);
//    }] filter:^BOOL(NSNumber *length) {
//        return [length integerValue] > 3;
//    }] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
    /**
     *  代码解析
     *  map: 地图,映射的意思.
     *  ^id(NSString *value):获取textField中的内容
     *  return: 返回最终的内容结果
     *  @(value.length); 这是将字符串长度转化为对象类型
     */

    
#pragma mark --- 处理数组数据 ---
    RACSequence *sequence = [@[@"you",@"are",@"my",@"destiny"]rac_sequence];
    RACSignal *signal = [sequence signal];
    
    [[signal map:^id(NSString *value) {
        return [value capitalizedString];
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
#pragma mark --- 信号的自定义 ---
    // 关键字 （RACSubject）
    /** 自定义信号需要考虑的三个问题
     *  1.自定创建信号的关键字是什么? (RACSubject)
     *  2.信号的开关怎么设置
     *  3.由谁来打开信号开关
     */
    // 1创建信号
//    RACSubject *homework = [RACSubject subject];
//    
//    // 1.1开启信号开关的信号
//    RACSubject *subject = [RACSubject subject];
//    
//    
//    RACSignal *mywebsite = [subject switchToLatest];
//    
//    // 3.对数据进行反馈
//    [mywebsite subscribeNext:^(id x) {
//        UIWebView *web = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        [web loadRequest:[NSURLRequest requestWithURL:x]];
//        [self.view addSubview:web];
//    }];
//    
//    // 2.传输数据
//    [subject sendNext:homework];
//    [homework sendNext:[NSURL URLWithString:@"http://www.wuocean.com"]];
    
    
#pragma mark --- 组合信号
    
    /** 组合信号需要考虑的三个问题
     *  1.自定义创建信号
     *  2.由谁来对自定义信号进行组合
     *  3.信号发出的数据是什么?
     *  combine: 组合
     *  Latest: 最新的
     *  reduce: 归并
     */
    
    // 创建两个自定义信号
    RACSubject *letters = [RACSubject subject];
    RACSubject *numbers = [RACSubject subject];
    
    // 对两个信号进行组合
    [[RACSignal combineLatest:@[letters,numbers] reduce:^(NSString *letter,NSString *number){
        return [letter stringByAppendingString:number];
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 为信号添加数据
    [letters sendNext:@"hello"];
    [numbers sendNext:@"1"];
    [numbers sendNext:@"3"];
    [letters sendNext:@"52"];
    [letters sendNext:@"haha"];
    [numbers sendNext:@"2"];
    
    // 总结:组合信号,只有在组合信号都有数据之后,才会产生新值,如果一个信号没有值,那么另一个信号就会等待直到有值. 组合顺序,以两个不同的信号为单位,从下往上找离自身最近的进行组合.
    
#pragma mark --- 信号合并
    
    // 特点: 谁有内容就出谁
    // merge:
    
    // 自定义三个信号量
    RACSubject *letters2 = [RACSubject subject];
    RACSubject *numbers2 = [RACSubject subject];
    RACSubject *chinese = [RACSubject subject];
    
    // 信号合并
    [[RACSignal merge:@[letters2,numbers2,chinese]]
     subscribeNext:^(id x) {
         NSLog(@"%@",x);
     }];
    
    // 为信号添加数据
    [letters2 sendNext:@"你"];
    [chinese sendNext:@"好"];
    [numbers2 sendNext:@"6"];
    
    // 总结: 信号合并使用关键字merge对信号门进行合并,合并之后,不管哪个管道中有数据,都会输出.不用等待其他管道.

#pragma mark --- 广播/通知
    // 5行代码代替通知
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:@"maincode.cn" object:nil]
     subscribeNext:^(NSNotification *x) {
         NSLog(@"技巧: %@",x.userInfo[@"找工作技巧"]);
     }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"maincode.cn" object:nil userInfo:@{@"找工作技巧":@"出去面试"}];
    
#pragma mark --- 延迟
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"等我10秒,马上就到!");
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
        return nil;
    }]delay:10]subscribeNext:^(id x) {
        NSLog(@"到了");
    }];
    
    
#pragma mark --- 定时
    [[RACSignal interval:6 onScheduler:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        NSLog(@"打针");
    }];
// 最后总结:这些内容只是ReactiveCocoa的冰山一角，还有很多需要大家自己去发掘。

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

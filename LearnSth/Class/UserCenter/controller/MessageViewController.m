//
//  MessageViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/25.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "MessageViewController.h"

#import "MessageViewCell.h"

@interface MessageViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataArray;

@end

static NSString *reuseIdentifier = @"cell";

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息";
    self.dataArray = @[
                       @"浅copy:指针复制，不会创建一个新的对象。\n深copy:内容复制，会创建一个新的对象。",
                       @"对immutableObject，即不可变对象，执行copy，会得到不可变对象，并且是浅copy。\n对immutableObject，即不可变对象，执行mutableCopy，会得到可变对象，并且是深copy。\n对mutableObject，即可变对象，执行copy，会得到不可变对象，并且是深copy。\n对mutableObject，即可变对象，执行mutableCopy，会得到可变对象，并且是深copy。",
                       @"如果想完美的解决NSArray嵌套NSArray这种情形，可以使用归档、解档的方式。\n归档和解档的前提是NSArray中所有的对象都实现了NSCoding协议。"
                       ];
    
    [self.view addSubview:self.tableView];
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    cell.content = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *content = self.dataArray[indexPath.row];
    
    UIFont *font = [UIFont systemFontOfSize:15];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    [style setLineSpacing:3.0];
    NSDictionary *attribute = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:style};
    
    CGSize size = [content boundingRectWithSize:CGSizeMake(ScreenWidth - 40, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:attribute
                                        context:nil].size;
    
    return size.height + 40;
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ViewFrameOrigin_X, ScreenWidth, ScreenHeight - 64)
                                                  style:UITableViewStylePlain];
        [_tableView registerClass:[MessageViewCell class] forCellReuseIdentifier:reuseIdentifier];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 50;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

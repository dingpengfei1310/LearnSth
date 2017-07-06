//
//  MessageViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/25.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageTableCell.h"

@interface MessageViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *heightArray;

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
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        [arrayM addObjectsFromArray:self.dataArray];
    }
    self.dataArray = [NSArray arrayWithArray:arrayM];
    
    self.heightArray = [NSMutableArray array];
    [self.view addSubview:self.tableView];
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageTableCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    cell.content = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.heightArray.count > indexPath.row) {
        return [self.heightArray[indexPath.row] floatValue];
        
    } else {
        NSString *content = self.dataArray[indexPath.row];
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 1.0;
        style.lineBreakMode = NSLineBreakByCharWrapping;
        NSDictionary *attribute = @{NSFontAttributeName:font,
                                    NSParagraphStyleAttributeName:style};
        
        CGSize size = [content boundingRectWithSize:CGSizeMake(CGRectGetWidth(tableView.frame) - 40, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size;
        
        [self.heightArray addObject:@(ceilf(size.height) + 40.0)];
        return ceilf(size.height) + 40.0;
    }
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[MessageTableCell class] forCellReuseIdentifier:reuseIdentifier];
        
        _tableView.backgroundColor = KBackgroundColor;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        _tableView.estimatedRowHeight = 160;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

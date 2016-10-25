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
@property (nonatomic, strong) NSArray *dataArray;

@end

static NSString *reuseIdentifier = @"cell";

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息";
    self.dataArray = @[@"上传文件法国代购电饭锅电饭锅电饭锅电饭锅地方地方顾客都反馈个大反派看过吗",@"查看相册从 v 变成 v 巴格达也让特有人同意让他依然讨厌热天有人同意恢复光滑风格化风格化风格化风格化风格化",@"好好学习"];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64) style:UITableViewStylePlain];
    [_tableView registerClass:[MessageViewCell class] forCellReuseIdentifier:reuseIdentifier];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 50;
    [self.view addSubview:_tableView];
    
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

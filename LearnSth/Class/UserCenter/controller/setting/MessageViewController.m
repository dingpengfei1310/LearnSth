//
//  MessageViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/25.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageTableCell.h"

@interface MessageViewController ()<UITableViewDataSource,UITableViewDelegate> {
    CGFloat viewW;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL noMoreData;
@property (nonatomic, assign) BOOL refreshing;

@end

static NSString *const identifier = @"messCell";
static const CGFloat threshold = 0.7;//预加载
static const NSInteger itemPerPage = 20;//每页个数

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息";
    
    _currentPage = 1;
    viewW = Screen_W;
    [self.view addSubview:self.tableView];
    
    [self loadLiveData];
}

- (void)loadLiveData {
    _refreshing = YES;
    
    NSDictionary *param = @{@"page":@(_currentPage)};
    [[HttpManager shareManager] getHotLiveListWithParam:param completion:^(NSArray *list, NSError *error) {
        
        if (error) {
            [self showErrorWithError:error];
            if (_currentPage > 1) {
                _currentPage--;
            }
        } else {
            if (list.count < itemPerPage) {
                _noMoreData = YES;
            }
            [self loadData:list];
        }
        
    }];
}

//- (void)loadMessageData {
//    viewW = Screen_W;
//    NSArray *tempArray = @[
//                           @"浅copy:指针复制，不会创建一个新的对象。\n深copy:内容复制，会创建一个新的对象。",
//                           @"对immutableObject，即不可变对象，执行copy，会得到不可变对象，并且是浅copy。\n对immutableObject，即不可变对象，执行mutableCopy，会得到可变对象，并且是深copy。\n对mutableObject，即可变对象，执行copy，会得到不可变对象，并且是深copy。\n对mutableObject，即可变对象，执行mutableCopy，会得到可变对象，并且是深copy。",
//                           @"如果想完美的解决NSArray嵌套NSArray这种情形，可以使用归档、解档的方式。\n归档和解档的前提是NSArray中所有的对象都实现了NSCoding协议。"
//                           ];
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSMutableArray *arrayM = [NSMutableArray array];
//        for (int i = 0; i < 50; i++) {
//            for (int i = 0; i < tempArray.count; i++) {
//
//                NSString *content = tempArray[i];
//                UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
//                NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//                style.lineSpacing = 1.0;
//                style.lineBreakMode = NSLineBreakByCharWrapping;
//                NSDictionary *attribute = @{NSFontAttributeName:font,
//                                            NSParagraphStyleAttributeName:style};
//
//                CGSize size = [content boundingRectWithSize:CGSizeMake(viewW - 40, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size;
//
//                NSDictionary *info = @{@"content":content,
//                                       @"height":@(ceilf(size.height) + 40.0)};
//                [arrayM addObject:info];
//            }
//        }
//
//        self.dataArray = [NSMutableArray arrayWithArray:arrayM];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
//        });
//    });
//}

- (void)loadData:(NSArray *)list {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *arrayM = [NSMutableArray array];
        
        for (NSDictionary *dict in list) {
            
            NSString *content = [NSString stringWithFormat:@"%@ (%@)",dict[@"familyName"],dict[@"myname"]];
            UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 1.0;
            style.lineBreakMode = NSLineBreakByCharWrapping;
            NSDictionary *attribute = @{NSFontAttributeName:font,
                                        NSParagraphStyleAttributeName:style};
            
            CGSize size = [content boundingRectWithSize:CGSizeMake(viewW - 40, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size;
            
            NSDictionary *info = @{@"content":content,
                                   @"height":@(ceilf(size.height) + 40.0)};
            [arrayM addObject:info];
        }
        
        if (_currentPage == 1) {
            self.dataArray = [NSMutableArray arrayWithArray:arrayM];
        } else {
            [self.dataArray addObjectsFromArray:arrayM];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            _refreshing = NO;
        });
    });
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSDictionary *info = self.dataArray[indexPath.row];
    cell.content = info[@"content"];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = self.dataArray[indexPath.row];
    return [info[@"height"] floatValue];
}

#pragma mark
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_noMoreData || _refreshing) {
        return;
    }
    
    CGFloat current = scrollView.contentOffset.y + scrollView.frame.size.height;
    CGFloat total = scrollView.contentSize.height;
    CGFloat ratio = current / total;
    
    NSInteger totalItem = itemPerPage * (_currentPage + 1);
    CGFloat needRead = itemPerPage * threshold + _currentPage * itemPerPage;
    CGFloat newThreshold = needRead / totalItem;
    
    if (ratio >= newThreshold) {
        _currentPage += 1;
        [self loadLiveData];
    }
}

#pragma mark
- (UITableView *)tableView {
    if (!_tableView) {
        CGFloat barH = NavigationBarH + StatusBarH;
        CGRect frame = CGRectMake(0, barH, Screen_W, Screen_H - barH);
        
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [_tableView registerClass:[MessageTableCell class] forCellReuseIdentifier:identifier];
        
        _tableView.backgroundColor = KBackgroundColor;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        _tableView.estimatedRowHeight = 0;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

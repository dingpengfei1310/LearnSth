//
//  TableViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/26.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "TableViewController.h"

#import "MGSwipeTableCell.h"

@interface TableViewController ()

@end

static NSString *reuseIdentifier = @"cell";

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[MGSwipeTableCell class] forCellReuseIdentifier:reuseIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = @"0";
    
//    MGSwipeButton *rightButton = [MGSwipeButton buttonWithTitle:@"00" backgroundColor:[UIColor greenColor] callback:^BOOL(MGSwipeTableCell *sender) {
//        NSLog(@"MGSwipeTableCell");
//        return YES;
//    }];
//    
//    cell.rightButtons = @[rightButton];
    
    return cell;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"12" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        
    }];
    
    return @[action];
}

@end

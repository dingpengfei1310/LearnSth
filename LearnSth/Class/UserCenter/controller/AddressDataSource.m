//
//  AddressDataSource.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/30.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "AddressDataSource.h"

@interface AddressDataSource ()

@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) CellInfoBlock cellInfoBlock;

@end

@implementation AddressDataSource
- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithDatas:(NSArray *)datas identifier:(NSString *)identifier cellBlock:(CellInfoBlock)cellBlock {
    if (self = [super init]) {
        self.dataArray = [datas copy];
        self.cellIdentifier = [identifier copy];
        self.cellInfoBlock = [cellBlock copy];
    }
    return self;
}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:self.cellIdentifier];
    }
    
    NSDictionary *info = self.dataArray[indexPath.row];
    if (self.cellInfoBlock) {
        self.cellInfoBlock(cell,info);
    }
    
    return cell;
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
}

@end


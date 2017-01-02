//
//  AddressDataSource.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/12/30.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CellInfoBlock)(UITableViewCell *cell,NSDictionary *data);

@interface AddressDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, copy) NSArray *dataArray;

- (instancetype)initWithDatas:(NSArray *)datas
                   identifier:(NSString *)identifier
                    cellBlock:(CellInfoBlock)cellBlock;

@end

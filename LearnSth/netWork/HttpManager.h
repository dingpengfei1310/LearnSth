//
//  HttpManager.h
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpManager : NSObject

+ (instancetype)shareManager;

///
- (void)getList;

- (void)getStockData;

- (void)getFutureData;

@end

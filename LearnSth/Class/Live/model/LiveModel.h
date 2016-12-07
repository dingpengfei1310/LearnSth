//
//  LiveModel.h
//  ReadyJob
//
//  Created by 丁鹏飞 on 16/8/28.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveModel : NSObject

@property (nonatomic, strong) NSNumber *allnum;
@property (nonatomic, strong) NSNumber *roomid;
@property (nonatomic, strong) NSNumber *serverid;
@property (nonatomic, strong) NSNumber *starlevel;
@property (nonatomic, strong) NSNumber *level;

@property (nonatomic, strong) NSNumber *useridx;
@property (nonatomic, strong) NSNumber *gender;

@property (nonatomic, copy) NSString *flv;

@property (nonatomic, copy) NSString *familyName;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *myname;
@property (nonatomic, copy) NSString *nation;
@property (nonatomic, copy) NSString *nationFlag;

@property (nonatomic, copy) NSString *smallpic;
@property (nonatomic, copy) NSString *bigpic;
@property (nonatomic, copy) NSString *signatures;
@property (nonatomic, copy) NSString *gps;

@property (nonatomic, strong) NSNumber *grade;
@property (nonatomic, strong) NSNumber *curexp;
@property (nonatomic, strong) NSNumber *isSign;
@property (nonatomic, strong) NSNumber *pos;

+ (NSArray<LiveModel *> *)liveWithArray:(NSArray *)array;

@end

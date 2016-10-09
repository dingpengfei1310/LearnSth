//
//  LiveModel.h
//  ReadyJob
//
//  Created by 丁鹏飞 on 16/8/28.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveModel : NSObject

@property (nonatomic, copy) NSString *allnum;
@property (nonatomic, copy) NSString *roomid;
@property (nonatomic, copy) NSString *serverid;
@property (nonatomic, copy) NSString *gps;

@property (nonatomic, copy) NSString *flv;

@property (nonatomic, copy) NSString *familyName;
@property (nonatomic, copy) NSString *useridx;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *myname;

@property (nonatomic, copy) NSString *smallpic;
@property (nonatomic, copy) NSString *bigpic;

@property (nonatomic, copy) NSString *signatures;
@property (nonatomic, copy) NSString *starlevel;
@property (nonatomic, copy) NSString *level;

@property (nonatomic, copy) NSString *grade;
@property (nonatomic, copy) NSString *curexp;

+ (NSArray<LiveModel *> *)liveWithArray:(NSArray *)array;

@end

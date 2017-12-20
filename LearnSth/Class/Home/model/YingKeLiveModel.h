//
//  YingKeLiveModel.h
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/12/20.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YingKeLiveModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *live_type;

@property (nonatomic, copy) NSString *share_addr;
@property (nonatomic, copy) NSString *stream_addr;

@property (nonatomic, copy) NSDictionary *creator;
//@property (nonatomic, copy) NSDictionary *extra;
//@property (nonatomic, copy) NSArray *like;

//@property (nonatomic, strong) NSNumber *group;
//@property (nonatomic, strong) NSNumber *ID;
//@property (nonatomic, strong) NSNumber *landscape;
//@property (nonatomic, strong) NSNumber *link;
//@property (nonatomic, strong) NSNumber *multi;
//
//@property (nonatomic, strong) NSNumber *online_users;
//@property (nonatomic, strong) NSNumber *optimal;
//@property (nonatomic, strong) NSNumber *room_id;
//@property (nonatomic, strong) NSNumber *rotate;
//@property (nonatomic, strong) NSNumber *slot;
//@property (nonatomic, strong) NSNumber *version;

+ (NSArray<YingKeLiveModel *> *)liveWithArray:(NSArray *)array;

@end

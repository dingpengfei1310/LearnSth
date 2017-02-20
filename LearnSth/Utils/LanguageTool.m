//
//  LanguageTool.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/2/20.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "LanguageTool.h"

#define LANGUAGE_SET @"langeuageset"
#define CNS @"zh-Hans"
#define EN @"en"

@interface LanguageTool ()

@property(nonatomic,strong) NSBundle *bundle;
@property (nonatomic, copy) NSString *language;

@end

@implementation LanguageTool

+ (instancetype)shareInstance {
    static LanguageTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[LanguageTool alloc] init];
    });
    
    return tool;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *tmp = [[NSUserDefaults standardUserDefaults]objectForKey:LANGUAGE_SET];
        
        //默认是中文
        if (!tmp) {
            tmp = CNS;
        }
        
        self.language = tmp;
        NSString *path = [[NSBundle mainBundle]pathForResource:self.language ofType:@"lproj"];
        self.bundle = [NSBundle bundleWithPath:path];
    }
    return self;
}

- (NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table {
    if (self.bundle) {
        return NSLocalizedStringFromTableInBundle(key, table, self.bundle, @"");
    }
    
    return NSLocalizedStringFromTable(key, table, @"");
}

- (void)changeLanguage:(NSString *)language {
    if ([language isEqualToString:self.language])
         return;
    
    if ([language isEqualToString:EN] || [language isEqualToString:CNS]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:language ofType:@"lproj"];
        self.bundle = [NSBundle bundleWithPath:path];
    }
    
    self.language = language;
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:LANGUAGE_SET];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

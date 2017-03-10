//
//  UserLocalNotification.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/10.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "UserLocalNotification.h"
#import <UserNotifications/UserNotifications.h>

@interface UserLocalNotification ()<UNUserNotificationCenterDelegate>

@end

@implementation UserLocalNotification

- (void)postNotification {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                NSLog(@"UNAuthorizationStatusNotDetermined");
                
                UNAuthorizationOptions options = UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert;
                [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * error) {
                    if (granted) {
                        [self localNotification];
                    }
                }];
                
            } else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                [self localNotification];
                
            } else {
                NSLog(@"UNAuthorizationStatusDenied");
            }
        }];
        
    } else {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
        notification.alertBody = @"闹钟响了。";
        if ([notification respondsToSelector:@selector(setAlertTitle:)]) {
            notification.alertTitle = @"请打开闹钟";
        }
        
        notification.applicationIconBadgeNumber = 1;
        
        notification.userInfo = @{@"name":@"Hello name"};
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        UIApplication *app = [UIApplication sharedApplication];
        //        app.isRegisteredForRemoteNotifications;
        
        if (app.currentUserNotificationSettings.types == 0) {
            UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
            [app registerUserNotificationSettings:setting];
            [app registerForRemoteNotifications];
        } else {
            [app scheduleLocalNotification:notification];
        }
    }
}

- (void)localNotification {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"title";
    content.subtitle = @"subtitle";
    content.body = @"body body body All rights reserved.";
    //    content.sound = [UNNotificationSound soundNamed:@"test.caf"];
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = @{@"name":@"Hello name"};
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:10 repeats:NO];
    
    //                //每周三，13点触发
    //                NSDateComponents *components = [[NSDateComponents alloc] init];
    //                components.weekday = 4; //周三
    //                components.hour = 13; //13点
    //                UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    
    //                //这个点，100米范围内，进入触发。
    //                CLLocationCoordinate2D cen = CLLocationCoordinate2DMake(39.990465,116.333386);
    //                CLRegion *region = [[CLCircularRegion alloc] initWithCenter:cen radius:100 identifier:@"center"];
    //                region.notifyOnEntry = YES;
    //                region.notifyOnExit = NO;
    //                UNLocationNotificationTrigger *trigger = [UNLocationNotificationTrigger triggerWithRegion:region repeats:YES];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"request" content:content trigger:trigger];
    
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"添加推送 ：%@",request.identifier);
    }];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"%@",notification.request.content.userInfo);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSLog(@"%@",response.notification.request.content.userInfo);
    completionHandler();
}

@end

//
//  AppDelegate.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "AppDelegate.h"

#import "AFNetworkReachabilityManager.h"
#import "RootViewController.h"
#import "UserManager.h"

#ifdef DEBUG
#import "UIViewController+Swizzled.h"
#endif

@interface AppDelegate ()
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//#ifdef DEBUG
//    SWIZZ_IT
//#endif
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    RootViewController *controller = [[RootViewController alloc] init];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    
    [self setNavigationBar];
    [self networkMonitoring];
    
    [UserManager loadUser];
    
//    application.applicationIconBadgeNumber = 0;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takeScreenshot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    
    return YES;
}

#pragma mark
- (void)setNavigationBar {
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];//设置后,UIStatusBarStyle,默认为LightContent
    [[UINavigationBar appearance] setBarTintColor:KBaseBlueColor];
//    [[UINavigationBar appearance] setBarTintColor:[UIColor clearColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont boldSystemFontOfSize:18],
                                 NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];
//    UIImage *image = [UIImage imageNamed:@"backButtonImage"];
//    UIImage *resizeableImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 42, 0, 42)];//26 42
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:resizeableImage
//                                                      forState:UIControlStateNormal
//                                                    barMetrics:UIBarMetricsDefault];
    
    UIImage *image = [UIImage imageNamed:@"backButtonImage"];
    [[UINavigationBar appearance] setBackIndicatorImage:image];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:image];
}

- (void)networkMonitoring {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            CGFloat width = [UIScreen mainScreen].bounds.size.width;
            UIView *networkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
            networkView.backgroundColor = KBaseBlueColor;
            [self.window addSubview:networkView];
            
            UILabel *networkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, width, 44)];
            networkLabel.text = @"网络已断开连接";
            networkLabel.textColor = [UIColor whiteColor];
            networkLabel.backgroundColor = [UIColor clearColor];
            networkLabel.textAlignment = NSTextAlignmentCenter;
            [networkView addSubview:networkLabel];
            
            [UIView animateWithDuration:0.5 animations:^{
                networkView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:1.5 animations:^{
                    networkView.alpha = 0.9;
                } completion:^(BOOL finished) {
                    [networkView removeFromSuperview];
                }];
            }];
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    if (self.isAutorotate) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
    if (application.statusBarOrientation <= UIInterfaceOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
        
    } else if (application.statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
        return UIInterfaceOrientationMaskLandscapeLeft;
        
    } else if (application.statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

//- (void)takeScreenshot:(NSNotification *)notification {
//    [self.window.rootViewController showSuccess:@"截图成功"];
//}

#pragma mark
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
//    [application registerForRemoteNotifications];//推送
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@",deviceToken);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%@",userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"%@",userInfo);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification {
    //8.0
    application.applicationIconBadgeNumber = 0;
    if (application.applicationState != UIApplicationStateActive) {
        NSLog(@"%@",notification.userInfo);//
        [self showAlertWithTitle:@"didReceiveLocalNotification"];
    } else {
        [self showAlertWithTitle:@"收到本地通知"];
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
    NSLog(@"%@ -- %@",identifier,notification.userInfo);
    [self showAlertWithTitle:@"handleActionWithIdentifier"];
    completionHandler();
}

- (void)showAlertWithTitle:(NSString *)title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:@"message" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

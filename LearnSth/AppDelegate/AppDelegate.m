//
//  AppDelegate.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "ShowViewController.h"

#import "HttpConnection.h"
#import "BaseConfigure.h"
#import "CustomiseTool.h"
#import "UserManager.h"
#import "FPSLabel.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    if ([CustomiseTool isFirstLaunch]) {
        ShowViewController *showVC = [[ShowViewController alloc] init];
        showVC.DismissShowBlock = ^{
            self.window.rootViewController = [[RootViewController alloc] init];
            [CustomiseTool setCurrentVersion];
        };
        self.window.rootViewController = showVC;
    } else {
        self.window.rootViewController = [[RootViewController alloc] init];
    }
    
    [self.window makeKeyAndVisible];
    
    [self setNavigationBar];
//    [self autoLoginWithToken];//自动登录
    
    return YES;
}

#pragma mark
- (void)setNavigationBar {
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];//设置后,UIStatusBarStyle,默认为LightContent
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    if ([CustomiseTool isNightModel]) {
        [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    } else {
        [[UINavigationBar appearance] setBarTintColor:KBaseAppColor];
    }
    
    UIImage *originalImage = [[UIImage imageNamed:@"backButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [[UINavigationBar appearance] setBackIndicatorImage:originalImage];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:originalImage];
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],
                                 NSForegroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-5, 0)
                                                         forBarMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}
                                                forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}
                                                forState:UIControlStateHighlighted];
    
//    FPSLabel *fpsLabel = [[FPSLabel alloc] initWithFrame:CGRectMake(Screen_W * 0.5 - 50, 0, 20, 20)];
//    [self.window addSubview:fpsLabel];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takeScreenshot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

- (void)autoLoginWithToken {
    [CustomiseTool setIsLogin:NO];
    
    if ([CustomiseTool loginToken]) {
        [[HttpConnection defaultConnection] userLoginWithTokenCompletion:^(NSDictionary *data, NSError *error) {
            if (error) {
                if (error.code == 403) {
                    [CustomiseTool setLoginToken:nil];
                }
                [CustomiseTool setIsLogin:NO];
            } else {
                [CustomiseTool setIsLogin:YES];
                [CustomiseTool setLoginToken:data[@"sessionToken"]];
                
                [[UserManager shareManager] updateUserWithDict:data];
                [UserManager cacheToDisk];
                
                [[HttpConnection defaultConnection] userResetTokenCompletion:^(NSDictionary *data, NSError *error) {
                    if (!error) {
                        [CustomiseTool setLoginToken:data[@"sessionToken"]];
                    }
                }];
            }
        }];
    }
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
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
}

#pragma mark
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [[UIApplication sharedApplication] performSelector:@selector(suspend)];//私有方法，模拟HOME键
    FFPrint(@"applicationDidEnterBackground");
//    FFPrint(@"%f",application.backgroundTimeRemaining);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    FFPrint(@"applicationWillTerminate");
}

@end

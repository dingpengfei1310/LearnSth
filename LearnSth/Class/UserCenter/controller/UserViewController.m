//
//  UserViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 16/10/10.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import "UserViewController.h"
#import "PhotoLibraryController.h"
#import "LoginViewController.h"
#import "UserInfoViewController.h"
#import "SettingViewController.h"
#import "StepCountViewController.h"

#import "HeaderImageViewCell.h"
#import "UserManager.h"

#import "AnimatedTransitioning.h"
//#import "PanInteractiveTransition.h"
#import <KVOController/KVOController.h>

@interface UserViewController ()<UITableViewDataSource,UITableViewDelegate,UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) FBKVOController *kvoController;

//@property (nonatomic, strong) PanInteractiveTransition *interactiveTransition;

@end

static NSString *HeaderIdentifier = @"headerCell";
static NSString *Identifier = @"cell";

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我";
    
    self.dataArray = @[@[@"头像"],
                       @[@"相册",@"步数"],
                       @[@"设置"]
                       ];
    CGRect frame = CGRectMake(0, 64, Screen_W, Screen_H - 113);
    if (IPHONE_X) {
        frame = CGRectMake(0, 88, Screen_W, Screen_H - 171);
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:Identifier];
    [self.tableView registerClass:[HeaderImageViewCell class] forCellReuseIdentifier:HeaderIdentifier];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;//貌似先设置代理才有效，不知道为啥
    self.tableView.layoutMargins = UIEdgeInsetsZero;//iOS10.0以上可以不用设置
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.sectionFooterHeight = 0.0;//通过代理设置无效，不知道为什么(如果只有一个section,可以不用设置)
    self.tableView.sectionHeaderHeight = 10.0;
    self.tableView.estimatedSectionHeaderHeight =0;
    self.tableView.estimatedSectionFooterHeight =0;
    [self.view addSubview:self.tableView];
    
    [self addObserve];
}

- (void)addObserve {
    _kvoController = [[FBKVOController alloc] initWithObserver:self];
    [_kvoController observe:[UserManager shareManager] keyPaths:@[@"username",@"headerUrl"] options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id observer, id object, NSDictionary<NSString *,id> * change) {
        [self reloadHeaderCell];
    }];
}

#pragma mark
- (void)loginClick {
    if ([CustomiseTool isLogin]) {
        UserInfoViewController *controller = [[UserInfoViewController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        
    } else {
        LoginViewController *controller = [[LoginViewController alloc] init];
        controller.LoginDismissBlock = ^ {
            if ([CustomiseTool isLogin]) {
                [self reloadHeaderCell];
                [self addObserve];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:controller];
        nvc.transitioningDelegate = self;
//        self.interactiveTransition = [[PanInteractiveTransition alloc] init];
//        [self.interactiveTransition setPresentingController:nvc];
        
        [self presentViewController:nvc animated:YES completion:nil];
    }
}

//刷新头像cell
- (void)reloadHeaderCell {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataArray[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        HeaderImageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HeaderIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userModel = [UserManager shareManager];
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSArray *array = self.dataArray[indexPath.section];
        cell.textLabel.text = array[indexPath.row];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setLayoutMargins:UIEdgeInsetsZero];//iOS10.0以上可以不用设置
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 1.0;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? 70 : 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [self loginClick];
        
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            PhotoLibraryController *controller = [[PhotoLibraryController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
            
//            controller.subtype = PhotoCollectionSubtypeImage;
//            controller.LibraryDismissBlock = ^{
//                [self dismissViewControllerAnimated:YES completion:nil];
//            };
//            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:controller];
//            [self presentViewController:nvc animated:YES completion:nil];
            
        } else if (indexPath.row == 1) {
            StepCountViewController *controller = [[StepCountViewController alloc] init];
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
        
    } else if (indexPath.section == 2) {
        SettingViewController *controller = [[SettingViewController alloc] init];
        controller.LogoutBlock = ^{
            [self reloadHeaderCell];
        };
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedTransitioning *transition = [[AnimatedTransitioning alloc] init];
    transition.operation = AnimatedTransitioningOperationPresent;
    return transition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    AnimatedTransitioning *transition = [[AnimatedTransitioning alloc] init];
    transition.operation = AnimatedTransitioningOperationDismiss;
    return transition;
}

//- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
//    return self.interactiveTransition.interacting ? self.interactiveTransition : nil;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

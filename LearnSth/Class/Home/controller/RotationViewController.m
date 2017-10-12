//
//  RotationViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/3/31.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "RotationViewController.h"
#import "UIViewController+PopAction.h"
#import "AppDelegate.h"

@interface RotationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;

@end

@implementation RotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"大熊猫";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSString *content = @"大熊猫的历史可谓源远流长。迄今所发现的最古老大熊猫成员——始熊猫的化石出土于中国云南禄丰和元谋两地，地质年代约为800万年前中新世晚期。在长期严酷的生存竞争和自然选择中，和它们同时代的很多动物都已灭绝，但大熊猫却是强者，处于优势，成为“活化石”保存到了今天。\n\n大熊猫的祖先是始熊猫（Ailuaractos lufengensis），大熊猫的标准中文名称其实叫“猫熊”，意即“像猫一样的熊”。这是一种由拟熊类演变而成的以食肉为主的最早的熊猫。始熊猫的主支则在中国的中部和南部继续演化，其中一种在距今约300万年的更新世初期出现，体形比熊猫小，从牙齿推断它已进化成为兼食竹类的杂食兽，卵生熊类，此后这一主支向亚热带扩展，分布广泛在华北、西北、华东、西南、华南以至越南和缅甸北部都发现了化石。在这一过程中，大熊猫适应了亚热带竹林生活，体型逐渐增大依赖竹子为生。在距今50-70万年的更新世中、晚期是大熊猫的鼎盛时期。生活中的大熊猫的臼齿发达，爪子除了五趾外还有一个“拇指”。这个“拇指”其实是一节腕骨特化形成，学名叫做“桡侧籽骨”，主要起握住竹子的作用。始熊猫在系统关系上介于祖熊和熊猫之间，是华夏大地熊猫类动物的先祖、始发期的代表。\n\n大熊猫的历史可谓源远流长。迄今所发现的最古老大熊猫成员——始熊猫的化石出土于中国云南禄丰和元谋两地，地质年代约为800万年前中新世晚期。在长期严酷的生存竞争和自然选择中，和它们同时代的很多动物都已灭绝，但大熊猫却是强者，处于优势，成为“活化石”保存到了今天。\n\n大熊猫的祖先是始熊猫（Ailuaractos lufengensis），大熊猫的标准中文名称其实叫“猫熊”，意即“像猫一样的熊”。这是一种由拟熊类演变而成的以食肉为主的最早的熊猫。始熊猫的主支则在中国的中部和南部继续演化，其中一种在距今约300万年的更新世初期出现，体形比熊猫小，从牙齿推断它已进化成为兼食竹类的杂食兽，卵生熊类，此后这一主支向亚热带扩展，分布广泛在华北、西北、华东、西南、华南以至越南和缅甸北部都发现了化石。在这一过程中，大熊猫适应了亚热带竹林生活，体型逐渐增大依赖竹子为生。在距今50-70万年的更新世中、晚期是大熊猫的鼎盛时期。生活中的大熊猫的臼齿发达，爪子除了五趾外还有一个“拇指”。这个“拇指”其实是一节腕骨特化形成，学名叫做“桡侧籽骨”，主要起握住竹子的作用。始熊猫在系统关系上介于祖熊和熊猫之间，是华夏大地熊猫类动物的先祖、始发期的代表。";
    self.introduceLabel.text = content;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.isAutorotate = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.isAutorotate = NO;
}

#pragma mark
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        //横
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    } else {
        //竖
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

#pragma mark
- (BOOL)navigationShouldPopItem {
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

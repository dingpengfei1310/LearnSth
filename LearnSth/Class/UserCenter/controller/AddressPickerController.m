//
//  AddressPickerController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/16.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "AddressPickerController.h"
#import "SQLManager.h"

@interface AddressPickerController ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, strong) NSArray *provinces;
@property (nonatomic, strong) NSArray *cities;
@property (nonatomic, strong) NSArray *areas;

@property (nonatomic, strong) UIView *pickerBackgroundView;
@property (nonatomic, strong) UIPickerView *pickerView;

@property (nonatomic, strong) NSDictionary *currentProvince;
@property (nonatomic, strong) NSDictionary *currentCity;

@end

const CGFloat PickViewHeight = 200;
const CGFloat ToolbarHeight = 40;
const CGFloat PickViewAppearDuration = 0.3;

@implementation AddressPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.currentProvince = self.provinces[0];
    self.currentCity = self.cities[0];
    
    [self.view addSubview:self.pickerBackgroundView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.pickerBackgroundView.transform = CGAffineTransformMakeTranslation(0, PickViewHeight + ToolbarHeight);
    [UIView animateWithDuration:PickViewAppearDuration animations:^{
        self.pickerBackgroundView.transform = CGAffineTransformIdentity;
        self.view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
    }];
}

#pragma mark
- (void)cancel {
    [UIView animateWithDuration:PickViewAppearDuration animations:^{
        self.pickerBackgroundView.transform = CGAffineTransformMakeTranslation(0, PickViewHeight + ToolbarHeight);
        self.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)submit {
    self.SelectBlock(self.currentProvince,self.currentCity);
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self cancel];
}

#pragma mark
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.provinces.count;
    } else if (component == 1) {
        return self.cities.count;
    } else if (component == 2) {
        return self.areas.count;
    }
    
    return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

#pragma mark
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == 0) {
        return Screen_W * 0.2;
    } else if (component == 1) {
        return Screen_W * 0.3;
    } else if (component == 2) {
        return Screen_W * 0.5;
    }
    
    return 0.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *info;
    
    switch (component) {
        case 0:
            info = self.provinces[row];
            break;
        case 1:
            info = self.cities[row];
            break;
        case 2:
            info = self.areas[row];
            break;
        default:
            return nil;
            break;
    }
    
    return info[@"name"];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (UILabel *)view;
    
    if (!label) {
        label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
    }
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.currentProvince = self.provinces[row];
        self.currentCity = self.cities[0];
        
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    } else if (component == 1) {
        
        self.currentCity = self.cities[row];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];
    }
}

#pragma mark
- (NSArray *)provinces {
    if (!_provinces) {
        _provinces = [[SQLManager manager] getProvinces];
    }
    return _provinces;
}

- (NSArray *)cities {
    _cities = [[SQLManager manager] getCitiesWithProvinceId:self.currentProvince[@"id"]];
    return _cities;
}

- (NSArray *)areas {
    _areas = [[SQLManager manager] getCitiesWithProvinceId:self.currentCity[@"id"]];
    return _areas;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, ToolbarHeight, Screen_W, PickViewHeight)];
        _pickerView.backgroundColor = KBackgroundColor;
        _pickerView.dataSource = self;
        _pickerView.delegate  = self;
    }
    return _pickerView;
}

- (UIView *)pickerBackgroundView {
    if (!_pickerBackgroundView) {
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, Screen_W, ToolbarHeight)];
        toolBar.backgroundColor = KBackgroundColor;
        [self.view addSubview:toolBar];
        
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(submit)];
        
        toolBar.items = @[cancelItem,spaceItem,submitItem];
        
        CGFloat height = PickViewHeight + ToolbarHeight;
        _pickerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, Screen_H - height, Screen_W, height)];
        [_pickerBackgroundView addSubview:toolBar];
        
        [_pickerBackgroundView addSubview:self.pickerView];
        
    }
    return _pickerBackgroundView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

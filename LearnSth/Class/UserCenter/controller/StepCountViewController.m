//
//  StepCountViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/5/11.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "StepCountViewController.h"
#import "StepCountView.h"

#import <HealthKit/HealthKit.h>

typedef NS_ENUM(NSInteger, StepCountDateType) {
    StepCountDateTypeRecent = 0,
    StepCountDateTypeWeek,
    StepCountDateTypeMonth,
    StepCountDateTypeYear,
};

@interface StepCountViewController ()

@property (nonatomic, strong) HKHealthStore *healthStore;

@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) StepCountView *stepCountView;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) StepCountDateType dateType;

@end

@implementation StepCountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.stepLabel];
    [self.view addSubview:self.stepCountView];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"最近30天",@"本年"]];
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(segmentedClick:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentedControl;
    
    self.healthStore = [[HKHealthStore alloc] init];
    [self checkAuthorize];
}

- (void)checkAuthorize {
    if (![HKHealthStore isHealthDataAvailable]) {
        [self showError:@"您的设备暂不支持此功能"];
        return;
    }
    
    HKAuthorizationStatus status = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount]];
    if (status == HKAuthorizationStatusSharingAuthorized) {
        [self getStepCount];
        
    } else if (status == HKAuthorizationStatusNotDetermined) {
        [self.healthStore requestAuthorizationToShareTypes:nil readTypes:[self dataTypesRead] completion:^(BOOL success, NSError *error) {
            [self requestAuthorization:success];
        }];
    } else if (status == HKAuthorizationStatusSharingDenied) {
        [self.healthStore requestAuthorizationToShareTypes:nil readTypes:[self dataTypesRead] completion:^(BOOL success, NSError *error) {
            [self requestAuthorization:success];
        }];
    }
}

- (void)requestAuthorization:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            [self getStepCount];
            
        } else {
            [self showError:@"您已拒绝此权限"];
        }
    });
}

#pragma mark
- (void)segmentedClick:(UISegmentedControl *)segmentedControl {
    if (segmentedControl.selectedSegmentIndex == 0) {
        _dateType = StepCountDateTypeRecent;
        
    } else if (segmentedControl.selectedSegmentIndex == 1) {
        _dateType = StepCountDateTypeYear;
        
    } else if (segmentedControl.selectedSegmentIndex == 2) {
        _dateType = StepCountDateTypeYear;
    }
    
    [self getStepCount];
}

#pragma mark
- (NSSet *)dataTypesRead {
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    return [NSSet setWithObjects:stepCountType,nil];
}

- (void)getStepCount {
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    NSPredicate *predicate = [self predicateForSamplesWithType:_dateType];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!error) {
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            
            for(HKQuantitySample *quantitySample in results) {
                HKQuantity *quantity = quantitySample.quantity;
                HKUnit *heightUnit = [HKUnit countUnit];
                double usersHeight = [quantity doubleValueForUnit:heightUnit];
                
                NSString *key = [self.dateFormatter stringFromDate:quantitySample.startDate];
                if (dictM[key]) {
                    double value = [dictM[key] doubleValue] + usersHeight;
                    [dictM setObject:@(value) forKey:key];
                } else {
                    [dictM setObject:@(usersHeight) forKey:key];
                }
            }
            
            [self handleStepResult:dictM];
        }
    }];
    
    [self.healthStore executeQuery:query];
}

- (void)handleStepResult:(NSDictionary *)dictM {
    
    NSArray *keysArray = [dictM allKeys];
    NSArray *sortedArray = [keysArray sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    NSMutableArray *arrayM = [NSMutableArray array];
    for (NSString *key in sortedArray) {
        NSString *value = dictM[key];
        [arrayM addObject:value];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (arrayM.count > 0) {
            NSString *today = [self.dateFormatter stringFromDate:[NSDate date]];
            NSString *stepCount = @"0";
            if (dictM[today]) {
                stepCount = [NSString stringWithFormat:@"%@",dictM[today]];
            }
            
            self.stepLabel.text = [NSString stringWithFormat:@" 今天共走了：%@步",stepCount];
            self.stepCountView.dataArray = arrayM;
        }
    });
}

- (NSPredicate *)predicateForSamplesWithType:(StepCountDateType)type {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond: 0];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    if (type == StepCountDateTypeRecent) {
        //最近30天
        startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-29 toDate:startDate options:0];
        
    } else if (type == StepCountDateTypeWeek) {
//        NSInteger weekday = components.weekday;
        startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-9 toDate:startDate options:0];
        
    } else if (type == StepCountDateTypeMonth) {
        NSInteger dayOfMonth = components.day;
        if (dayOfMonth < 10) {
            startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-9 toDate:startDate options:0];
        } else {
            startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-(dayOfMonth - 1) toDate:startDate options:0];
        }
        
    } else if (type == StepCountDateTypeYear) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"DD"];
        NSInteger dayOfYear = [[dateFormatter stringFromDate:now] integerValue];
        
        if (dayOfYear < 10) {
            startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-9 toDate:startDate options:0];
        } else {
            startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-(dayOfYear - 1) toDate:startDate options:0];
        }
    }
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    return predicate;
}

#pragma makr
- (StepCountView *)stepCountView {
    if (!_stepCountView) {
        _stepCountView = [[StepCountView alloc] initWithFrame:CGRectMake(0, 94, self.view.frame.size.width, self.view.frame.size.width * 0.6)];
        _stepCountView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _stepCountView;
}

- (UILabel *)stepLabel {
    if (!_stepLabel) {
        _stepLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 30)];
        _stepLabel.font = [UIFont boldSystemFontOfSize:16];
        _stepLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _stepLabel;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MMdd"];
    }
    return _dateFormatter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end

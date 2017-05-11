//
//  StepCountViewController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/5/11.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "StepCountViewController.h"

#import "LineView.h"
#import <HealthKit/HealthKit.h>

@interface StepCountViewController ()

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) LineView *lineView;

@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation StepCountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"步数";
    self.view.backgroundColor = [UIColor whiteColor];
    
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
- (NSSet *)dataTypesRead {
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    return [NSSet setWithObjects:stepCountType,nil];
}

- (void)getStepCount {
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepType predicate:[self predicateForSamplesToday] limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
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
        self.stepLabel.text = [NSString stringWithFormat:@" 今天共走了：%@步",arrayM.lastObject];
        [self.view addSubview:self.stepLabel];
        
        self.lineView.dataArray = arrayM;
        [self.view addSubview:self.lineView];
    });
}

- (NSPredicate *)predicateForSamplesToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond: 0];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-9 toDate:startDate options:0];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    return predicate;
}

#pragma makr
- (LineView *)lineView {
    if (!_lineView) {
        _lineView = [[LineView alloc] initWithFrame:CGRectMake(0, 94, Screen_W, Screen_W * 0.6)];
        _lineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _lineView;
}

- (UILabel *)stepLabel {
    if (!_stepLabel) {
        _stepLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, Screen_W, 30)];
        _stepLabel.font = [UIFont boldSystemFontOfSize:16];
        _stepLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _stepLabel;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"YYYYMMdd"];
    }
    return _dateFormatter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end

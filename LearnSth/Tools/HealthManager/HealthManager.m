//
//  HealthManager.m
//  LearnSth
//
//  Created by 丁鹏飞 on 2017/5/11.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "HealthManager.h"
#import <HealthKit/HealthKit.h>

@interface HealthManager ()

@property (nonatomic,strong) HKHealthStore *healthStore;

@end

@implementation HealthManager

+ (instancetype)shareManager {
    static HealthManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HealthManager alloc] init];
        
    });
    return manager;
}

- (void)checkAuthorize {
    if ([HKHealthStore isHealthDataAvailable]) {
        [self.healthStore requestAuthorizationToShareTypes:nil readTypes:[self dataTypesRead] completion:^(BOOL success, NSError *error) {
            
        }];
    }
    
}

- (NSSet *)dataTypesRead {
//    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
//    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
//    HKQuantityType *temperatureType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
//    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
//    HKCharacteristicType *sexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
//    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
//    HKQuantityType *distance = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
//    HKQuantityType *activeEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
//    
//    return [NSSet setWithObjects:heightType, temperatureType,birthdayType,sexType,weightType,stepCountType, distance, activeEnergyType,nil];
    
    HKQuantityType *distance = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    return [NSSet setWithObjects:stepCountType, distance,nil];
}

@end

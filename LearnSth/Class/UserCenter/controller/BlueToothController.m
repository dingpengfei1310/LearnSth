//
//  BlueToothController.m
//  LearnSth
//
//  Created by 丁鹏飞 on 17/1/18.
//  Copyright © 2017年 丁鹏飞. All rights reserved.
//

#import "BlueToothController.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface BlueToothController ()<CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *manager;

@end

@implementation BlueToothController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}

#pragma mark
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
        {
//            [_manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
            [_manager scanForPeripheralsWithServices:nil options:nil];
        }
            break;
        case CBCentralManagerStatePoweredOff:
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
//    [self.manager connectPeripheral:peripheral options:nil];
    [self.manager stopScan];
    
    NSLog(@"搜索到设备：%@ -- %@",peripheral.identifier,peripheral.name);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"搜索到设备：%@ -- %@",peripheral.identifier,peripheral.name);
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error {
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end


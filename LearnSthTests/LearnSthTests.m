//
//  LearnSthTests.m
//  LearnSthTests
//
//  Created by 丁鹏飞 on 16/9/21.
//  Copyright © 2016年 丁鹏飞. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "HomeViewController.h"

@interface LearnSthTests : XCTestCase

@property (nonatomic, strong) HomeViewController *homeVC;

@end

@implementation LearnSthTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.homeVC = [[HomeViewController alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    
    self.homeVC = nil;
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    [self.homeVC getHomeAdBanner];
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

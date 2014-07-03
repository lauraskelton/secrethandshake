//
//  IBeaconTransmitHandlerTests.m
//  SecretHandshake
//
//  Created by Laura Skelton on 7/3/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IBeaconTransmitHandler.h"

@interface IBeaconTransmitHandlerTests : XCTestCase

@end

@implementation IBeaconTransmitHandlerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSharedIBeaconTransmitHandlerExists {
    
    //+ (IBeaconTransmitHandler *)shared;
    
    // The IBeaconTransmitHandler shared should never return nil
    if ([IBeaconTransmitHandler shared]) {
        XCTAssert(YES, @"Pass");
        return;
    }
    XCTFail(@"IBeaconTransmitHandler shared does not exist");
}

- (void)testSharedIBeaconTransmitHandlerIsSingleton {
    
    //+ (IBeaconTransmitHandler *)shared;
    
    // The IBeaconTransmitHandler shared should always point to the same object
    IBeaconTransmitHandler *iBeaconTransmitHandler = [IBeaconTransmitHandler shared];
    
    IBeaconTransmitHandler *iBeaconTransmitHandlerNew = [IBeaconTransmitHandler shared];
    
    if (iBeaconTransmitHandler == iBeaconTransmitHandlerNew) {
        XCTAssert(YES, @"Pass");
        return;
    }
    XCTFail(@"IBeaconTransmitHandler shared is not a singleton");
    
}

@end

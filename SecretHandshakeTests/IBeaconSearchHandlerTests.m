//
//  IBeaconSearchHandlerTests.m
//  SecretHandshake
//
//  Created by Laura Skelton on 7/3/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IBeaconSearchHandler.h"

@interface IBeaconSearchHandlerTests : XCTestCase

@end

@implementation IBeaconSearchHandlerTests

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

- (void)testSharedIBeaconSearchHandlerExists {
    
    //+ (IBeaconSearchHandler *)shared;

    // The IBeaconSearchHandler shared should never return nil
    if ([IBeaconSearchHandler shared]) {
        XCTAssert(YES, @"Pass");
        return;
    }
    XCTFail(@"IBeaconSearchHandler shared does not exist");
}

- (void)testSharedIBeaconSearchHandlerIsSingleton {
    
    //+ (IBeaconSearchHandler *)shared;
    
    // The IBeaconSearchHandler shared should always point to the same object
    IBeaconSearchHandler *iBeaconSearchHandler = [IBeaconSearchHandler shared];
    
    IBeaconSearchHandler *iBeaconSearchHandlerNew = [IBeaconSearchHandler shared];
    
    if (iBeaconSearchHandler == iBeaconSearchHandlerNew) {
        XCTAssert(YES, @"Pass");
        return;
    }
    XCTFail(@"IBeaconSearchHandler shared is not a singleton");
    
}

@end

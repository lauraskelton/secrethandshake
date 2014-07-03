//
//  HackerSchoolAPIManagerTests.m
//  SecretHandshake
//
//  Created by Laura Skelton on 7/2/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HackerSchoolAPIManager.h"

@interface HackerSchoolAPIManagerTests : XCTestCase

@end

@implementation HackerSchoolAPIManagerTests

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

- (void)testHackerSchoolAPIManagerExists {
    
    //+ (HackerSchoolAPIManager *)sharedWithContext:(NSManagedObjectContext *)context;

    // The HackerSchoolAPIManager sharedWithContext should never return nil
    if ([HackerSchoolAPIManager sharedWithContext:nil]) {
        XCTAssert(YES, @"Pass");
        return;
    }
    XCTFail(@"HackerSchoolAPIManager shared does not exist");
}

- (void)testHackerSchoolAPIManagerIsSingleton {
    
    //+ (HackerSchoolAPIManager *)sharedWithContext:(NSManagedObjectContext *)context;
    
    // The HackerSchoolAPIManager sharedWithContext should always point to the same object
    HackerSchoolAPIManager *hackerSchoolAPIManager = [HackerSchoolAPIManager sharedWithContext:nil];
    
    HackerSchoolAPIManager *hackerSchoolAPIManagerNew = [HackerSchoolAPIManager sharedWithContext:nil];
    
    if (hackerSchoolAPIManager == hackerSchoolAPIManagerNew) {
        XCTAssert(YES, @"Pass");
        return;
    }
    XCTFail(@"HackerSchoolAPIManager sharedWithContext is not a singleton");
    
}

@end

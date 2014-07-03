//
//  FormattingHelpersTests.m
//  SecretHandshake
//
//  Created by Laura Skelton on 7/3/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FormattingHelpers.h"

@interface FormattingHelpersTests : XCTestCase

@end

@implementation FormattingHelpersTests

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

- (void)testFormatDate
{
    //+(NSString *)formatDate:(NSDate *)date

    // if the date is nil, the string should be nil
    NSString *dateString = [FormattingHelpers formatDate:nil];
    if (dateString) {
        XCTFail(@"FormattingHelpers formatDate returns non-nil string for nil date");
        return;
    }
    // if the date is not nil, the string should be not nil
    dateString = [FormattingHelpers formatDate:[NSDate date]];
    if (!dateString) {
        XCTFail(@"FormattingHelpers formatDate returns nil string for valid date");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

@end

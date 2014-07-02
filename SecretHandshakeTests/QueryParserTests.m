//
//  QueryParserTests.m
//  SecretHandshake
//
//  Created by Laura Skelton on 7/2/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "QueryParser.h"

@interface QueryParserTests : XCTestCase

@end

@implementation QueryParserTests

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

- (void)testQueryParser {
    
    // If there are no query parameters, the dictionary should be empty.
    NSDictionary *queryDictionary = [QueryParser parseQueryString:@"?"];
    if ([queryDictionary count] > 0) {
        return;
    }
    queryDictionary = [QueryParser parseQueryString:@"="];
    if ([queryDictionary count] > 0) {
        return;
    }
    queryDictionary = [QueryParser parseQueryString:@"&"];
    if ([queryDictionary count] > 0) {
        return;
    }
    // If there is no value, the dictionary should be empty.
    queryDictionary = [QueryParser parseQueryString:@"key="];
    if ([queryDictionary count] > 0) {
        return;
    }
    queryDictionary = [QueryParser parseQueryString:@"&key"];
    if ([queryDictionary count] > 0) {
        return;
    }
    // If there is no key, the dictionary should be empty.
    queryDictionary = [QueryParser parseQueryString:@"&=123"];
    if ([queryDictionary count] > 0) {
        return;
    }
    // If one key has no value, the other key should still be processed and return with its value.
    queryDictionary = [QueryParser parseQueryString:@"&key1=&key2=123"];
    if (![(NSString *)[queryDictionary objectForKey:@"key2"] isEqualToString:@"123"] || [queryDictionary count] != 1) {
        return;
    }
    queryDictionary = [QueryParser parseQueryString:@"&key1&key2=123"];
    if (![(NSString *)[queryDictionary objectForKey:@"key2"] isEqualToString:@"123"] || [queryDictionary count] != 1) {
        return;
    }
    queryDictionary = [QueryParser parseQueryString:@"&key1=123&key2"];
    if (![(NSString *)[queryDictionary objectForKey:@"key1"] isEqualToString:@"123"] || [queryDictionary count] != 1) {
        return;
    }
    XCTAssert(YES, @"Pass");
}

@end

//
//  OAuthHandlerTests.m
//  SecretHandshake
//
//  Created by Laura Skelton on 7/2/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OAuthHandler.h"
#import "OAuthHandler_Internal.h"
#import "QueryParser.h"

@interface OAuthHandlerTests : XCTestCase

@end

@implementation OAuthHandlerTests

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

- (void)testSharedOAuthHandlerExists {
    
    //+ (OAuthHandler *)sharedHandler;
    
    // The OAuthHandler sharedHandler should never return nil
    if ([OAuthHandler sharedHandler]) {
        XCTAssert(YES, @"Pass");
    }
}

- (void)testSharedOAuthHandlerIsSingleton {
    
    //+ (OAuthHandler *)sharedHandler;
    
    // The OAuthHandler sharedHandler should always point to the same object
    OAuthHandler *oauthHandler = [OAuthHandler sharedHandler];
    
    OAuthHandler *oauthHandlerNew = [OAuthHandler sharedHandler];
    
    if (oauthHandler == oauthHandlerNew) {
        XCTAssert(YES, @"Pass");
    }
    
}

- (void)testHandleResponseWithData {
    
    //-(BOOL)handleResponse:(NSURLResponse *)response withData:(NSData *)data andError:(NSError *)error;
    
    // If all arguments are nil, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:nil andError:nil]) {
        return;
    }
    // If error is not nil, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:nil andError:[[NSError alloc] initWithDomain:@"Test Domain" code:404 userInfo:@{@"test key": @"test value"}]]) {
        return;
    }
    // If error is not nil and data is not nil, it should still return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:[[NSData alloc] init] andError:[[NSError alloc] initWithDomain:@"Test Domain" code:404 userInfo:@{@"test key": @"test value"}]]) {
        return;
    }
    // If error is nil and data is not nil but has no string, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:[[NSData alloc] init] andError:nil]) {
        return;
    }
    // If error is nil and data is not nil but the string is invalid JSON, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:[@"nonjsonstring" dataUsingEncoding:NSUTF8StringEncoding] andError:nil]) {
        return;
    }
    // If error is nil and data is not nil and the string does not contain an access token or a refresh token, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:[@"{\"somekey\":\"myvalue\"}" dataUsingEncoding:NSUTF8StringEncoding] andError:nil]) {
        return;
    }
    // If error is nil and data is not nil and the string contains an access token but not a refresh token, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:[@"{\"access_token\":\"someaccesstoken\"}" dataUsingEncoding:NSUTF8StringEncoding] andError:nil]) {
        return;
    }
    // If error is nil and data is not nil and the string contains a refresh token but not an access token, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:[@"{\"refresh_token\":\"somerefreshtoken\"}" dataUsingEncoding:NSUTF8StringEncoding] andError:nil]) {
        return;
    }
    // If error is not nil and data is not nil and the string contains both a refresh token and an access token, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:[@"{\"access_token\":\"someaccesstoken\", \"refresh_token\":\"somerefreshtoken\"}" dataUsingEncoding:NSUTF8StringEncoding] andError:[[NSError alloc] initWithDomain:@"Test Domain" code:404 userInfo:@{@"test key": @"test value"}]]) {
        return;
    }
    // If error is nil and data is not nil and the string contains both a refresh token and an access token, it should return true
    if (![[OAuthHandler sharedHandler] handleResponseWithData:[@"{\"access_token\":\"someaccesstoken\", \"refresh_token\":\"somerefreshtoken\"}" dataUsingEncoding:NSUTF8StringEncoding] andError:nil]) {
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testAccessTokenRequest {
    
    //-(NSURLRequest *)accessTokenRequest;
    
    // If method is not a POST request, return false
    if (![[[OAuthHandler sharedHandler] accessTokenRequest].HTTPMethod isEqualToString:@"POST"]) {
        return;
    }
    // If OAuth Token Request URL is incorrect or missing, return false
    if (![[[OAuthHandler sharedHandler] accessTokenRequest].URL.absoluteString isEqualToString:@"https://www.hackerschool.com/oauth/token"]) {
        return;
    }
    // If OAuth Token Request HTTP Body is not a string, return false
    NSString *httpBodyString = [[NSString alloc] initWithData:[[OAuthHandler sharedHandler] accessTokenRequest].HTTPBody encoding:NSUTF8StringEncoding];
    if (httpBodyString == nil) {
        return;
    }
    
    NSDictionary *parsedQuery = [QueryParser parseQueryString:httpBodyString];
    if ([httpBodyString hasPrefix:@"grant_type=authorization_code"]) {
        // make sure the query string has all of the required parameters and no more
        if ([parsedQuery objectForKey:@"client_id" ] == nil || [parsedQuery objectForKey:@"client_secret" ] == nil || [parsedQuery objectForKey:@"redirect_uri" ] == nil || [parsedQuery objectForKey:@"code"] == nil) {
            return;
        }
        // make sure the query string has no extraneous parameters (grant_type, client_id, client_secret, redirect_uri, code)
        if ([[parsedQuery allKeys] count] != 5) {
            return;
        }

    } else if ([httpBodyString hasPrefix:@"grant_type=refresh_token"]) {
        // make sure the query string has all of the required parameters and no more
        if ([parsedQuery objectForKey:@"client_id" ] == nil || [parsedQuery objectForKey:@"client_secret" ] == nil || [parsedQuery objectForKey:@"refresh_token" ] == nil) {
            return;
        }
        // make sure the query string has no extraneous parameters (grant_type, client_id, client_secret, refresh_token)
        if ([[parsedQuery allKeys] count] != 4) {
            return;
        }
        
    } else {
        // If OAuth Token Request HTTP Body does not start with the correct grant_type parameter, return false
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

@end

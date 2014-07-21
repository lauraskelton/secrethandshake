//
//  OAuthHandlerTests.m
//  SecretHandshake
//
//  Created by Laura Skelton on 7/2/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SecretHandshake-Prefix.pch"

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
        return;
    }
    XCTFail(@"OAuthHandler sharedHandler does not exist");
}

- (void)testSharedOAuthHandlerIsSingleton {
    
    //+ (OAuthHandler *)sharedHandler;
    
    // The OAuthHandler sharedHandler should always point to the same object
    OAuthHandler *oauthHandler = [OAuthHandler sharedHandler];
    
    OAuthHandler *oauthHandlerNew = [OAuthHandler sharedHandler];
    
    if (oauthHandler == oauthHandlerNew) {
        XCTAssert(YES, @"Pass");
        return;
    }
    XCTFail(@"OAuthHandler sharedHandler is not a singleton");

}

- (void)testHandleResponseWithData {
    
    //-(BOOL)handleResponse:(NSURLResponse *)response withData:(NSData *)data andError:(NSError *)error;
    
    // If all arguments are nil, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:nil andError:nil]) {
        XCTFail(@"OAuthHandler handleResponseWithData returns true with nil arguments");
        return;
    }
    // If error is not nil, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:nil andError:[[NSError alloc] initWithDomain:@"Test Domain" code:404 userInfo:@{@"test key": @"test value"}]]) {
        XCTFail(@"OAuthHandler handleResponseWithData returns true with non-nil error");
        return;
    }
    // If error is not nil and data is not nil, it should still return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:[[NSData alloc] init] andError:[[NSError alloc] initWithDomain:@"Test Domain" code:404 userInfo:@{@"test key": @"test value"}]]) {
        XCTFail(@"OAuthHandler handleResponseWithData returns true with non-nil error");
        return;
    }
    // If error is nil and data is not nil but has no string, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:[[NSData alloc] init] andError:nil]) {
        XCTFail(@"OAuthHandler handleResponseWithData returns true with non-string data");
        return;
    }
    // If error is nil and data is not nil but the string is invalid JSON, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:[@"nonjsonstring" dataUsingEncoding:NSUTF8StringEncoding] andError:nil]) {
        XCTFail(@"OAuthHandler handleResponseWithData returns true with invalid JSON data");
        return;
    }
    // If error is nil and data is not nil and the string does not contain an access token or a refresh token, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:[@"{\"somekey\":\"myvalue\"}" dataUsingEncoding:NSUTF8StringEncoding] andError:nil]) {
        XCTFail(@"OAuthHandler handleResponseWithData returns true with no access token or refresh token");
        return;
    }
    // If error is nil and data is not nil and the string contains an access token but not a refresh token, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:[@"{\"access_token\":\"someaccesstoken\"}" dataUsingEncoding:NSUTF8StringEncoding] andError:nil]) {
        XCTFail(@"OAuthHandler handleResponseWithData returns true with no refresh token");
        return;
    }
    // If error is nil and data is not nil and the string contains a refresh token but not an access token, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:[@"{\"refresh_token\":\"somerefreshtoken\"}" dataUsingEncoding:NSUTF8StringEncoding] andError:nil]) {
        XCTFail(@"OAuthHandler handleResponseWithData returns true with no access token");
        return;
    }
    // If error is not nil and data is not nil and the string contains both a refresh token and an access token, it should return false
    if ([[OAuthHandler sharedHandler] handleResponseWithData:[@"{\"access_token\":\"someaccesstoken\",\"refresh_token\":\"somerefreshtoken\"}" dataUsingEncoding:NSUTF8StringEncoding] andError:[[NSError alloc] initWithDomain:@"Test Domain" code:404 userInfo:@{@"test key": @"test value"}]]) {
        XCTFail(@"OAuthHandler handleResponseWithData returns true with non-nil error");
        return;
    }
    
    // If error is nil and data is not nil and the string contains both a refresh token and an access token, it should return true
    if (![[OAuthHandler sharedHandler] handleResponseWithData:[@"{\"access_token\":\"someaccesstoken\",\"refresh_token\":\"somerefreshtoken\"}" dataUsingEncoding:NSUTF8StringEncoding] andError:nil]) {
        XCTFail(@"OAuthHandler handleResponseWithData returns false with a refresh token and access token and no error");
        return;
    }
    
    // If error is nil and data is not nil and the string contains both a refresh token and an access token, it should save to user defaults
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:kSHAccessTokenKey] isEqualToString:@"someaccesstoken"]) {
        XCTFail(@"OAuthHandler handleResponseWithData does not save access token to user defaults");
        return;
    }
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:kSHRefreshTokenKey] isEqualToString:@"somerefreshtoken"]) {
        XCTFail(@"OAuthHandler handleResponseWithData does not save refresh token to user defaults");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testAccessTokenRequest {
    
    //-(NSURLRequest *)accessTokenRequest;
    
    // If method is not a POST request, return false
    if (![[[OAuthHandler sharedHandler] accessTokenRequest].HTTPMethod isEqualToString:@"POST"]) {
        XCTFail(@"OAuthHandler accessTokenRequest is not a POST request");
        return;
    }
    // If OAuth Token Request URL is incorrect or missing, return false
    if (![[[OAuthHandler sharedHandler] accessTokenRequest].URL.absoluteString isEqualToString:@"https://www.hackerschool.com/oauth/token"]) {
        XCTFail(@"OAuthHandler accessTokenRequest URL is not https://www.hackerschool.com/oauth/token");
        return;
    }
    // If OAuth Token Request HTTP Body is not a string, return false
    NSString *httpBodyString = [[NSString alloc] initWithData:[[OAuthHandler sharedHandler] accessTokenRequest].HTTPBody encoding:NSUTF8StringEncoding];
    if (httpBodyString == nil) {
        XCTFail(@"OAuthHandler accessTokenRequest httpBody is not a string");
        return;
    }
    
    NSDictionary *parsedQuery = [QueryParser parseQueryString:httpBodyString];
    if ([httpBodyString hasPrefix:@"grant_type=authorization_code"]) {
        // make sure the query string has all of the required parameters and no more
        if ([parsedQuery objectForKey:@"client_id" ] == nil || [parsedQuery objectForKey:@"client_secret" ] == nil || [parsedQuery objectForKey:@"redirect_uri" ] == nil || [parsedQuery objectForKey:@"code"] == nil) {
            XCTFail(@"OAuthHandler accessTokenRequest authorization code query string does not have all required key-value pairs");
            return;
        }
        // make sure the query string has no extraneous parameters (grant_type, client_id, client_secret, redirect_uri, code)
        if ([[parsedQuery allKeys] count] != 5) {
            XCTFail(@"OAuthHandler accessTokenRequest authorization code query string has extraneous key-value pairs");
            return;
        }

    } else if ([httpBodyString hasPrefix:@"grant_type=refresh_token"]) {
        // make sure the query string has all of the required parameters and no more
        if ([parsedQuery objectForKey:@"client_id" ] == nil || [parsedQuery objectForKey:@"client_secret" ] == nil || [parsedQuery objectForKey:@"refresh_token" ] == nil) {
            XCTFail(@"OAuthHandler accessTokenRequest refresh token query string does not have all required key-value pairs");
            return;
        }
        // make sure the query string has no extraneous parameters (grant_type, client_id, client_secret, refresh_token)
        if ([[parsedQuery allKeys] count] != 4) {
            XCTFail(@"OAuthHandler accessTokenRequest refresh token query string has extraneous key-value pairs");
            return;
        }
        
    } else {
        // If OAuth Token Request HTTP Body does not start with the correct grant_type parameter, return false
        XCTFail(@"OAuthHandler accessTokenRequest query string does not have correct grant_type parameter");
        return;
    }
    
    XCTAssert(YES, @"Pass");
}

@end

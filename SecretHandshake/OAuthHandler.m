//
//  OAuthHandler.m
//  SecretHandshake
//
//  Created by Laura Skelton on 6/21/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import "SecretHandshake-Prefix.pch"

#import "OAuthHandler.h"

@interface OAuthHandler ()


@end

@implementation OAuthHandler

@synthesize delegate, authURL;

- (id)init
{
    
    // designated initializer
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)handleAuthTokenURL:(NSURL *)url
{
    // handle query here
    NSDictionary *dict = [self parseQueryString:[url query]];
    
    if ([dict objectForKey:@"error"] != nil) {
        [self.delegate oauthHandlerDidFailWithError:[dict objectForKey:@"error"]];
    } else if ([dict objectForKey:@"access_token"] != nil) {
        [self.delegate oauthHandlerDidAuthorizeWithToken:[dict objectForKey:@"access_token"]];
    } else {
        [self.delegate oauthHandlerDidFailWithError:@"Access token not found. Failed to log in to Hacker School."];
    }
    
}

- (NSDictionary *)parseQueryString:(NSString *)query
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
        elements = nil;
        key = nil;
        val = nil;
    }
    pairs = nil;
    return dict;
}

@end

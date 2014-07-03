//
//  QueryParser.m
//  SecretHandshake
//
//  Created by Laura Skelton on 7/1/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import "QueryParser.h"

@implementation QueryParser

+ (NSDictionary *)parseQueryString:(NSString *)query
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if ([elements count] == 2) {
            NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if ([key length] > 0 && [val length] > 0) {
                [dict setObject:val forKey:key];
            }
            key = nil;
            val = nil;
        }
        elements = nil;
    }
    pairs = nil;
    return dict;
}

@end

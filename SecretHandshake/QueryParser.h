//
//  QueryParser.h
//  SecretHandshake
//
//  Created by Laura Skelton on 7/1/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueryParser : NSObject

+ (NSDictionary *)parseQueryString:(NSString *)query;

@end

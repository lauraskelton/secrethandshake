//
//  QueryParserSpec.m
//  SecretHandshake
//
//  Created by Laura Skelton on 7/21/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

// Unit Tests written in Specta testing framework


#import "Specta.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "QueryParser.h"

SpecBegin(QueryParserSpec)

it(@"should return empty if there are no keys and values", ^{
    NSDictionary *queryDictionary = [QueryParser parseQueryString:@"?"];
    expect([queryDictionary count]).to.equal(0);
    
});

it(@"should return empty if there are no keys and values", ^{
    NSDictionary *queryDictionary = [QueryParser parseQueryString:@"="];
    expect([queryDictionary count]).to.equal(0);
    
});

it(@"should return empty if there are no values", ^{
    NSDictionary *queryDictionary = [QueryParser parseQueryString:@"key="];
    expect([queryDictionary count]).to.equal(0);
    
});

it(@"should return empty if there are no values", ^{
    NSDictionary *queryDictionary = [QueryParser parseQueryString:@"&key"];
    expect([queryDictionary count]).to.equal(0);
    
});

it(@"should return empty if there are no keys", ^{
    NSDictionary *queryDictionary = [QueryParser parseQueryString:@"&=123"];
    expect([queryDictionary count]).to.equal(0);
    
});

it(@"should return the complete key value pair even if an additional pair is incomplete", ^{
    NSDictionary *queryDictionary = [QueryParser parseQueryString:@"&key1=&key2=123"];
    expect([queryDictionary objectForKey:@"key2"]).to.equal(@"123");
    expect([queryDictionary count]).to.equal(1);
});

it(@"should return the complete key value pair even if an additional pair is incomplete", ^{
    NSDictionary *queryDictionary = [QueryParser parseQueryString:@"&key1&key2=123"];
    expect([queryDictionary objectForKey:@"key2"]).to.equal(@"123");
    expect([queryDictionary count]).to.equal(1);
});

it(@"should return the complete key value pair even if an additional pair is incomplete", ^{
    NSDictionary *queryDictionary = [QueryParser parseQueryString:@"&key1=123&key2"];
    expect([queryDictionary objectForKey:@"key1"]).to.equal(@"123");
    expect([queryDictionary count]).to.equal(1);
});


SpecEnd
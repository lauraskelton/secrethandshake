//
//  OCMockito - MKTClassObjectMock.m
//  Copyright 2013 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: David Hart
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTClassObjectMock.h"


@implementation MKTClassObjectMock
{
    Class _mockedClass;
}

+ (id)mockForClass:(Class)aClass
{
    return [[self alloc] initWithClass:aClass];
}

- (id)initWithClass:(Class)aClass
{
    self = [super init];
    if (self)
        _mockedClass = aClass;
    return self;
}

- (NSString *)description
{
    return [@"mock class of " stringByAppendingString:NSStringFromClass(_mockedClass)];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [_mockedClass methodSignatureForSelector:aSelector];
}


#pragma mark NSObject protocol

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [_mockedClass respondsToSelector:aSelector];
}

@end

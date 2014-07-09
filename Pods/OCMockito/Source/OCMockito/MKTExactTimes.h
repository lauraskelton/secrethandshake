//
//  OCMockito - MKTExactTimes.h
//  Copyright 2013 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import <Foundation/Foundation.h>
#import "MKTVerificationMode.h"


@interface MKTExactTimes : NSObject <MKTVerificationMode>

+ (instancetype)timesWithCount:(NSUInteger)expectedNumberOfInvocations;
- (instancetype)initWithCount:(NSUInteger)expectedNumberOfInvocations;

@end

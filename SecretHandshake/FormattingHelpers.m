//
//  FormattingHelpers.m
//  SecretHandshake
//
//  Created by Laura Skelton on 7/3/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import "FormattingHelpers.h"

@implementation FormattingHelpers

+(NSString *)formatDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [NSLocale currentLocale];
    [formatter setLocale:locale];
    [formatter setDateFormat:@"EEEE, MMMM d, h:mm a"];
    NSString *dateString = [formatter stringFromDate:date];
    formatter = nil;
    return dateString;
}

@end

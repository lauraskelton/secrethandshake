//
//  Event.m
//  SecretHandshake
//
//  Created by Laura Skelton on 6/18/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import "Event.h"
#import "HackerSchooler.h"


@implementation Event

@dynamic timestamp;
@dynamic hackerSchooler;

+(Event *) createEventWithHackerSchooler:(HackerSchooler *)hackerSchooler inManagedObjectContext:(NSManagedObjectContext *)context
{
    Event *event = nil;
        
    event = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                                   inManagedObjectContext:context];
    event.timestamp = [NSDate date];
    event.hackerSchooler = hackerSchooler;
    hackerSchooler.lastEventTime = event.timestamp;
    
    return event;
}

@end

//
//  Event.h
//  SecretHandshake
//
//  Created by Laura Skelton on 6/18/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HackerSchooler;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) HackerSchooler *hackerSchooler;

+(Event *) createEventWithHackerSchooler:(HackerSchooler *)hackerSchooler inManagedObjectContext:(NSManagedObjectContext *)context;


@end

//
//  HackerSchooler.h
//  SecretHandshake
//
//  Created by Laura Skelton on 6/18/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class HackerSchooler, Event;

@protocol HackerSchoolerDelegate <NSObject>
@optional
- (void)hackerSchoolerSavedPhoto:(HackerSchooler *)hackerSchooler forEvent:(Event *)event;
@end

@interface HackerSchooler : NSManagedObject

@property (nonatomic, weak) id <HackerSchoolerDelegate> delegate;

@property (nonatomic, retain) NSString * batch;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSNumber * savedPhoto;
@property (nonatomic, retain) NSNumber * userid;
@property (nonatomic, retain) NSDate * lastEventTime;
@property (nonatomic, retain) NSSet *events;

+(HackerSchooler *) hackerSchoolerWithUniqueUserID:(NSNumber*)uniqueUserID andFirstName:(NSString *)first_name andLastName:(NSString *)last_name andBatch:(NSString *)batch inManagedObjectContext:(NSManagedObjectContext *)context;

-(void)savePhoto:(NSData *)jpegData forEvent:(Event *)event withManagedObjectContext:(NSManagedObjectContext *)context;
- (NSString *)photoDirectoryPath;
- (NSString *)photoFilePath;
-(void)saveContext;

@end

@interface HackerSchooler (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end

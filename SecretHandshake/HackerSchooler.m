//
//  HackerSchooler.m
//  SecretHandshake
//
//  Created by Laura Skelton on 6/18/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import "HackerSchooler.h"
#import "Event.h"

static NSString *const kSHAccessTokenKey = @"LESSecretHandshakeAccessTokenStorageKey42";

@implementation HackerSchooler

@dynamic batch;
@dynamic first_name;
@dynamic last_name;
@dynamic photoURL;
@dynamic savedPhoto;
@dynamic userid;
@dynamic events;

@synthesize delegate;
@synthesize lastEventTime;

+(HackerSchooler *) hackerSchoolerWithUniqueUserID:(NSNumber*)uniqueUserID andFirstName:(NSString *)first_name andLastName:(NSString *)last_name andBatch:(NSString *)batch inManagedObjectContext:(NSManagedObjectContext *)context
{
    
    HackerSchooler *hackerSchooler = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    request.entity = [NSEntityDescription entityForName:@"HackerSchooler" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"userid = %@",uniqueUserID];
    NSError *executeFetchError= nil;
    hackerSchooler = [[context executeFetchRequest:request error:&executeFetchError] lastObject];
    
    if (executeFetchError) {
        NSLog(@"[%@, %@] error looking up hacker schooler with userid: %@ with error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), uniqueUserID, [executeFetchError localizedDescription]);
    } else if(!hackerSchooler) {
        
        hackerSchooler = [NSEntityDescription insertNewObjectForEntityForName:@"HackerSchooler"
                                                       inManagedObjectContext:context];
        
        hackerSchooler.userid = uniqueUserID;
        hackerSchooler.first_name = first_name;
        hackerSchooler.last_name = last_name;
        hackerSchooler.batch = batch;
        hackerSchooler.savedPhoto = @NO;
        
    }
    
    return hackerSchooler;
}

-(void)savePhoto:(NSData *)jpegData forEvent:(Event *)event withManagedObjectContext:(NSManagedObjectContext *)context;
{
    
    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:self.photoDirectoryPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error != nil) {
        NSLog(@"error creating profile photo directory: %@", error);
    } else {
        NSLog(@"profile photo directory path: %@", self.photoDirectoryPath);
    }
    
    error = nil;
    [jpegData writeToFile:self.photoFilePath options:NSDataWritingAtomic error:&error];
    if (error != nil) {
        NSLog(@"error writing profile photo to file: %@", error);
        error = nil;
    }
    
    jpegData = nil;
    NSLog(@"saved profile photo to filepath: %@", self.photoFilePath);
    
    self.savedPhoto = @YES;
    
    [self saveContext];
    
    [self.delegate hackerSchoolerSavedPhoto:self forEvent:event];
    
}

-(void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSString *)photoDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    paths = nil;
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"userphotos"];
    documentsPath = nil;
    return filePath;
}

- (NSString *)photoFilePath
{
    NSString *filePath = [self.photoDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@profile.jpg", self.userid]];
    return filePath;
}

@end

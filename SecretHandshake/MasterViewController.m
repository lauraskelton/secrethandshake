//
//  MasterViewController.m
//  SecretHandshake
//
//  Created by Laura Skelton on 6/18/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//
#import "SecretHandshake-Prefix.pch"

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "HackerSchooler.h"
#import "Event.h"

@interface MasterViewController ()

- (void)initBeacon;
- (IBAction)transmitBeacon:(UIButton *)sender;

@end

@implementation MasterViewController
            
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSHUserIDKey] != nil) {

        [self initBeacon];
        [self transmitBeacon:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - iBeacons

-(void)startIBeacon:(id)sender
{
    [self initBeacon];
    [self transmitBeacon:nil];
}

- (void)initBeacon
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSHUserIDKey] != nil) {

        NSLog(@"my id int value: %d", [[[NSUserDefaults standardUserDefaults] objectForKey:kSHUserIDKey] intValue]);
        
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"3ee761a0-f737-11e3-a3ac-0800200c9a66"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major:1
                                                                minor:[[[NSUserDefaults standardUserDefaults] objectForKey:kSHUserIDKey] intValue]
                                                           identifier:@"region42"];
    }
}

- (IBAction)transmitBeacon:(UIButton *)sender
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSHUserIDKey] != nil) {

        self.beaconPeripheralData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                         queue:nil
                                                                       options:nil];
    }
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Powered On");
        [self.peripheralManager startAdvertising:self.beaconPeripheralData];
    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff) {
        NSLog(@"Powered Off");
        [self.peripheralManager stopAdvertising];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Event *anEvent = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setEvent:anEvent];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HSCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Event *anEvent = [self.fetchedResultsController objectAtIndexPath:indexPath];    
    
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:2];
    titleLabel.text = [NSString stringWithFormat:@"%@ %@", anEvent.hackerSchooler.first_name, anEvent.hackerSchooler.last_name];
    
    UILabel *captionLabel = (UILabel *)[cell.contentView viewWithTag:3];
    captionLabel.text = anEvent.hackerSchooler.batch;
    
    UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:4];
    dateLabel.text = [self formatDate:anEvent.timestamp];
    
    UIImageView *profileImageView = (UIImageView *)[cell.contentView viewWithTag:1];
    if ([anEvent.hackerSchooler.savedPhoto boolValue] == YES) {
        profileImageView.image = [UIImage imageWithContentsOfFile:anEvent.hackerSchooler.photoFilePath];
    } else {
        profileImageView.image = nil;
        // download profile image
        NSURL *URL = [NSURL URLWithString:anEvent.hackerSchooler.photoURL];
        NSURLRequest *requestURL = [[NSURLRequest alloc] initWithURL:URL];
        [NSURLConnection sendAsynchronousRequest:requestURL
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if (error != nil) {
                 NSLog(@"error: %@", error);
             } else {
                 anEvent.hackerSchooler.delegate = self;
                 [anEvent.hackerSchooler savePhoto:data forEvent:anEvent withManagedObjectContext:self.managedObjectContext];
             }
         }];
        
    }

}

-(NSString *)formatDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [NSLocale currentLocale];
    [formatter setLocale:locale];
    [formatter setDateFormat:@"EEEE, MMMM d, h:mm a"];
    NSString *dateString = [formatter stringFromDate:date];
    formatter = nil;
    return dateString;
}

#pragma mark - Hacker Schooler Delegate Methods

- (void)hackerSchoolerSavedPhoto:(HackerSchooler *)hackerSchooler forEvent:(Event *)event
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:event];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

/*

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}
*/

// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 

@end

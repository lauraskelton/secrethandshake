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

#import "FormattingHelpers.h"

@interface MasterViewController ()

@end

@implementation MasterViewController
            
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSHUserIDKey] != nil) {

        //[self initBeacon];
        //[self transmitBeacon:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    dateLabel.text = [FormattingHelpers formatDate:anEvent.timestamp];
    
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 

@end

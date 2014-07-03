//
//  DetailViewController.m
//  SecretHandshake
//
//  Created by Laura Skelton on 6/18/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import "DetailViewController.h"
#import "Event.h"
#import "HackerSchooler.h"

@interface DetailViewController ()
            

@end

@implementation DetailViewController
            
#pragma mark - Managing the detail item

- (void)setEvent:(Event *)newEvent {
    if (_event != newEvent) {
        _event = newEvent;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.event) {
        nameLabel.text = [NSString stringWithFormat:@"%@ %@",self.event.hackerSchooler.first_name, self.event.hackerSchooler.last_name];
        batchLabel.text = self.event.hackerSchooler.batch;
        profileImageView.image = [UIImage imageWithContentsOfFile:self.event.hackerSchooler.photoFilePath];

    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  DetailViewController.h
//  SecretHandshake
//
//  Created by Laura Skelton on 6/18/14.
//  Copyright (c) 2014 Laura Skelton. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;

@interface DetailViewController : UIViewController
{
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *batchLabel;
    IBOutlet UIImageView *profileImageView;
}

@property (strong, nonatomic) Event * event;

@end


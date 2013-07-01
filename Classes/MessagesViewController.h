//
//  MessagesViewController.h
//  EVEUniverse
//
//  Created by Mr. Depth on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterViewController.h"
#import "EUFilter.h"

@class EUMailBox;
@interface MessagesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *messagesTableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet FilterViewController *filterViewController;
@property (nonatomic, strong) IBOutlet UINavigationController *filterNavigationViewController;
@property (nonatomic, strong) UIPopoverController *filterPopoverController;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

- (IBAction)markAsRead:(id)sender;

@end

//
//  CertificatesViewController.h
//  EVEUniverse
//
//  Created by Mr. Depth on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EVEDBCrtCategory;
@interface CertificatesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView* certificatesTableView;
@property (nonatomic, strong) EVEDBCrtCategory* category;

@end

//
//  SkillPlannerViewController.h
//  EVEUniverse
//
//  Created by Mr. Depth on 1/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SkillPlannerImportViewController.h"

@class SkillPlan;
@interface SkillPlannerViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, SkillPlannerImportViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UITableView* skillsTableView;
@property (weak, nonatomic) IBOutlet UILabel *trainingTimeLabel;

@end

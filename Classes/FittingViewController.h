//
//  FittingViewController.h
//  EVEUniverse
//
//  Created by Artem Shimanski on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModulesViewController.h"
#import "DronesViewController.h"
#import "ImplantsViewController.h"
#import "StatsViewController.h"
#import "FleetViewController.h"
#import "BrowserViewController.h"
#import "FittingSection.h"
#import "AreaEffectsViewController.h"
#import "CharactersViewController.h"
#import "DamagePatternsViewController.h"
#import "FitsViewController.h"
#import "TargetsViewController.h"
#import "FittingVariationsViewController.h"

#import "eufe.h"

@class EVEFittingFit;
@class ShipFit;
@class DamagePattern;
@class PriceManager;
@interface FittingViewController : UIViewController<UIActionSheetDelegate,
													UITextFieldDelegate,
													BrowserViewControllerDelegate,
													AreaEffectsViewControllerDelegate,
													CharactersViewControllerDelegate,
													DamagePatternsViewControllerDelegate,
													FitsViewControllerDelegate,
													TargetsViewControllerDelegate,
													MFMailComposeViewControllerDelegate,
													FittingVariationsViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIView *sectionsView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *sectionSegmentControl;
@property (nonatomic, retain) IBOutlet UINavigationController *modalController;
@property (nonatomic, retain) IBOutlet UINavigationController *targetsModalController;
@property (nonatomic, retain) IBOutlet UINavigationController *areaEffectsModalController;
@property (nonatomic, retain) IBOutlet TargetsViewController* targetsViewController;
@property (nonatomic, retain) IBOutlet AreaEffectsViewController* areaEffectsViewController;
@property (nonatomic, retain) IBOutlet ModulesViewController *modulesViewController;
@property (nonatomic, retain) IBOutlet DronesViewController *dronesViewController;
@property (nonatomic, retain) IBOutlet ImplantsViewController *implantsViewController;
@property (nonatomic, retain) IBOutlet StatsViewController *statsViewController;
@property (nonatomic, retain) IBOutlet FleetViewController *fleetViewController;

@property (nonatomic, retain) IBOutlet UIView *shadeView;
@property (nonatomic, retain) IBOutlet UIToolbar *fitNameView;
@property (nonatomic, retain) IBOutlet UITextField *fitNameTextField;
@property (nonatomic, retain) IBOutlet UIView *statsSectionView;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UIPopoverController *targetsPopoverController;
@property (nonatomic, retain) UIPopoverController *areaEffectsPopoverController;
@property (nonatomic, retain) UIPopoverController *variationsPopoverController;

@property (nonatomic, retain) ShipFit* fit;

@property (nonatomic, readonly) eufe::Engine* fittingEngine;
@property (nonatomic, retain, readonly) NSMutableArray* fits;
@property (nonatomic, retain) DamagePattern* damagePattern;
@property (nonatomic, retain) PriceManager* priceManager;

- (IBAction) didCloseModalViewController:(id) sender;
- (IBAction) didChangeSection:(id) sender;
- (IBAction) onMenu:(id) sender;
- (IBAction) onDone:(id) sender;
- (IBAction) onBack:(id) sender;
- (void) update;
- (void) addFleetMember;
- (void) selectCharacterForFit:(ShipFit*) fit;

@end

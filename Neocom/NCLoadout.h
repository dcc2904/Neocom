//
//  NCLoadout.h
//  Neocom
//
//  Created by Shimanski Artem on 30.01.14.
//  Copyright (c) 2014 Artem Shimanski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NCLoadoutData.h"
#import "NCStorage.h"

typedef NS_ENUM(NSInteger, NCLoadoutCategory) {
	NCLoadoutCategoryShip,
	NCLoadoutCategoryPOS
};

@class NCDBInvType;

@interface NCLoadout : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic) int32_t typeID;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NCLoadoutData *data;

@property (nonatomic, readonly, strong) NCDBInvType* type;
@property (nonatomic, readonly) NCLoadoutCategory category;


@end

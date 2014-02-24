//
//  NCKillMail.m
//  Neocom
//
//  Created by Артем Шиманский on 21.02.14.
//  Copyright (c) 2014 Artem Shimanski. All rights reserved.
//

#import "NCKillMail.h"
#import "EVEOnlineAPI.h"
#import "EVEKillLogKill+Neocom.h"
#import "EVEKillLogVictim+Neocom.h"

@implementation NCKillMailPilot

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		self.allianceID = [aDecoder decodeIntegerForKey:@"allianceID"];
		self.allianceName = [aDecoder decodeObjectForKey:@"allianceName"];
		self.characterID = [aDecoder decodeIntegerForKey:@"characterID"];
		self.characterName = [aDecoder decodeObjectForKey:@"characterName"];
		self.corporationID = [aDecoder decodeIntegerForKey:@"corporationID"];
		self.corporationName = [aDecoder decodeObjectForKey:@"corporationName"];
		self.shipType = [EVEDBInvType invTypeWithTypeID:[aDecoder decodeIntegerForKey:@"shipTypeID"] error:nil];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeInteger:self.allianceID forKey:@"allianceID"];
	[aCoder encodeInteger:self.characterID forKey:@"characterID"];
	[aCoder encodeInteger:self.corporationID forKey:@"corporationID"];
	if (self.allianceName)
		[aCoder encodeObject:self.allianceName forKey:@"allianceName"];
	if (self.characterName)
		[aCoder encodeObject:self.allianceName forKey:@"characterName"];
	if (self.corporationName)
		[aCoder encodeObject:self.allianceName forKey:@"corporationName"];
	if (self.shipType)
		[aCoder encodeInteger:self.shipType.typeID forKey:@"shipTypeID"];

}

@end

@implementation NCKillMailVictim

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.damageTaken = [aDecoder decodeIntegerForKey:@"damageTaken"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeInteger:self.damageTaken forKey:@"damageTaken"];
}

@end

@implementation NCKillMailAttacker

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.securityStatus = [aDecoder decodeFloatForKey:@"securityStatus"];
		self.damageDone = [aDecoder decodeIntegerForKey:@"damageDone"];
		self.finalBlow = [aDecoder decodeBoolForKey:@"finalBlow"];
		self.weaponType = [EVEDBInvType invTypeWithTypeID:[aDecoder decodeIntegerForKey:@"weaponTypeID"] error:nil];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeFloat:self.securityStatus forKey:@"securityStatus"];
	[aCoder encodeInteger:self.damageDone forKey:@"damageDone"];
	[aCoder encodeBool:self.finalBlow forKey:@"finalBlow"];
	if (self.weaponType)
		[aCoder encodeInteger:self.weaponType.typeID forKey:@"weaponTypeID"];
}

@end

@implementation NCKillMailItem

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		self.destroyed = [aDecoder decodeBoolForKey:@"destroyed"];
		self.qty = [aDecoder decodeIntegerForKey:@"qty"];
		self.type = [EVEDBInvType invTypeWithTypeID:[aDecoder decodeIntegerForKey:@"typeID"] error:nil];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeBool:self.destroyed forKey:@"destroyed"];
	[aCoder encodeInteger:self.qty forKey:@"qty"];
	if (self.type)
		[aCoder encodeInteger:self.type.typeID forKey:@"typeID"];
	
}

@end

@implementation NCKillMail

- (id) initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		self.hiSlots = [aDecoder decodeObjectForKey:@"hiSlots"];
		self.medSlots = [aDecoder decodeObjectForKey:@"medSlots"];
		self.lowSlots = [aDecoder decodeObjectForKey:@"lowSlots"];
		self.rigSlots = [aDecoder decodeObjectForKey:@"rigSlots"];
		self.subsystemSlots = [aDecoder decodeObjectForKey:@"subsystemSlots"];
		self.droneBay = [aDecoder decodeObjectForKey:@"droneBay"];
		self.cargo = [aDecoder decodeObjectForKey:@"cargo"];
		self.attackers = [aDecoder decodeObjectForKey:@"attackers"];
		self.victim = [aDecoder decodeObjectForKey:@"victim"];
		self.solarSystem = [EVEDBMapSolarSystem mapSolarSystemWithSolarSystemID:[aDecoder decodeIntegerForKey:@"solarSystemID"] error:nil];
		self.killTime = [aDecoder decodeObjectForKey:@"killTime"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
	if (self.hiSlots)
		[aCoder encodeObject:self.hiSlots forKey:@"hiSlots"];
	if (self.medSlots)
		[aCoder encodeObject:self.medSlots forKey:@"medSlots"];
	if (self.lowSlots)
		[aCoder encodeObject:self.lowSlots forKey:@"lowSlots"];
	if (self.rigSlots)
		[aCoder encodeObject:self.rigSlots forKey:@"rigSlots"];
	if (self.subsystemSlots)
		[aCoder encodeObject:self.subsystemSlots forKey:@"subsystemSlots"];
	if (self.droneBay)
		[aCoder encodeObject:self.droneBay forKey:@"droneBay"];
	if (self.cargo)
		[aCoder encodeObject:self.cargo forKey:@"cargo"];
	if (self.attackers)
		[aCoder encodeObject:self.attackers forKey:@"attackers"];
	if (self.victim)
		[aCoder encodeObject:self.victim forKey:@"victim"];
	if (self.solarSystem)
		[aCoder encodeInteger:self.solarSystem.solarSystemID forKey:@"solarSystemID"];
	if (self.killTime)
		[aCoder encodeObject:self.killTime forKey:@"killTime"];
	
}

- (id) initWithKillLogKill:(EVEKillLogKill*) kill {
	if (self = [super init]) {
		self.victim = [NCKillMailVictim new];
		self.victim.characterName = kill.victim.characterName;
		self.victim.characterID = kill.victim.characterID;
		self.victim.corporationName = kill.victim.corporationName;
		self.victim.corporationID = kill.victim.corporationID;
		self.victim.allianceName = kill.victim.allianceName;
		self.victim.allianceID = kill.victim.allianceID;
		self.victim.shipType =  kill.victim.shipType;
		self.victim.damageTaken = kill.victim.damageTaken;

		self.solarSystem = kill.solarSystem;
		self.killTime = kill.killTime;
		
		NSMutableArray* hiSlots = [NSMutableArray new];
		NSMutableArray* medSlots = [NSMutableArray new];
		NSMutableArray* lowSlots = [NSMutableArray new];
		NSMutableArray* rigSlots = [NSMutableArray new];
		NSMutableArray* subsystems = [NSMutableArray new];
		NSMutableArray* drones = [NSMutableArray new];
		NSMutableArray* cargo = [NSMutableArray new];
		
		for (EVEKillLogItem* item in kill.items) {
			if (item.flag >= EVEInventoryFlagHiSlot0 && item.flag <= EVEInventoryFlagHiSlot7) {
				if (item.qtyDestroyed) {
					NCKillMailItem* module = [NCKillMailItem new];
					module.type = [EVEDBInvType invTypeWithTypeID:item.typeID error:nil];
					module.qty = item.qtyDestroyed;
					module.destroyed = YES;
					[hiSlots addObject:module];
				}
				if (item.qtyDropped) {
					NCKillMailItem* module = [NCKillMailItem new];
					module.type = [EVEDBInvType invTypeWithTypeID:item.typeID error:nil];
					module.qty = item.qtyDropped;
					module.destroyed = NO;
					[hiSlots addObject:module];
				}
			}
			else if (item.flag >= EVEInventoryFlagMedSlot0 && item.flag <= EVEInventoryFlagMedSlot7) {
				if (item.qtyDestroyed) {
					NCKillMailItem* module = [NCKillMailItem new];
					module.type = [EVEDBInvType invTypeWithTypeID:item.typeID error:nil];
					module.qty = item.qtyDestroyed;
					module.destroyed = YES;
					[medSlots addObject:module];
				}
				if (item.qtyDropped) {
					NCKillMailItem* module = [NCKillMailItem new];
					module.type = [EVEDBInvType invTypeWithTypeID:item.typeID error:nil];
					module.qty = item.qtyDropped;
					module.destroyed = NO;
					[medSlots addObject:module];
				}
			}
			else if (item.flag >= EVEInventoryFlagLoSlot0 && item.flag <= EVEInventoryFlagLoSlot7) {
				if (item.qtyDestroyed) {
					NCKillMailItem* module = [NCKillMailItem new];
					module.type = [EVEDBInvType invTypeWithTypeID:item.typeID error:nil];
					module.qty = item.qtyDestroyed;
					module.destroyed = YES;
					[lowSlots addObject:module];
				}
				if (item.qtyDropped) {
					NCKillMailItem* module = [NCKillMailItem new];
					module.type = [EVEDBInvType invTypeWithTypeID:item.typeID error:nil];
					module.qty = item.qtyDropped;
					module.destroyed = NO;
					[lowSlots addObject:module];
				}
			}
			else if (item.flag >= EVEInventoryFlagRigSlot0 && item.flag <= EVEInventoryFlagRigSlot7) {
				if (item.qtyDestroyed) {
					NCKillMailItem* module = [NCKillMailItem new];
					module.type = [EVEDBInvType invTypeWithTypeID:item.typeID error:nil];
					module.qty = item.qtyDestroyed;
					module.destroyed = YES;
					[rigSlots addObject:module];
				}
				if (item.qtyDropped) {
					NCKillMailItem* module = [NCKillMailItem new];
					module.type = [EVEDBInvType invTypeWithTypeID:item.typeID error:nil];
					module.qty = item.qtyDropped;
					module.destroyed = NO;
					[rigSlots addObject:module];
				}
			}
			else if (item.flag >= EVEInventoryFlagSubSystem0 && item.flag <= EVEInventoryFlagSubSystem7) {
				if (item.qtyDestroyed) {
					NCKillMailItem* module = [NCKillMailItem new];
					module.type = [EVEDBInvType invTypeWithTypeID:item.typeID error:nil];
					module.qty = item.qtyDestroyed;
					module.destroyed = YES;
					[subsystems addObject:module];
				}
				if (item.qtyDropped) {
					NCKillMailItem* module = [NCKillMailItem new];
					module.type = [EVEDBInvType invTypeWithTypeID:item.typeID error:nil];
					module.qty = item.qtyDropped;
					module.destroyed = NO;
					[subsystems addObject:module];
				}
			}
			else if (item.flag == EVEInventoryFlagDroneBay) {
				if (item.qtyDestroyed) {
					NCKillMailItem* drone = [NCKillMailItem new];
					drone.type = [EVEDBInvType invTypeWithTypeID:item.typeID error:nil];
					drone.qty = item.qtyDestroyed;
					drone.destroyed = YES;
					[drones addObject:drone];
				}
				if (item.qtyDropped) {
					NCKillMailItem* drone = [NCKillMailItem new];
					drone.type = [EVEDBInvType invTypeWithTypeID:item.typeID error:nil];
					drone.qty = item.qtyDropped;
					drone.destroyed = NO;
					[drones addObject:drone];
				}
			}
			else {
				if (item.qtyDestroyed) {
					NCKillMailItem* cargoItem = [NCKillMailItem new];
					cargoItem.type = [EVEDBInvType invTypeWithTypeID:item.typeID error:nil];
					cargoItem.qty = item.qtyDestroyed;
					cargoItem.destroyed = YES;
					[cargo addObject:cargoItem];
				}
				if (item.qtyDropped) {
					NCKillMailItem* cargoItem = [NCKillMailItem new];
					cargoItem.type = [EVEDBInvType invTypeWithTypeID:item.typeID error:nil];
					cargoItem.qty = item.qtyDropped;
					cargoItem.destroyed = NO;
					[cargo addObject:cargoItem];
				}
			}
		}
		self.hiSlots = hiSlots;
		self.medSlots = medSlots;
		self.lowSlots = lowSlots;
		self.rigSlots = rigSlots;
		self.subsystemSlots = subsystems;
		self.droneBay = drones;
		self.cargo = cargo;
		
		NSMutableArray* attackers = [NSMutableArray new];
		for (EVEKillLogAttacker* item in kill.attackers) {
			NCKillMailAttacker* attacker = [NCKillMailAttacker new];
			attacker.characterName = item.characterName;
			attacker.characterID = item.characterID;
			attacker.corporationName = item.corporationName;
			attacker.corporationID = item.corporationID;
			attacker.allianceName = item.allianceName;
			attacker.allianceID = item.allianceID;
			attacker.shipType = [EVEDBInvType invTypeWithTypeID:item.shipTypeID error:nil];
			attacker.weaponType = [EVEDBInvType invTypeWithTypeID:item.weaponTypeID error:nil];
			attacker.securityStatus = item.securityStatus;
			attacker.damageDone = item.damageDone;
			attacker.finalBlow = item.finalBlow;
			[attackers addObject:attacker];
		}
		[attackers sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"finalBlow" ascending:NO],
										  [NSSortDescriptor sortDescriptorWithKey:@"damageDone" ascending:NO]]];
		self.attackers = attackers;
	}
	return self;
}

- (id) initWithKillNetLogEntry:(EVEKillNetLogEntry*) kill {
	if (self = [super init]) {
	}
	return self;
}

@end
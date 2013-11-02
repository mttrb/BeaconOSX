//
//  BLCAppDelegate.m
//  BeaconOSX
//
//  Created by Matthew Robinson on 1/11/2013.
//  Copyright (c) 2013 Blended Cocoa. All rights reserved.
//

#import "BLCAppDelegate.h"

#import <IOBluetooth/IOBluetooth.h>

#import "BLCBeaconAdvertisementData.h"

@interface BLCAppDelegate () <CBPeripheralManagerDelegate>

@property (nonatomic,strong) CBPeripheralManager *manager;

@end

@implementation BLCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    _manager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                       queue:nil];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        
        NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"A6C4C5FA-A8DD-4BA1-B9A8-A240584F02D3"];
        
        BLCBeaconAdvertisementData *beaconData = [[BLCBeaconAdvertisementData alloc] initWithProximityUUID:proximityUUID
                                                                                                     major:5
                                                                                                     minor:5000
                                                                                             measuredPower:-59];

        
        [_manager startAdvertising:beaconData.beaconAdvertisement];
    }
}

@end

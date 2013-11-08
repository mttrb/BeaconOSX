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

@interface BLCAppDelegate () <CBPeripheralManagerDelegate, NSTextFieldDelegate>

@property (nonatomic,strong) CBPeripheralManager *manager;

@property (weak) IBOutlet NSButton  *startbutton;
@property (weak) IBOutlet NSTextField *uuidTextField;
@property (weak) IBOutlet NSTextField *majorValueTextField;
@property (weak) IBOutlet NSTextField *minorValueTextField;
@property (weak) IBOutlet NSTextField *measuredPowerTextField;

- (IBAction)startButtonTapped:(NSButton*)advertisingButton;

@end

@implementation BLCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    _manager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                       queue:nil];
    [self.startbutton setEnabled:NO];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        [self.startbutton setEnabled:YES];
        [self.uuidTextField setEnabled:YES];
        [self.majorValueTextField setEnabled:YES];
        [self.minorValueTextField setEnabled:YES];
        [self.measuredPowerTextField setEnabled:YES];
        
        [self.startbutton setTarget:self];
        [self.startbutton setAction:@selector(startButtonTapped:)];
        
        self.uuidTextField.delegate = self;
    }
}

- (IBAction)startButtonTapped:(NSButton*)advertisingButton{
    if (_manager.isAdvertising) {
        [_manager stopAdvertising];
        [advertisingButton setTitle:@"startAdvertising"];
        [self.uuidTextField setEnabled:YES];
        [self.majorValueTextField setEnabled:YES];
        [self.minorValueTextField setEnabled:YES];
        [self.measuredPowerTextField setEnabled:YES];
    } else {
        NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:[self.uuidTextField stringValue]];
        
        BLCBeaconAdvertisementData *beaconData = [[BLCBeaconAdvertisementData alloc] initWithProximityUUID:proximityUUID
                                                                                                     major:self.majorValueTextField.integerValue
                                                                                                     minor:self.minorValueTextField.integerValue
                                                                                             measuredPower:self.measuredPowerTextField.integerValue];
        
        
        [_manager startAdvertising:beaconData.beaconAdvertisement];
        [self.uuidTextField setEnabled:NO];
        [self.majorValueTextField setEnabled:NO];
        [self.minorValueTextField setEnabled:NO];
        [self.measuredPowerTextField setEnabled:NO];

        [advertisingButton setTitle:@"stop advertising"];
    }
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    
    
    return YES;
}

@end

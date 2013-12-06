//
//  Copyright (c) 2013, Matthew Robinson
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this
//     list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//
//  3. Neither the name of Blended Cocoa nor the names of its contributors may
//     be used to endorse or promote products derived from this software without
//     specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//
//
//  BLCAppDelegate.m
//  BeaconOSX
//
//  Created by Matthew Robinson on 1/11/2013.
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

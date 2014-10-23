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

static NSString *kBLCUserDefaultsUDID = @"kBLCUserDefaultsUDID";
static NSString *kBLCUserDefaultsMajor = @"kBLCUserDefaultsMajor";
static NSString *kBLCUserDefaultsMinor = @"kBLCUserDefaultsMinor";
static NSString *kBLCUserDefaultsMeasuredPower = @"kBLCUserDefaultsMeasuredPower";

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
    
	if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]){
        NSInteger major =  [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion;
        NSInteger minor =  [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
        if (major == 10 && minor == 10) {
            NSAlert* alert = [NSAlert alertWithMessageText:@"Unsupported OS" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You are running a version of OSX that does not support the iBeacon feature."];
            [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
                exit(-1);
            }];
        }
    }

    [self loadLastUsedData];
}

- (void)loadLastUsedData {
    NSString *udid = [[NSUserDefaults standardUserDefaults] stringForKey:kBLCUserDefaultsUDID];
    if (udid) {
        [self.uuidTextField setStringValue:udid];
    }
    
    NSString *major = [[NSUserDefaults standardUserDefaults] stringForKey:kBLCUserDefaultsMajor];
    if (major) {
        [self.majorValueTextField setStringValue:major];
    }
    
    NSString *minor = [[NSUserDefaults standardUserDefaults] stringForKey:kBLCUserDefaultsMinor];
    if (minor) {
        [self.minorValueTextField setStringValue:minor];
    }
    
    NSString *measuredPower = [[NSUserDefaults standardUserDefaults] stringForKey:kBLCUserDefaultsMeasuredPower];
    if (measuredPower) {
        [self.measuredPowerTextField setStringValue:measuredPower];
    }
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
        
        [[NSUserDefaults standardUserDefaults] setObject:[self.uuidTextField stringValue] forKey:kBLCUserDefaultsUDID];
        [[NSUserDefaults standardUserDefaults] setObject:[self.majorValueTextField stringValue] forKey:kBLCUserDefaultsMajor];
        [[NSUserDefaults standardUserDefaults] setObject:[self.minorValueTextField stringValue] forKey:kBLCUserDefaultsMinor];
        [[NSUserDefaults standardUserDefaults] setObject:[self.measuredPowerTextField stringValue] forKey:kBLCUserDefaultsMeasuredPower];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        BLCBeaconAdvertisementData *beaconData = [[BLCBeaconAdvertisementData alloc] initWithProximityUUID:proximityUUID
                                                                                                     major:self.majorValueTextField.integerValue
                                                                                                     minor:self.minorValueTextField.integerValue
                                                                                             measuredPower:self.measuredPowerTextField.integerValue];
        
        
        [_manager startAdvertising:beaconData.beaconAdvertisement];
        [self.uuidTextField setEnabled:NO];
        [self.majorValueTextField setEnabled:NO];
        [self.minorValueTextField setEnabled:NO];
        [self.measuredPowerTextField setEnabled:NO];

        [advertisingButton setTitle:@"Stop Broadcasting"];
    }
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor{
    
    
    return YES;
}

@end

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
//  BLCBeaconAdvertisementData.m
//  BeaconOSX
//
//  Created by Matthew Robinson on 1/11/2013.
//

#import "BLCBeaconAdvertisementData.h"

@implementation BLCBeaconAdvertisementData

- (id)initWithProximityUUID:(NSUUID *)proximityUUID major:(uint16_t)major minor:(uint16_t)minor measuredPower:(int8_t)power {
    self = [super init];
    
    if (self) {
        self.proximityUUID = proximityUUID;
        self.major = major;
        self.minor = minor;
        self.measuredPower = power;
    }

    return self;
}


- (NSDictionary *)beaconAdvertisement {
    NSString *beaconKey = @"kCBAdvDataAppleBeaconKey";
    
    unsigned char advertisementBytes[21] = {0};
    
    [self.proximityUUID getUUIDBytes:(unsigned char *)&advertisementBytes];
    
    advertisementBytes[16] = (unsigned char)(self.major >> 8);
    advertisementBytes[17] = (unsigned char)(self.major & 255);
    
    advertisementBytes[18] = (unsigned char)(self.minor >> 8);
    advertisementBytes[19] = (unsigned char)(self.minor & 255);
    
    advertisementBytes[20] = self.measuredPower;
    
    NSMutableData *advertisement = [NSMutableData dataWithBytes:advertisementBytes length:21];
    
    return [NSDictionary dictionaryWithObject:advertisement forKey:beaconKey];
}

@end

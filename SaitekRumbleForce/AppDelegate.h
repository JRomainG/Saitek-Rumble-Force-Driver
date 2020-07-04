//
//  AppDelegate.h
//  SaitekRumbleForce
//
//  Created by Jean-Romain on 06/11/2019.
//  Copyright © 2019 JustKodding. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <IOKit/hid/IOHIDManager.h>
#import "IOHIDDevice.h"
#import "ViewController.h"

static NSMutableDictionary *devices;

@interface AppDelegate : NSObject <NSApplicationDelegate>

// USB device added callback function
static void Handle_DeviceMatchingCallback(void *inContext,
                                          IOReturn inResult,
                                          void *inSender,
                                          IOHIDDeviceRef inIOHIDDeviceRef);

// USB device removed callback function
static void Handle_DeviceRemovalCallback(void *inContext,
                                         IOReturn inResult,
                                         void *inSender,
                                         IOHIDDeviceRef inIOHIDDeviceRef);

// USB device data callback function
static void Handle_IOHIDDeviceInputReportCallback(void *inContext,
                                                  IOReturn inResult,
                                                  void *inSender,
                                                  IOHIDReportType inType,
                                                  uint32_t inReportID,
                                                  uint8_t *inReport,
                                                  CFIndex inReportLength);

// Counts the number of devices in the device set (includes all USB devices that match our dictionary)
static long USBDeviceCount(IOHIDManagerRef HIDManager);

@end

//
//  AppDelegate.m
//  SaitekRumbleForce
//
//  Created by Jean-Romain on 06/11/2019.
//  Copyright © 2019 JustKodding. All rights reserved.
//

#import "AppDelegate.h"
#import "IOKit/hid/IOHIDManager.h"
#import "IOKit/hid/IOHIDKeys.h"
#include <stdio.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    devices = [NSMutableDictionary new];

    // Create an HID Manager
    IOHIDManagerRef HIDManager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);

    // Create a Matching Dictionary
    CFMutableDictionaryRef matchDict = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                                 2,
                                                                 &kCFTypeDictionaryKeyCallBacks,
                                                                 &kCFTypeDictionaryValueCallBacks);

    // Specify a device manufacturer and product name in the Matching Dictionary
    CFDictionarySetValue(matchDict, CFSTR(kIOHIDManufacturerKey), CFSTR("Saitek PLC"));
    long productID = 24333; // Saitek P2600 Rumble Force Pad
    CFNumberRef vendorIDCFNumRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &productID);
    CFDictionarySetValue(matchDict, CFSTR(kIOHIDProductIDKey), vendorIDCFNumRef);

    // Register the Matching Dictionary to the HID Manager
    IOHIDManagerSetDeviceMatching(HIDManager, matchDict);
    
    // Register a callback for USB device detection with the HID Manager
    IOHIDManagerRegisterDeviceMatchingCallback(HIDManager, &Handle_DeviceMatchingCallback, NULL);
    IOHIDManagerRegisterDeviceRemovalCallback(HIDManager, &Handle_DeviceRemovalCallback, NULL);

    // Add the HID manager to the main run loop (or the callback functions won't be called)
    IOHIDManagerScheduleWithRunLoop(HIDManager, CFRunLoopGetMain(), kCFRunLoopDefaultMode);

    // Open the HID Manager
    IOReturn IOReturn = IOHIDManagerOpen(HIDManager, kIOHIDOptionsTypeNone);
    if (IOReturn) {
        NSLog(@"IOHIDManagerOpen failed.");
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


// New USB device specified in the matching dictionary has been added (callback function)
static void Handle_DeviceMatchingCallback(void *inContext,
                                          IOReturn inResult,
                                          void *inSender,
                                          IOHIDDeviceRef inIOHIDDeviceRef) {

    // Try to retrieve device name and product ID
    CFTypeRef _Nullable devNamePtr = IOHIDDeviceGetProperty(inIOHIDDeviceRef, CFSTR(kIOHIDProductKey));
    NSString *devName = [NSString stringWithUTF8String:CFStringGetCStringPtr(devNamePtr, kCFStringEncodingMacRoman)];

    long devProductID;
    CFTypeRef _Nullable devProductIDPtr = IOHIDDeviceGetProperty(inIOHIDDeviceRef, CFSTR(kIOHIDProductIDKey));
    CFNumberGetValue(devProductIDPtr, CFNumberGetType(devProductIDPtr), &devProductID);

    // Other useful info
    // IOHIDDeviceGetProperty(inIOHIDDeviceRef, CFSTR(kIOHIDTransportKey))     // USB
    // IOHIDDeviceGetProperty(inIOHIDDeviceRef, CFSTR(kIOHIDVendorIDKey))      // 1699
    // IOHIDDeviceGetProperty(inIOHIDDeviceRef, CFSTR(kIOHIDVersionNumberKey)) // 256
    // IOHIDDeviceGetProperty(inIOHIDDeviceRef, CFSTR(kIOHIDManufacturerKey))  // Saitek PLC
    // IOHIDDeviceGetProperty(inIOHIDDeviceRef, CFSTR(kIOHIDCountryCodeKey))   // 33
    // IOHIDDeviceGetProperty(inIOHIDDeviceRef, CFSTR(kIOHIDLocationIDKey))    // 337641472

    // Try to capture this device
    // https://stackoverflow.com/questions/23244349/iokit-not-permitted-in-sandbox
    IOReturn o = IOHIDDeviceOpen(inIOHIDDeviceRef, kIOHIDOptionsTypeSeizeDevice);

    if (o == kIOReturnSuccess) {
        // Init device with the retrieved info
        NSString *deviceRef = [NSString stringWithFormat:@"%p", inIOHIDDeviceRef];
        IOHIDDevice *device = [[IOHIDDevice alloc] initWithName:devName andProductID:devProductID];
        [device setReference:inIOHIDDeviceRef];
        [devices setValue:device forKey:deviceRef];

        // Update devices in UI
        ViewController *vc = (ViewController *)[[[NSApplication sharedApplication] orderedWindows].firstObject contentViewController];
        [vc didUpdateDeviceList:devices.allValues];

        // Register input callback
        IOHIDDeviceRegisterInputReportCallback(device.reference,
                                               (uint8_t *)device.readBuffer,
                                               sizeof(device.readBuffer),
                                               Handle_IOHIDDeviceInputReportCallback,
                                               inIOHIDDeviceRef);

        NSLog(@"\nDevice added: %@\nModel: %@\nDevice count: %ld",
              deviceRef,
              device.name,
              USBDeviceCount(inSender));

        [vc didUpdateDeviceList:devices.allValues];
    } else {
        NSLog(@"\nFailed to add device: %p\nModel: %@",
              (void *)inIOHIDDeviceRef,
              devName);
    }
}


// USB device specified in the matching dictionary has been removed (callback function)
static void Handle_DeviceRemovalCallback(void *inContext,
                                         IOReturn inResult,
                                         void *inSender,
                                         IOHIDDeviceRef inIOHIDDeviceRef) {

    // De-register input callback
    uint8_t buffer[0];
    IOHIDDeviceRegisterInputReportCallback(inIOHIDDeviceRef, buffer, 0, NULL, NULL);

    // Forget device
    NSString *deviceRef = [NSString stringWithFormat:@"%p", inIOHIDDeviceRef];

    if ([devices objectForKey:deviceRef]) {
        [devices removeObjectForKey:deviceRef];

        // Update devices in UI
        ViewController *vc = (ViewController *)[[[NSApplication sharedApplication] orderedWindows].firstObject contentViewController];
        [vc didUpdateDeviceList:devices.allValues];

        NSLog(@"\nDevice removed: %p\nDevice count: %ld", deviceRef, USBDeviceCount(inSender));
    }
}


// USB device specified in the matching dictionary has received data (callback function)
static void Handle_IOHIDDeviceInputReportCallback(void *inContext,
                                                  IOReturn inResult,
                                                  void *inSender,
                                                  IOHIDReportType inType,
                                                  uint32_t inReportID,
                                                  uint8_t *inReport,
                                                  CFIndex inReportLength) {

    // inResult should always be 0
    if (inResult) {
        NSLog(@"Unexpected input: %08x\n", inResult);
        return;
    }

    NSString *deviceRef = [NSString stringWithFormat:@"%p", inContext];
    if (![devices objectForKey:deviceRef]) {
        return;
    }

    switch (inType) {
        case kIOHIDReportTypeInput: {
            // Send input info to device
            NSData *data = [NSData dataWithBytes:inReport length:inReportLength];
            IOHIDDevice *device = [devices objectForKey:deviceRef];
            [device handleInput:data];

            // Update UI
            ViewController *vc = (ViewController *)[[[NSApplication sharedApplication] orderedWindows].firstObject contentViewController];
            [vc didUpdateDevice:device];

            break;
        }

        default:
            NSLog(@"Unknown report: %s, length: %ld, type: %d", inReport, (long)inReportLength, inType);
            break;
    }
}



// Counts the number of devices in the device set (includes all USB devices that match our dictionary)
static long USBDeviceCount(IOHIDManagerRef HIDManager) {

    // The device set includes all USB devices that match our matching dictionary. Fetch it.
     CFSetRef devSet = IOHIDManagerCopyDevices(HIDManager);

    // The devSet will be NULL if there are 0 devices, so only try to count the devices if devSet exists
    if (devSet) {
        return CFSetGetCount(devSet);
    }

    // There were no matching devices (devSet was NULL), so return a count of 0
     return 0;
}

@end

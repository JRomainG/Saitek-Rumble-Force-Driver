//
//  IOHIDDevice.h
//  SaitekRumbleForce
//
//  Created by Jean-Romain on 06/11/2019.
//  Copyright © 2019 JustKodding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IOKit/hid/IOHIDManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int, DPadDirection) {
    dpadDirectionNone,
    dpadDirectionTop,
    dpadDirectionTopRight,
    dpadDirectionRight,
    dpadDirectionBottomRight,
    dpadDirectionBottom,
    dpadDirectionBottomLeft,
    dpadDirectionLeft,
    dpadDirectionTopLeft,
};

struct JoystickPosition {
    double angle;      // In rad, angles follow trigonometric circle
    double amplitude;  // Between -128 and 127

    // Alternate representation
    int x;  // Between -128 and 127
    int y;  // Between -128 and 127
};

@interface IOHIDDevice : NSObject

@property (nonatomic, strong) NSString *name;           // Device's name
@property (nonatomic) long productID;                   // Type of product
@property (assign) IOHIDDeviceRef _Nullable reference;  // Device ref to use with the IOHIDManager
@property (assign) char *readBuffer;                    // read buffer (8 bytes) written by the HIDManager

// Button states
@property bool isButton1Pressed;        // X
@property bool isButton2Pressed;        // A
@property bool isButton3Pressed;        // B
@property bool isButton4Pressed;        // Y
@property bool isButton5Pressed;        // L1
@property bool isButton6Pressed;        // R1
@property bool isButton7Pressed;        // L2
@property bool isButton8Pressed;        // R2
@property bool isButtonOption1Pressed;  // Black button
@property bool isButtonOption2Pressed;  // Gray button
@property bool isButtonFPSPressed;      // FPS button
@property bool isButtonStartPressed;    // Start button

@property bool isFPSModeEnabled;        // Is FPS light on (assuming it was off when the controller was first detected)

// Dpad
@property DPadDirection dpadDirection;

// Joysticks
@property struct JoystickPosition leftJoystickPosition;
@property struct JoystickPosition rightJoystickPosition;

- (id)initWithName:(NSString *)name andProductID:(long)ID;
- (void)destroy;

- (NSString *)getDescription;
- (void)handleInput:(NSData *)input;

@end

NS_ASSUME_NONNULL_END

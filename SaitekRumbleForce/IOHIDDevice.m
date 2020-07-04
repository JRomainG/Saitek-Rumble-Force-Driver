//
//  IOHIDDevice.m
//  SaitekRumbleForce
//
//  Created by Jean-Romain on 06/11/2019.
//  Copyright © 2019 JustKodding. All rights reserved.
//

#import "IOHIDDevice.h"
#import "RumbleForceDecodeInfo.h"

@implementation IOHIDDevice

- (id)initWithName:(NSString *)name andProductID:(long)ID {
    if (self = [super init]) {
        self.name = name;
        self.reference = NULL;
        self.readBuffer = calloc(64, 1);
        self.productID = -1;
    }

    return self;
}

- (void)destroy {
    free(self.readBuffer);
}

- (NSString *)getDescription {
    return [NSString stringWithFormat:@"%@ (%p)", self.name, self.reference];
}

struct JoystickPosition positionFromBytes(uint8_t *bytes) {
    // When joystick is in center, its coordinates are (128, 128)
    int x = bytes[0] - 128;
    int y = bytes[1] - 128;

    struct JoystickPosition position;
    position.x = x;
    position.y = y;
    position.angle = atan2(y, x);
    position.amplitude = MAX(abs(x), abs(y));

    return position;
}

- (void)handleInput:(NSData *)input {
    // Interpret input
    uint8_t bytes;

    /* Standard buttons */
    // Get relevant info only
    [input getBytes:&bytes range:NSMakeRange(standardButtonsBytesInfoStart, 1)];

    // Multiple buttons can be pressed at once, so don't just check for equality
    self.isButton1Pressed = (bytes & btn1) == btn1;
    self.isButton2Pressed = (bytes & btn2) == btn2;
    self.isButton3Pressed = (bytes & btn3) == btn3;
    self.isButton4Pressed = (bytes & btn4) == btn4;
    self.isButton5Pressed = (bytes & btn5) == btn5;
    self.isButton6Pressed = (bytes & btn6) == btn6;
    self.isButton7Pressed = (bytes & btn7) == btn7;
    self.isButton8Pressed = (bytes & btn8) == btn8;

    /* Special buttons */
    // Keep only bits relevent to those buttons (they're stored in the same byte as the dpap)
    [input getBytes:&bytes range:NSMakeRange(specialButtonsBytesInfoStart, 1)];
    bytes &= 0x0f;

    // First, find out if the FPS button's "on or off" state changed
    if (!self.isButtonFPSPressed && ((bytes & btnFPS) == btnFPS)) {
        self.isFPSModeEnabled = !self.isFPSModeEnabled;
    }

    // Then, simply update the pressed (or not) state
    self.isButtonOption1Pressed = (bytes & btnOpt1) == btnOpt1;
    self.isButtonOption2Pressed = (bytes & btnOpt2) == btnOpt2;
    self.isButtonFPSPressed = (bytes & btnFPS) == btnFPS;
    self.isButtonStartPressed = (bytes & btnStart) == btnStart;

    /* DPad */
    // Keep only bits relevent to the dpap
    [input getBytes:&bytes range:NSMakeRange(dpadBytesInfoStart, 1)];
    bytes &= 0xf0;

    // Only one button can be pressed at once, so a switch is enough
    switch (bytes) {
        case dpadNone:
            self.dpadDirection = dpadDirectionNone;
            break;

        case dpadTop:
            self.dpadDirection = dpadDirectionTop;
            break;

        case dpadTopRight:
            self.dpadDirection = dpadDirectionTopRight;
            break;

        case dpadRight:
            self.dpadDirection = dpadDirectionRight;
            break;

        case dpadBottomRight:
            self.dpadDirection = dpadDirectionBottomRight;
            break;

        case dpadBottom:
            self.dpadDirection = dpadDirectionBottom;
            break;

        case dpadBottomLeft:
            self.dpadDirection = dpadDirectionBottomLeft;
            break;

        case dpadLeft:
            self.dpadDirection = dpadDirectionLeft;
            break;

        case dpadTopLeft:
            self.dpadDirection = dpadDirectionTopLeft;
            break;

        default:
            break;
    }

    /* Joysticks */
    // For joysticks, there are 2 uint8_t: the x coordinate and the y coordinate
    uint8_t joystickBytes[2];

    [input getBytes:&joystickBytes range:NSMakeRange(leftJoystickBytesInfoStart, 2)];
    self.leftJoystickPosition = positionFromBytes(joystickBytes);

    [input getBytes:&joystickBytes range:NSMakeRange(rightJoystickBytesInfoStart, 2)];
    self.rightJoystickPosition = positionFromBytes(joystickBytes);
}

@end

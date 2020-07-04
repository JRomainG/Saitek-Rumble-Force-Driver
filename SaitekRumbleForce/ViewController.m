//
//  ViewController.m
//  SaitekRumbleForce
//
//  Created by Jean-Romain on 06/11/2019.
//  Copyright © 2019 JustKodding. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.devicesList = [NSArray new];
    [self.gamepadSelectorButton removeAllItems];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)didUpdateDeviceList:(NSArray *)devices {
    self.devicesList = devices;

    NSString *selectedDeviceTitle = self.gamepadSelectorButton.selectedItem.title;
    [self.gamepadSelectorButton removeAllItems];

    IOHIDDevice *selectedDevice;
    for (IOHIDDevice *device in devices) {
        NSString *deviceTitle = [device getDescription];
        [self.gamepadSelectorButton addItemWithTitle:deviceTitle];

        if ([deviceTitle isEqualToString:selectedDeviceTitle]) {
            // Reselect previous option
            [self.gamepadSelectorButton selectItemWithTitle:deviceTitle];
            selectedDevice = device;
        }
    }

    // Make sure something is selected by default
    if (!selectedDeviceTitle && self.gamepadSelectorButton.numberOfItems > 0) {
        [self.gamepadSelectorButton selectItemAtIndex:0];
        selectedDevice = devices.firstObject;
    }

    // Update UI
    if (selectedDevice) {
        [self showUI];
        [self updateDisplayForDevice:selectedDevice];
    } else {
        [self hideUI];
    }
}

- (void)didUpdateDevice:(IOHIDDevice *)device {
    // Only update UI for the selected device
    if ([[device getDescription] isEqualToString:[[self.gamepadSelectorButton selectedItem] title]]) {
        [self updateDisplayForDevice:device];
    }
}

- (void)showUI {
    self.gamepadImageView.hidden = false;
    self.joystickLeftImageView.hidden = false;
    self.joystickRightImageView.hidden = false;
}

- (void)hideUI {
    self.gamepadImageView.hidden = true;

    self.btn1ImageView.hidden = true;
    self.btn2ImageView.hidden = true;
    self.btn3ImageView.hidden = true;
    self.btn4ImageView.hidden = true;
    self.btn5ImageView.hidden = true;
    self.btn6ImageView.hidden = true;
    self.btn7ImageView.hidden = true;
    self.btn8ImageView.hidden = true;

    self.btnOpt1ImageView.hidden = true;
    self.btnOpt2ImageView.hidden = true;
    self.btnFPSImageView.hidden = true;
    self.btnStartImageView.hidden = true;

    self.dpadImageView.hidden = true;
    self.joystickLeftImageView.hidden = true;
    self.joystickRightImageView.hidden = true;
}

- (void)updateDisplayForDevice:(IOHIDDevice *)device {
    // Update which images are shown to reflect the buttons pressed on the controler

    /* Standard buttons */
    self.btn1ImageView.hidden = !device.isButton1Pressed;
    self.btn2ImageView.hidden = !device.isButton2Pressed;
    self.btn3ImageView.hidden = !device.isButton3Pressed;
    self.btn4ImageView.hidden = !device.isButton4Pressed;
    self.btn5ImageView.hidden = !device.isButton5Pressed;
    self.btn6ImageView.hidden = !device.isButton6Pressed;
    self.btn7ImageView.hidden = !device.isButton7Pressed;
    self.btn8ImageView.hidden = !device.isButton8Pressed;
    
    /* Special buttons */
    self.btnOpt1ImageView.hidden = !device.isButtonOption1Pressed;
    self.btnOpt2ImageView.hidden = !device.isButtonOption2Pressed;
    self.btnFPSImageView.hidden = !device.isFPSModeEnabled;
    self.btnStartImageView.hidden = !device.isButtonStartPressed;
    
    /* DPad */
    self.dpadImageView.hidden = device.dpadDirection == dpadDirectionNone;

    switch (device.dpadDirection) {
        case dpadDirectionTop:
            self.dpadImageView.image = [NSImage imageNamed:@"dpad-top"];
            break;

        case dpadDirectionTopRight:
            self.dpadImageView.image = [NSImage imageNamed:@"dpad-top-right"];
            break;

        case dpadDirectionRight:
            self.dpadImageView.image = [NSImage imageNamed:@"dpad-right"];
            break;

        case dpadDirectionBottomRight:
            self.dpadImageView.image = [NSImage imageNamed:@"dpad-bottom-right"];
            break;

        case dpadDirectionBottom:
            self.dpadImageView.image = [NSImage imageNamed:@"dpad-bottom"];
            break;

        case dpadDirectionBottomLeft:
            self.dpadImageView.image = [NSImage imageNamed:@"dpad-bottom-left"];
            break;

        case dpadDirectionLeft:
            self.dpadImageView.image = [NSImage imageNamed:@"dpad-left"];
            break;

        case dpadDirectionTopLeft:
            self.dpadImageView.image = [NSImage imageNamed:@"dpad-top-left"];
            break;

        default:
            self.dpadImageView.image = nil;
            break;
    }

    /* Joysticks */
    CGFloat tx = device.leftJoystickPosition.x / 6;
    CGFloat ty = -device.leftJoystickPosition.y / 6;
    [self.joystickLeftImageView.layer setAffineTransform:CGAffineTransformMakeTranslation(tx, ty)];

    tx = device.rightJoystickPosition.x / 6;
    ty = -device.rightJoystickPosition.y / 6;
    [self.joystickRightImageView.layer setAffineTransform:CGAffineTransformMakeTranslation(tx, ty)];
}

@end

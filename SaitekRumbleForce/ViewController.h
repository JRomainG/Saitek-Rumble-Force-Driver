//
//  ViewController.h
//  SaitekRumbleForce
//
//  Created by Jean-Romain on 06/11/2019.
//  Copyright © 2019 JustKodding. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IOHIDDevice.h"

@interface ViewController : NSViewController

@property (nonatomic, strong) NSArray *devicesList;

@property (strong) IBOutlet NSPopUpButton *gamepadSelectorButton;

@property (strong) IBOutlet NSImageView *gamepadImageView;
@property (strong) IBOutlet NSImageView *dpadImageView;
@property (strong) IBOutlet NSImageView *btn1ImageView;
@property (strong) IBOutlet NSImageView *btn2ImageView;
@property (strong) IBOutlet NSImageView *btn3ImageView;
@property (strong) IBOutlet NSImageView *btn4ImageView;
@property (strong) IBOutlet NSImageView *btn5ImageView;
@property (strong) IBOutlet NSImageView *btn6ImageView;
@property (strong) IBOutlet NSImageView *btn7ImageView;
@property (strong) IBOutlet NSImageView *btn8ImageView;
@property (strong) IBOutlet NSImageView *btnOpt1ImageView;
@property (strong) IBOutlet NSImageView *btnOpt2ImageView;
@property (strong) IBOutlet NSImageView *btnFPSImageView;
@property (strong) IBOutlet NSImageView *btnStartImageView;
@property (strong) IBOutlet NSImageView *joystickLeftImageView;
@property (strong) IBOutlet NSImageView *joystickRightImageView;

- (void)didUpdateDeviceList:(NSArray *)devices;
- (void)didUpdateDevice:(IOHIDDevice *)device;

@end


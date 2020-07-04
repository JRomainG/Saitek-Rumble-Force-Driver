//
//  RumbleForceDecodeInfo.h
//  SaitekRumbleForce
//
//  Created by Jean-Romain on 07/11/2019.
//  Copyright © 2019 JustKodding. All rights reserved.
//

#ifndef RumbleForceDecodeInfo_h
#define RumbleForceDecodeInfo_h

// Ranges to decode input data (7 bytes in total)
// Data always starts with 0x01
static const int leftJoystickBytesInfoStart = 1;     // 2 bytes long
static const int rightJoystickBytesInfoStart = 3;    // 2 bytes long
static const int standardButtonsBytesInfoStart = 5;  // 1 byte long
static const int specialButtonsBytesInfoStart = 6;   // Last 4 bits of last byte
static const int dpadBytesInfoStart = 6;             // First 4 bits of last byte

// Expected data
typedef NS_ENUM(long int, ButtonPressType) {
    btn1             = 0x01,  // X
    btn2             = 0x02,  // A
    btn3             = 0x04,  // B
    btn4             = 0x08,  // Y
    btn5             = 0x10,  // L1
    btn6             = 0x20,  // R1
    btn7             = 0x40,  // L2
    btn8             = 0x80,  // R2

    btnOpt1          = 0x01,  // Bottom button
    btnOpt2          = 0x02,  // Top button
    btnFPS           = 0x04,  // FPS button
    btnStart         = 0x08,  // Start button

    dpadNone         = 0xf0,
    dpadTop          = 0x00,
    dpadTopRight     = 0x10,
    dpadRight        = 0x20,
    dpadBottomRight  = 0x30,
    dpadBottom       = 0x40,
    dpadBottomLeft   = 0x50,
    dpadLeft         = 0x60,
    dpadTopLeft      = 0x70,
};


#endif /* RumbleForceDecodeInfo_h */

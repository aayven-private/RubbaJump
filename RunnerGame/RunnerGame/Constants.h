//
//  Constants.h
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

static NSString *kObjectTypeRunner = @"runner";
static NSString *kObjectTypeBarrier = @"barrier";
static NSString *kObjectTypeGround = @"ground";

static uint32_t kObjectCategoryFrame = 0x1 << 0;
static uint32_t kObjectCategoryRunner = 0x1 << 1;
static uint32_t kObjectCategoryBarrier = 0x1 << 2;
static uint32_t kObjectCategoryGround = 0x1 << 3;

static float kPpm = 150.0;

static int kMaxJumpCount = 2;

static float kGroundHeight = 60;

static int kTopLimit = 100;
static int kBottomLimit = 4;
static int kMovingLimit = 2;

static float kRunnerSpeed = 600.0;

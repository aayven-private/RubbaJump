//
//  Constants.h
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


#define IS_PHONEPOD5() ([UIScreen mainScreen].bounds.size.height == 568.0f && [UIScreen mainScreen].scale == 2.f && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

static NSString *kSecret = @"kcU%$uP8vmE3zJvBHA";

static NSString *kObjectTypeRunner = @"runner";
static NSString *kObjectTypeBarrier = @"barrier";
static NSString *kObjectTypeGround = @"ground";
static NSString *kObjectTypeStar = @"star";

static uint32_t kObjectCategoryFrame = 0x1 << 0;
static uint32_t kObjectCategoryRunner = 0x1 << 1;
static uint32_t kObjectCategoryBarrier = 0x1 << 2;
static uint32_t kObjectCategoryGround = 0x1 << 3;
static uint32_t kObjectCategoryStar = 0x1 << 4;

static float kPpm = 150.0;

static int kMaxJumpCount = 2;

static float kGroundHeight = 90;

static int kTopLimit = 10;
static int kBottomLimit = 4;
static int kMovingLimit = 2;

static float kRunnerSpeed = 600.0;

static NSString *kRunnerMoodNormal = @"normal";
static NSString *kRunnerMoodMad = @"mad";
static NSString *kRunnerMoodVeryMad = @"verymad";

static NSString *kStatBarrierKey = @"weloux_runner_barrier_count";
static NSString *kStatJumpKey = @"weloux_runner_jump_count";
static NSString *kStatDoubleJumpKey = @"weloux_runner_doublejump_count";
static NSString *kStatDistanceKey = @"weloux_runner_total_distance";

static NSString *kComboPatternMad = @"dddd";
static NSString *kComboPatternVeryMad = @"dddddddd";
static NSString *kComboPatternTriple = @"ddd";
static NSString *kComboPatternUpDown = @"jdjdjd";

static float kParallaxBGSpeed_gameScene = 2.2;

static NSString *kSoundEnabledKey = @"RB_sound_enabled";

static NSString *kWillResignActiveNotifName = @"RB_willResignActive";

static NSString *kDirtyScoreKey = @"dirty_score";
static NSString *kGlobalPositionKey = @"global_position";

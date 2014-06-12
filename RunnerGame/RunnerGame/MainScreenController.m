//
//  ViewController.m
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "MainScreenController.h"
#import "GameScene.h"
#import "Constants.h"

#define IS_PHONEPOD5() ([UIScreen mainScreen].bounds.size.height == 568.0f && [UIScreen mainScreen].scale == 2.f && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

@interface MainScreenController()

@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *highScoreButton;
@property (nonatomic, weak) IBOutlet UIButton *statButton;
@property (nonatomic, weak) IBOutlet UIButton *soundButton;
@property (nonatomic, weak) IBOutlet UIButton *welouxButton;
@property (nonatomic, weak) IBOutlet UIButton *fbButton;
@property (nonatomic, weak) IBOutlet UIImageView *bgView;

@property (nonatomic) BOOL isSoundEnabled;

@end

@implementation MainScreenController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.playButton.titleLabel.font = [UIFont fontWithName:@"ExpletusSans-Bold" size:20.0];
    self.highScoreButton.titleLabel.font = [UIFont fontWithName:@"ExpletusSans-Bold" size:20.0];
    
    NSNumber *soundEnabled = [[NSUserDefaults standardUserDefaults] objectForKey:kSoundEnabledKey];
    if (!soundEnabled) {
        soundEnabled = [NSNumber numberWithBool:YES];
        [[NSUserDefaults standardUserDefaults] setObject:soundEnabled forKey:kSoundEnabledKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    _isSoundEnabled = soundEnabled.boolValue;
    if (!_isSoundEnabled) {
        [_soundButton setImage:[UIImage imageNamed:@"sound_off_a4.png"] forState:UIControlStateNormal];
    }
    
    if (IS_PHONEPOD5()) {
        self.bgView.image = [UIImage imageNamed:@"main_bg-568h.png"];
    } else {
        self.bgView.image = [UIImage imageNamed:@"main_bg.png"];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(IBAction)fbClicked:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"fb://profile/<id>"];
    [[UIApplication sharedApplication] openURL:url];
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
    else {
        //Open the url as usual
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.daledietrich.com"]];
    }

}

-(IBAction)soundClicked:(id)sender
{
    if (_isSoundEnabled) {
        [_soundButton setImage:[UIImage imageNamed:@"sound_off_a4.png"] forState:UIControlStateNormal];
        _isSoundEnabled = NO;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kSoundEnabledKey];
    } else {
        [_soundButton setImage:[UIImage imageNamed:@"sound_on_a4.png"] forState:UIControlStateNormal];
        _isSoundEnabled = YES;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kSoundEnabledKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction)welouxClicked:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.weloux.com"]];
}

@end

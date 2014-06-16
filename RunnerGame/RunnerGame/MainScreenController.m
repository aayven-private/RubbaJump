//
//  ViewController.m
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "MainScreenController.h"
#import "GameScene.h"
#import "Constants.h"

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
    
    self.playButton.titleLabel.font = [UIFont fontWithName:@"PoetsenOne-Regular" size:20.0];
    self.highScoreButton.titleLabel.font = [UIFont fontWithName:@"PoetsenOne-Regular" size:20.0];
    
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
        self.bgView.image = [UIImage imageNamed:@"main_bg_a4-568h.png"];
    } else {
        self.bgView.image = [UIImage imageNamed:@"main_bg_a4.png"];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
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
    [self playButtonSound];
    NSURL *url = [NSURL URLWithString:@"fb://profile/202042746673250"];
    [[UIApplication sharedApplication] openURL:url];
    if ([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
    else {
        //Open the url as usual
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/pages/Weloux/202042746673250"]];
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
        [self playButtonSound];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kSoundEnabledKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction)welouxClicked:(id)sender
{
    [self playButtonSound];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.weloux.com"]];
}

-(IBAction)buttonClicked:(id)sender
{
    [self playButtonSound];
}

-(void)playButtonSound
{
    if (_isSoundEnabled) {
        SystemSoundID soundID;
        
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"buttonClick_B-01" ofType:@"wav"];
        NSURL *soundUrl = [NSURL fileURLWithPath:soundPath];
        
        AudioServicesCreateSystemSoundID ((__bridge CFURLRef)soundUrl, &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
}

@end

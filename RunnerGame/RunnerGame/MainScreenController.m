//
//  ViewController.m
//  RunnerGame
//
//  Created by Ivan Borsa on 03/04/14.
//  Copyright (c) 2014 Weloux. All rights reserved.
//

#import "MainScreenController.h"
#import "GameScene.h"
#import "StatisticsManager.h"

@interface MainScreenController()

@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *highScoreButton;
@property (nonatomic, weak) IBOutlet UIButton *statButton;

@end

@implementation MainScreenController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.playButton.titleLabel.font = [UIFont fontWithName:@"ExpletusSans-Bold" size:20.0];
    self.highScoreButton.titleLabel.font = [UIFont fontWithName:@"ExpletusSans-Bold" size:20.0];
    
    StatisticsHelper *stat = [[StatisticsManager sharedInstance] getStatistics];
    NSLog(@"E");
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

@end

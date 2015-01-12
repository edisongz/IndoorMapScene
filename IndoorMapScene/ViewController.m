//
//  ViewController.m
//  IndoorMapScene
//
//  Created by apple on 13-10-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ViewController.h"
#import "IndoorMapScrollView.h"

#import "Constants.h"

@interface ViewController ()
{
    IndoorMapScrollView *indoorMapScrollView;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    indoorMapScrollView = [[IndoorMapScrollView alloc] initWithFrame:CGRectMake(0, 0.0f, MRScreenWidth, MRScreenHeight)];
    [self.view addSubview:indoorMapScrollView];
    
    //寻找最短路径
    [indoorMapScrollView findShortestPath:CGPointMake(113.0f, 70.0f) end:CGPointMake(300, 389) filePath:@"map1_path_data"];
    
    //弹出popover
    MyPositon *position = [[MyPositon alloc] init];
    position.point = CGPointMake(113.0f, 70.0f);
    [indoorMapScrollView popupOfPosition:position];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

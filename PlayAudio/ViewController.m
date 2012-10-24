//
//  ViewController.m
//  PlayAudio
//
//  Created by 杨飞 on 10/24/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize audio = _audio;
@synthesize audioTableView = _audioTableView;

- (id)init
{
    if(self == [super init])
    {
        _audioTableView = nil;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"铃声";
    //不能播放wav文件
    self.audio= [[AudioStreamer alloc]initWithAudioPath:[[NSBundle mainBundle] pathForResource:@"kaibulekou" ofType:@"mp3"]];
    [self.audio start];
    self.audioTableView = [[AudioTableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.audioTableView.audioDelegate = self;
    
    [self.view addSubview:self.audioTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RingTableViewDelegate

- (void)AudioTableViewDelegate:(AudioTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)AudioTableViewDelegate:(AudioTableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%i",indexPath.row);
}


@end

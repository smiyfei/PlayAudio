//
//  ViewController.m
//  PlayAudio
//
//  Created by 杨飞 on 10/24/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import "ViewController.h"
#import "TBAudioPlayer.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize audioPlayer = _audioPlayer;
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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pause)];
    
    self.navigationItem.title = @"铃声";

//    //不能播放wav文件
//    self.audio= [[AudioStreamer alloc]initWithContentsOfPath:[[NSBundle mainBundle] pathForResource:@"kaibulekou" ofType:@"mp3"] error:nil];
//
//    [self.audio start];
    self.audioPlayer = [[TBAudioPlayer alloc] initWithContentsOfPath:[[NSBundle mainBundle] pathForResource:@"kaibulekou" ofType:@"mp3"] error:nil];
    [self.audioPlayer play];
    //播放在线
//    NSURL *url = [NSURL URLWithString:@"http://infinitinb.net/COFFdD0xMzUwOTc1NzQ3Jmk9MTI1Ljc3LjIwMi4yNDYmdT1Tb25ncy92MS9mYWludFFDLzk0LzczOWIyNGFjZTZkM2FiMTllZmE0Yzc0MDE5MzI1Yzk0Lm1wMyZtPTlkMjAxY2Y5YzQ4OGQyOGQ1NjA5YzBiMTE4MjY0M2NiJnY9bGlzdGVuJm49v8nE3MTju7mwrs7SJnM90dfRx8LaJnA9cw==.mp3"];
//    TBAudioStreamer *streamer = [[TBAudioStreamer alloc] initWithContentsOfURL:url error:nil];
    

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

- (void)pause
{
    [self.audioPlayer pause];
}


@end

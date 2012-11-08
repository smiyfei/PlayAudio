//
//  ViewController.m
//  PlayAudio
//
//  Created by 杨飞 on 10/24/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import "ViewController.h"
#import "AVFoundation/AVFoundation.h"
#import "AudioPlayer.h"
#import "AudioTableView.h"
#import "AudioTrim.h"
#import "AudioParam.h"

static NSString *audioUrl = @"http://infinitinb.net/COFFdD0xMzUwOTc1NzQ3Jmk9MTI1Ljc3LjIwMi4yNDYmdT1Tb25ncy92MS9mYWludFFDLzk0LzczOWIyNGFjZTZkM2FiMTllZmE0Yzc0MDE5MzI1Yzk0Lm1wMyZtPTlkMjAxY2Y5YzQ4OGQyOGQ1NjA5YzBiMTE4MjY0M2NiJnY9bGlzdGVuJm49v8nE3MTju7mwrs7SJnM90dfRx8LaJnA9cw==.mp3";

@interface ViewController ()

@end

@implementation ViewController

@synthesize audioPlayer = _audioPlayer;

- (void)dealloc
{
    [_audioPlayer release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"铃声";
    
    UIButton *localButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [localButton setTitle:@"播放本地音乐" forState:UIControlStateNormal];
    localButton.frame = CGRectMake(0, 10, 100, 40);
    [localButton setTag:1001];
    [localButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *onlineButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [onlineButton setTitle:@"播放在线音乐" forState:UIControlStateNormal];
    onlineButton.frame = CGRectMake(0, 80, 100, 40);
    [onlineButton setTag:2001];
    [onlineButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *trimButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [trimButton setTitle:@"音频剪切" forState:UIControlStateNormal];
    trimButton.frame = CGRectMake(0,150, 100, 40);
    [trimButton setTag:3001];
    [trimButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *paramButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [paramButton setTitle:@"音频参数" forState:UIControlStateNormal];
    paramButton.frame = CGRectMake(0,220, 100, 40);
    [paramButton setTag:4001];
    [paramButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    

    [self.view addSubview:localButton];
    [self.view addSubview:onlineButton];
    [self.view addSubview:trimButton];
    [self.view addSubview:paramButton];
    
    [onlineButton release];
    [localButton release];
    [trimButton release];
    [paramButton release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonClick:(UIButton *)button
{
    int tag = button.tag;
    NSURL *url = nil;
    AVPlayer *player = nil;
    NSString *audioPath = nil;
    AudioParam *audioParam = nil;
    switch (tag) {
        case 1001:
            url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"kaibulekou" ofType:@"mp3"]];
            self.audioPlayer = [[AudioPlayer alloc] initwithcontentsOFURL:url error:nil];
            [self.audioPlayer play];
            break;
        case 2001:
            url = [NSURL URLWithString:audioUrl];
            self.audioPlayer = [[AudioPlayer alloc] initwithcontentsOFURL:url error:nil];
            [self.audioPlayer play];
//            [self.audioPlayer seekToTime:20.0];
            break;
        case 3001:
            // 测试音频剪切
            player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"kaibulekou" ofType:@"mp3"]]];
            CMTime startTime = CMTimeMake(30, 1);
            CMTime stopTime = CMTimeMake(60, 1);
            NSString *targetPath = @"/Users/comtongbu/Desktop/test.m4a";
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"kaibulekou" ofType:@"mp3"];
            AudioTrim *audioTrim = [[AudioTrim alloc] init];
            [audioTrim trimAudio:filePath toFilePath:targetPath startTime:startTime stopTime:stopTime];
            break;
        case 4001:
            audioPath = [[NSBundle mainBundle] pathForResource:@"kaibulekou" ofType:@"mp3"];
            audioParam = [[AudioParam alloc] initWithAudioPath:audioPath];
            NSLog(@"audio param : %@ %@ %@ %@ %@",[audioParam title],[audioParam year],[audioParam artist],[audioParam album],[audioParam duration]);
            
            
        default:
            break;
    }
}

@end

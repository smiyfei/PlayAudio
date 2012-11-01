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

static NSString *audioUrl = @"http://infinitinb.net/COFFdD0xMzUwOTc1NzQ3Jmk9MTI1Ljc3LjIwMi4yNDYmdT1Tb25ncy92MS9mYWludFFDLzk0LzczOWIyNGFjZTZkM2FiMTllZmE0Yzc0MDE5MzI1Yzk0Lm1wMyZtPTlkMjAxY2Y5YzQ4OGQyOGQ1NjA5YzBiMTE4MjY0M2NiJnY9bGlzdGVuJm49v8nE3MTju7mwrs7SJnM90dfRx8LaJnA9cw==.mp3";

@interface ViewController ()

@end

@implementation ViewController

@synthesize audioPlayer = _audioPlayer;
@synthesize audioTableView = _audioTableView;

- (id)init
{
    if(self == [super init])
    {
        _audioTableView = nil;
    }
    
    return self;
}

- (void)dealloc
{
    [_audioTableView release];
    [_audioPlayer release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pause)];
    self.navigationItem.title = @"铃声";

    NSURL *url = [NSURL URLWithString:audioUrl];
    self.audioPlayer = [[AudioPlayer alloc] initwithcontentsOFURL:url error:nil];
    [self.audioPlayer play];
    
    NSURL *fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"kaibulekou" ofType:@"mp3"]];
    self.audioPlayer = [[AudioPlayer alloc] initwithcontentsOFURL:fileUrl error:nil];
    [self.audioPlayer play];

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

//
//  TBAudioPlayer.m
//  PlayAudio
//
//  Created by 杨飞 on 10/25/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import "PlayLocal.h"
#import "PlayAudio.h"
#import "AudioPlayer.h"
#import "AudioStreamer.h"

#define IS_LOCAL TRUE //定义默认本地播放

@implementation AudioPlayer

@synthesize seekTime;
@synthesize progress;

- (id)initwithcontentsOFURL:(NSURL *)url error:(NSError **)outError
{
    if (self == [super init])
    {
        if (nil != playAudio) {
            [playAudio stop];
            [playAudio release];
        }
        if ([url isFileURL])
        {
            playAudio = [[PlayLocal alloc] initWithURL:url error:nil];
        }
        else
        {
            playAudio = [[AudioStreamer alloc] initWithURL:url];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [playAudio release];
    [super dealloc];
}

- (BOOL)play
{
    if ([playAudio isPlaying])
    {
        [playAudio stop];
    }
    else
    {
        [playAudio start];
    }
    
    return true;
}

- (void)pause
{
    if (!playAudio)
    {
        [playAudio pause];
    }
}

- (void)stop
{
    if (nil != playAudio)
    {
        [playAudio stop];
        
    }
}

- (void)seekToTime:(double)newSeekTime
{
    if (nil != playAudio) {
        [self stop];
        [playAudio seekToTime:newSeekTime];
    }
}



@end

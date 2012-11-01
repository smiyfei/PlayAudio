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

@implementation AudioPlayer

@synthesize localPlayer = _localPlayer;
@synthesize streamer = _streamer;
@synthesize seekTime;
@synthesize progress;

- (id)initwithcontentsOFURL:(NSURL *)url error:(NSError **)outError
{
    if (self == [super init]) {
        if ([url isFileURL]) {
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
    [_streamer release];
    [_localPlayer release];
    [super dealloc];
}

- (BOOL)play
{
    if (!playAudio) {
//        self.streamer = [[AudioStreamer alloc] initWithURL:self.url];
        // set up display updater
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [self methodSignatureForSelector:@selector(updateProgress)]];
        [invocation setSelector:@selector(updateProgress)];
        [invocation setTarget:self];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                             invocation:invocation
                                                repeats:YES];
        
        // register the streamer on notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackStateChanged:)
                                                     name:ASStatusChangedNotification
                                                   object:playAudio];
    }
    
//    if ([playAudio isPlaying])
//    {
//        [playAudio stop];
//    }
//    else
//    {
        [playAudio start];
//    }
    
    return true;
}

- (double)progress
{
    
}

- (BOOL)isFinishing
{
    
}


- (double)duration
{
    
}

- (void)seekToTime:(double)newSeekTime
{
    
}

@end

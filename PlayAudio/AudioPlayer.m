//
//  TBAudioPlayer.m
//  PlayAudio
//
//  Created by 杨飞 on 10/25/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import "AudioPlayer.h"
#import "AudioStreamer.h"
#import "AudioParam.h"



@implementation AudioPlayer

@synthesize streamer = _streamer;
@synthesize webStreamer = _webStreamer;
@synthesize state;
@synthesize seekTime;
@synthesize progress;

- (id)initWithContentsOfPath:(NSString *)path error:(NSError **)outError
{
    if(self == [super init])
    {
        self.state = AS_INITIALIZED;//状态初始化
        self.streamer = [[AudioStreamer alloc] initWithContentsOfPath:path error:nil];
        audioQueue = [self.streamer createQueue];//获取本地播放音频队列
    }
    
    return self;
}

- (id)initwithcontentsOFURL:(NSURL *)url error:(NSError **)outError
{
    if (self == [super init]) {
        self.state = AS_INITIALIZED;
        self.webStreamer = [[AudioWebStreamer alloc] initWithURL:url];
        if (audioQueue != nil) {
            err = AudioQueueStop(audioQueue, true);
            if (err) {
                NSLog(@"can't stop audio queue");
                return nil;
            }
        }
        audioQueue = [self.webStreamer start];

    }
    
    return self;
}

- (void)dealloc
{
    [_streamer release];
    [_webStreamer release];
    [super dealloc];
}


//- (BOOL)play
//{
//    @synchronized (self)
//    {
//        if(state == AS_PAUSED)
//        {
//            [self pause];
//        }
//        else
//        {
//            if(state == AS_INITIALIZED)
//            {
//                NSAssert([[NSThread currentThread] isEqual:[NSThread mainThread]], @"Playback can only be started from the main thread.");
//                notificationCenter = [[NSNotificationCenter defaultCenter] retain];
////                audioQueue = [_streamer startInterval];
//                Float32 gain = 1.0;
//                //音量设置
//                AudioQueueSetParameter(audioQueue, kAudioQueueParam_Volume, gain);
//                AudioQueueStart(audioQueue, nil);
//                self.state = AS_PLAYING;
//            }
//        }
//    }
//    
//    
//    return YES;
//}
//
//- (void)pause
//{
//    @synchronized(self)
//    {
//        if(self.state == AS_PLAYING)
//        {
//            err = AudioQueuePause(audioQueue);
//            if(err)
//            {
//                NSLog(@"%@",@"AS_AUDIO_QUEUE_PAUSE_FAILED");
//                return;
//            }
//            self.state = AS_PAUSED;
//        }
//        else if(self.state == AS_PAUSED)
//        {
//            err = AudioQueueStart(audioQueue, NULL);
//            if(err)
//            {
//                NSLog(@"%@",@"AS_AUDIO_QUEUE_START_FAILED");
//                return;
//            }
//            self.state = AS_PLAYING;
//        }
//    }
//}
//
//- (void)stop
//{
//    @synchronized(self)
//	{
//		if (audioQueue &&
//			(state == AS_PLAYING || state == AS_PAUSED ||
//             state == AS_BUFFERING || state == AS_WAITING_FOR_QUEUE_TO_START))
//		{
//			self.state = AS_STOPPING;
////			stopReason = AS_STOPPING_USER_ACTION;
//			err = AudioQueueStop(audioQueue, true);
//			if (err)
//			{
////				[self failWithErrorCode:AS_AUDIO_QUEUE_STOP_FAILED];
//                NSLog(@"%@",@"AS_AUDIO_QUEUE_STOP_FAILED");
//				return;
//			}
//		}
//		else if (state != AS_INITIALIZED)
//		{
//			self.state = AS_STOPPED;
////			stopReason = AS_STOPPING_USER_ACTION;
//		}
////		seekWasRequested = NO;
//	}
//	
//	while (state != AS_INITIALIZED)
//	{
//		[NSThread sleepForTimeInterval:0.1];
//	}
//
//}

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

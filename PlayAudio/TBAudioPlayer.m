//
//  TBAudioPlayer.m
//  PlayAudio
//
//  Created by 杨飞 on 10/25/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import "TBAudioPlayer.h"
#import "TBAudioStreamer.h"

@implementation TBAudioPlayer

@synthesize streamer;
@synthesize state;

- (id)initWithContentsOfPath:(NSString *)path error:(NSError **)outError
{
    if(self == [super init])
    {
        streamer = [[TBAudioStreamer alloc] initWithContentsOfPath:path error:nil];
    }
    
    return self;
}


- (BOOL)play
{
    @synchronized (self)
    {
        if(state == AS_PAUSED)
        {
            [self pause];
        }
        else
        {
            if(state == AS_INITIALIZED)
            {
                NSAssert([[NSThread currentThread] isEqual:[NSThread mainThread]], @"Playback can only be started from the main thread.");
                notificationCenter = [[NSNotificationCenter defaultCenter] retain];
                queue = [streamer startInterval];
                self.state = AS_PLAYING;
                
                
                
            }
        }
    }
    return YES;
}

- (void)pause
{
    @synchronized(self)
    {
        if(state == AS_PLAYING)
        {
            err = AudioQueuePause(queue);
            if(err)
            {
                NSLog(@"%@",@"AS_AUDIO_QUEUE_PAUSE_FAILED");
                return;
            }
            self.state = AS_PAUSED;
        }
        else if(state == AS_PAUSED)
        {
            err = AudioQueueStart(queue, NULL);
            if(err)
            {
                NSLog(@"%@",@"AS_AUDIO_QUEUE_START_FAILED");
                return;
            }
            self.state = AS_PLAYING;
        }
    }
}

- (void)stop
{
    @synchronized(self)
	{
		if (queue &&
			(state == AS_PLAYING || state == AS_PAUSED ||
             state == AS_BUFFERING || state == AS_WAITING_FOR_QUEUE_TO_START))
		{
			self.state = AS_STOPPING;
//			stopReason = AS_STOPPING_USER_ACTION;
			err = AudioQueueStop(queue, true);
			if (err)
			{
//				[self failWithErrorCode:AS_AUDIO_QUEUE_STOP_FAILED];
                NSLog(@"%@",@"AS_AUDIO_QUEUE_STOP_FAILED");
				return;
			}
		}
		else if (state != AS_INITIALIZED)
		{
			self.state = AS_STOPPED;
//			stopReason = AS_STOPPING_USER_ACTION;
		}
//		seekWasRequested = NO;
	}
	
	while (state != AS_INITIALIZED)
	{
		[NSThread sleepForTimeInterval:0.1];
	}

}

- (void)seekToTime:(double)newSeekTime
{
    
}


@end

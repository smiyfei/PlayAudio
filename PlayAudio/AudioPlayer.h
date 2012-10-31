//
//  TBAudioPlayer.h
//  PlayAudio
//
//  Created by 杨飞 on 10/25/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioToolBox/AudioToolBox.h"
#import "TBAudioStreamer.h"

typedef enum
{
	AS_INITIALIZED = 0,
	AS_STARTING_FILE_THREAD,
	AS_WAITING_FOR_DATA,
	AS_FLUSHING_EOF,
	AS_WAITING_FOR_QUEUE_TO_START,
	AS_PLAYING,
	AS_BUFFERING,
	AS_STOPPING,
	AS_STOPPED,
	AS_PAUSED
} AudioStreamerState;

@interface TBAudioPlayer : NSObject
{
    TBAudioStreamer *streamer;
    
    AudioQueueRef queue;//获取当前播放音频队列
    AudioStreamerState state;//音频播放状态
    NSNotificationCenter *notificationCenter;
    NSThread *internalThread;
    OSStatus err;
    
    double seekTime;//跳转到的时间
    double prograss;//当前进度
}

@property (nonatomic,retain) TBAudioStreamer *streamer;
@property (readwrite) AudioStreamerState state;

/* all data must be in the form of an audio file understood by CoreAudio */
- (id)initWithContentsOfPath:(NSString *)path error:(NSError **)outError;
- (id)initwithcontentsOFURL:(NSURL *)url error:(NSError **)outError;
- (id)initWithData:(NSData *)data error:(NSError **)outError;
- (BOOL)prepareToPlay;	/* get ready to play the sound. happens automatically on play. */
- (BOOL)play;			/* sound is played asynchronously. */
- (void)seekToTime:(double)newSeekTime;
- (void)pause;			/* pauses playback, but remains ready to play. */
- (void)stop;			/* stops playback. no longer ready to play. */


@end

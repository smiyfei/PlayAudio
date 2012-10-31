//
//  TBAudioPlayer.h
//  PlayAudio
//
//  Created by 杨飞 on 10/25/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioToolBox/AudioToolBox.h"
#import "AudioStreamer.h"
#import "AudioWebStreamer.h"

//typedef enum
//{
//	AS_INITIALIZED = 0,//初始化
//	AS_STARTING_FILE_THREAD,
//	AS_WAITING_FOR_DATA,
//	AS_FLUSHING_EOF,
//	AS_WAITING_FOR_QUEUE_TO_START,
//	AS_PLAYING,
//	AS_BUFFERING,
//	AS_STOPPING,
//	AS_STOPPED,
//	AS_PAUSED
//} AudioStreamerState;

@interface AudioPlayer : NSObject
{
    AudioStreamer *_streamer;
    AudioWebStreamer *_webStreamer;
    
    AudioQueueRef audioQueue;//获取当前播放音频队列,控制播放、暂停等操作
    AudioStreamerState state;//音频播放状态

    NSNotificationCenter *notificationCenter;
    
    NSThread *internalThread;
    OSStatus err;
    
    double seekTime;//跳转到的时间
    double lastProgress;//最近计算进度点
}

@property (nonatomic,retain) AudioStreamer *streamer;
@property (nonatomic,retain) AudioWebStreamer *webStreamer;
@property (readwrite) AudioStreamerState state;
@property (nonatomic,assign) double seekTime;
@property (readonly) double progress;
@property (readonly) double duration;

/* all data must be in the form of an audio file understood by CoreAudio */
- (id)initWithContentsOfPath:(NSString *)path error:(NSError **)outError;
- (id)initwithcontentsOFURL:(NSURL *)url error:(NSError **)outError;
- (id)initWithData:(NSData *)data error:(NSError **)outError;

- (BOOL)prepareToPlay;	/* get ready to play the sound. happens automatically on play. */
- (BOOL)play;			/* sound is played asynchronously. */
- (void)seekToTime:(double)newSeekTime;
- (void)pause;			/* pauses playback, but remains ready to play. */
- (void)stop;			/* stops playback. no longer ready to play. */
- (BOOL)isPlaying;
- (BOOL)isPaused;
- (BOOL)isWaiting;
- (BOOL)isIdle;

+ (NSString *)stringForErrorCode:(AudioStreamerErrorCode)anErrorCode;

@end

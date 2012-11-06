//
//  PlayLocal.h
//
//  Created by 杨飞 on 10/25/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioToolBox/AudioToolBox.h"
#import "PlayAudio.h"

#define NUM_BUFFERS 3

typedef enum
{
	PL_INITIALIZED = 0,
	PL_PLAYING,                       // 正在播放
	PL_PAUSED,                        // 手动暂停
	PL_STOPPING,                      // 即将停止,自动提醒
	PL_STOPPED,                       // 已停止播放
} PlayLocalState;

typedef enum
{
	PL_NO_STOP = 0,
	PL_STOPPING_EOF,
	PL_STOPPING_USER_ACTION,
	PL_STOPPING_ERROR,
	PL_STOPPING_TEMPORARILY
} PlayLocalStopReason;

typedef enum
{
	PL_NO_ERROR = 0,
	PL_NETWORK_CONNECTION_FAILED,
	PL_FILE_STREAM_GET_PROPERTY_FAILED,
	PL_FILE_STREAM_SEEK_FAILED,
	PL_FILE_STREAM_PARSE_BYTES_FAILED,
	PL_FILE_STREAM_OPEN_FAILED,
	PL_FILE_STREAM_CLOSE_FAILED,
	PL_AUDIO_DATA_NOT_FOUND,
	PL_AUDIO_QUEUE_CREATION_FAILED,
	PL_AUDIO_QUEUE_BUFFER_ALLOCATION_FAILED,
	PL_AUDIO_QUEUE_ENQUEUE_FAILED,
	PL_AUDIO_QUEUE_ADD_LISTENER_FAILED,
	PL_AUDIO_QUEUE_REMOVE_LISTENER_FAILED,
	PL_AUDIO_QUEUE_START_FAILED,
	PL_AUDIO_QUEUE_PAUSE_FAILED,
	PL_AUDIO_QUEUE_BUFFER_MISMATCH,
	PL_AUDIO_QUEUE_DISPOSE_FAILED,
	PL_AUDIO_QUEUE_STOP_FAILED,
	PL_AUDIO_QUEUE_FLUSH_FAILED,
	PL_AUDIO_STREAMER_FAILED,
	PL_GET_AUDIO_TIME_FAILED,
	PL_AUDIO_BUFFER_TOO_SMALL
} PlayLocalErrorCode;

@interface PlayLocal: NSObject <PlayAudio>
{
    //音频队列
    AudioQueueRef audioQueue;
    //播放音频文件ID
    AudioFileID audioFile;
    //音频流描述对象
    AudioStreamBasicDescription dataFormat;
    
    OSStatus err;
    BOOL seekWasRequested;//判断当前是否允许改变进度
    
    PlayLocalState state;
    PlayLocalErrorCode errorCode;
    PlayLocalStopReason stopReason;

    SInt64 packetIndex;
    UInt32 numPacketsToRead;
    UInt32 bufferByteSize;
    AudioStreamPacketDescription *packetDescs;
    AudioQueueBufferRef buffers[NUM_BUFFERS];
}

@property (assign) NSString *audioPath;
@property (assign) NSURL *audioURL;

- (id)initWithURL:(NSURL *)url error:(NSError **)outError;

@end

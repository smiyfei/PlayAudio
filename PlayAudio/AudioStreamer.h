//
//  AudioStreamer.h
//  PlayAudio
//
//  Created by 杨飞 on 12-3-26.
//  Copyright (c) 2012年 infomedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>
#define NUM_BUFFERS 3

//typedef enum
//{
//	AS_NO_STOP = 0,
//	AS_STOPPING_EOF,
//	AS_STOPPING_USER_ACTION,
//	AS_STOPPING_ERROR,
//	AS_STOPPING_TEMPORARILY
//} AudioStreamerStopReason;
//
//typedef enum
//{
//	AS_NO_ERROR = 0,
//	AS_NETWORK_CONNECTION_FAILED,
//	AS_FILE_STREAM_GET_PROPERTY_FAILED,
//	AS_FILE_STREAM_SEEK_FAILED,
//	AS_FILE_STREAM_PARSE_BYTES_FAILED,
//	AS_FILE_STREAM_OPEN_FAILED,
//	AS_FILE_STREAM_CLOSE_FAILED,
//	AS_AUDIO_DATA_NOT_FOUND,
//	AS_AUDIO_QUEUE_CREATION_FAILED,
//	AS_AUDIO_QUEUE_BUFFER_ALLOCATION_FAILED,
//	AS_AUDIO_QUEUE_ENQUEUE_FAILED,
//	AS_AUDIO_QUEUE_ADD_LISTENER_FAILED,
//	AS_AUDIO_QUEUE_REMOVE_LISTENER_FAILED,
//	AS_AUDIO_QUEUE_START_FAILED,
//	AS_AUDIO_QUEUE_PAUSE_FAILED,
//	AS_AUDIO_QUEUE_BUFFER_MISMATCH,
//	AS_AUDIO_QUEUE_DISPOSE_FAILED,
//	AS_AUDIO_QUEUE_STOP_FAILED,
//	AS_AUDIO_QUEUE_FLUSH_FAILED,
//	AS_AUDIO_STREAMER_FAILED,
//	AS_GET_AUDIO_TIME_FAILED,
//	AS_AUDIO_BUFFER_TOO_SMALL
//} AudioStreamerErrorCode;

@interface AudioStreamer : NSObject{
    //音频队列
    AudioQueueRef queue;
    //播放音频文件ID
    AudioFileID audioFile;
    //音频流描述对象
    AudioStreamBasicDescription dataFormat;
    
    SInt64 packetIndex;
    UInt32 numPacketsToRead;
    UInt32 bufferByteSize;
    AudioStreamPacketDescription *packetDescs;
    AudioQueueBufferRef buffers[NUM_BUFFERS];
}

@property AudioQueueRef queue;

//播放方法定义
- (id)initWithContentsOfPath:(NSString *)path error:(NSError **)outError;
- (void)start;
- (void)pause;
- (void)stop;
- (BOOL)isPlaying;
- (BOOL)isPaused;
- (BOOL)isWaiting;

@end

//
//  TBAudioStreamer.h
//  PlayAudio
//
//  Created by 杨飞 on 10/25/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioToolBox/AudioToolBox.h"

#define NUM_BUFFERS 3

#define LOG_QUEUED_BUFFERS 0

#define kNumAQBufs 16			// Number of audio queue buffers we allocate.
                                // Needs to be big enough to keep audio pipeline
                                // busy (non-zero number of queued buffers) but
                                // not so big that audio takes too long to begin
                                // (kNumAQBufs * kAQBufSize of data must be
                                // loaded before playback will start).
                                //
                                // Set LOG_QUEUED_BUFFERS to 1 to log how many
                                // buffers are queued at any time -- if it drops
                                // to zero too often, this value may need to
                                // increase. Min 3, typical 8-24.

#define kAQDefaultBufSize 2048	// Number of bytes in each audio queue buffer
                                // Needs to be big enough to hold a packet of
                                // audio from the audio file. If number is too
                                // large, queuing of audio before playback starts
                                // will take too long.
                                // Highly compressed files can use smaller
                                // numbers (512 or less). 2048 should hold all
                                // but the largest packets. A buffer size error
                                // will occur if this number is too small.

#define kAQMaxPacketDescs 512	// Number of packet descriptions in our array

typedef enum
{
	AS_NO_STOP = 0,
	AS_STOPPING_EOF,
	AS_STOPPING_USER_ACTION,
	AS_STOPPING_ERROR,
	AS_STOPPING_TEMPORARILY
} AudioStreamerStopReason;//停止播放原因

@interface AudioStreamer : NSObject
{
    NSString *audioPath;
    NSURL *audioUrl;
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

@property (assign) NSString *audioPath;
//定义队列为实例属性
@property AudioQueueRef queue;

//播放方法定义
- (id)initWithContentsOfPath:(NSString *)path error:(NSError **)outError;
- (AudioQueueRef)createQueue;
- (AudioQueueRef)startInterval;

@end

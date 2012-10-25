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

typedef enum
{
	AS_NO_ERROR = 0,
	AS_NETWORK_CONNECTION_FAILED,
	AS_FILE_STREAM_GET_PROPERTY_FAILED,
	AS_FILE_STREAM_SEEK_FAILED,
	AS_FILE_STREAM_PARSE_BYTES_FAILED,
	AS_FILE_STREAM_OPEN_FAILED,
	AS_FILE_STREAM_CLOSE_FAILED,
	AS_AUDIO_DATA_NOT_FOUND,
	AS_AUDIO_QUEUE_CREATION_FAILED,
	AS_AUDIO_QUEUE_BUFFER_ALLOCATION_FAILED,
	AS_AUDIO_QUEUE_ENQUEUE_FAILED,
	AS_AUDIO_QUEUE_ADD_LISTENER_FAILED,
	AS_AUDIO_QUEUE_REMOVE_LISTENER_FAILED,
	AS_AUDIO_QUEUE_START_FAILED,
	AS_AUDIO_QUEUE_PAUSE_FAILED,
	AS_AUDIO_QUEUE_BUFFER_MISMATCH,
	AS_AUDIO_QUEUE_DISPOSE_FAILED,
	AS_AUDIO_QUEUE_STOP_FAILED,
	AS_AUDIO_QUEUE_FLUSH_FAILED,
	AS_AUDIO_STREAMER_FAILED,
	AS_GET_AUDIO_TIME_FAILED,
	AS_AUDIO_BUFFER_TOO_SMALL
} AudioStreamerErrorCode;//播放错误代码

@interface TBAudioStreamer : NSObject
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
    
    
    //播放网络文件
    AudioQueueRef webQueue;
    AudioFileStreamID audioFileStream;
    AudioStreamBasicDescription audioBasicDescription;
    NSThread *internalThread;
    
    AudioQueueBufferRef audioQueueBuffer[kNumAQBufs];
    AudioStreamPacketDescription packetDescription[kAQMaxPacketDescs];
    unsigned int fillBufferIndex;
    UInt32 packetBufferSize;
    size_t bytesFilled;				// how many bytes have been filled
	size_t packetsFilled;			// how many packets have been filled
	bool inuse[kNumAQBufs];			// flags to indicate that a buffer is still in use
	NSInteger buffersUsed;
	NSDictionary *httpHeaders;
	NSString *fileExtension;
    
	AudioStreamerStopReason stopReason;
	AudioStreamerErrorCode errorCode;
	OSStatus err;
	
	bool discontinuous;			// flag to indicate middle of the stream
	
	pthread_mutex_t queueBuffersMutex;			// a mutex to protect the inuse flags
	pthread_cond_t queueBufferReadyCondition;	// a condition varable for handling the inuse flags
    
	CFReadStreamRef stream;
	NSNotificationCenter *notificationCenter;
	
	UInt32 bitRate;				// Bits per second in the file
	NSInteger dataOffset;		// Offset of the first audio packet in the stream
	NSInteger fileLength;		// Length of the file in bytes
	NSInteger seekByteOffset;	// Seek offset within the file in bytes
	UInt64 audioDataByteCount;  // Used when the actual number of audio bytes in
    // the file is known (more accurate than assuming
    // the whole file is audio)
    
	UInt64 processedPacketsCount;		// number of packets accumulated for bitrate estimation
	UInt64 processedPacketsSizeTotal;	// byte size of accumulated estimation packets
    
	double seekTime;
	BOOL seekWasRequested;
	double requestedSeekTime;
	double sampleRate;			// Sample rate of the file (used to compare with
    // samples played by the queue for current playback
    // time)
	double packetDuration;		// sample rate times frames per packet
	double lastProgress;		// last calculated progress point
#if TARGET_OS_IPHONE
	BOOL pausedByInterruption;
#endif

    
    
}

@property (assign) NSString *audioPath;
//定义队列为实例属性
@property AudioQueueRef queue;

//播放网络
@property (readonly) double progress;
@property (readonly) double duration;
@property (readwrite) UInt32 bitRate;
@property (readonly) NSDictionary *httpHeaders;
@property (copy,readwrite) NSString *fileExtension;

//播放方法定义
- (id)initWithContentsOfPath:(NSString *)path error:(NSError **)outError;
- (id)initWithContentsOfURL:(NSURL *)url error:(NSError **)outError;
- (AudioQueueRef)startInterval;
- (AudioQueueRef)createQueue;

@end

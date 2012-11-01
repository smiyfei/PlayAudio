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

//播放本地音乐
@interface PlayLocal: NSObject<PlayAudio>
{
    //音频队列
    AudioQueueRef audioQueue;
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
@property (assign) NSURL *audioURL;

//播放方法定义
- (id)initwithPath:(NSString *)path error:(NSError **)outError;
- (id)initWithURL:(NSURL *)url error:(NSError **)outError;

@end

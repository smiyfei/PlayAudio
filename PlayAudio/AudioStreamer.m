//
//  TBAudioStreamer.m
//  PlayAudio
//
//  Created by 杨飞 on 10/25/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import "AudioStreamer.h"

static UInt32 gBufferSizeBytes=0x10000;//It muse be pow(2,x)

@interface AudioStreamer()

//定义回调(Callback)函数
static void BufferCallack(void *inUserData,AudioQueueRef inAQ,
                          AudioQueueBufferRef buffer);
//定义缓存数据读取方法
-(void)audioQueueOutputWithQueue:(AudioQueueRef)audioQueue
                     queueBuffer:(AudioQueueBufferRef)audioQueueBuffer;
-(UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer;

@end

@implementation AudioStreamer

@synthesize audioPath;
@synthesize queue;

//播放本地文件初始化
- (id)initWithContentsOfPath:(NSString *)path error:(NSError **)outError;
{
    self = [super init];
    if(self)
    {
        audioPath = [path retain];
    }
    
    return self;
}

- (void)dealloc
{
    [audioPath release];
    [super dealloc];
}

- (AudioQueueRef)createQueue
{
    UInt32 size,maxPacketSize;
    char *cookie;
    int i;
    OSStatus status;
    
    //打开音频文件
    status = AudioFileOpenURL((CFURLRef)[NSURL fileURLWithPath:audioPath], kAudioFileReadPermission, 0, &audioFile);
    if(status != noErr)
    {
        NSLog(@"*** Error *** PlayAudio - Play:Path could not open audio file. Path given was : %@",audioPath);
        return nil;
    }
    
    for(int i = 0;i < NUM_BUFFERS; i++)
    {
        AudioQueueEnqueueBuffer(queue, buffers[i], 0, nil);
    }
    
    //取得音频数据格式
    size = sizeof(dataFormat);
    AudioFileGetProperty(audioFile, kAudioFilePropertyDataFormat, &size, &dataFormat);
    
    //创建播放用的音频队列
    AudioQueueNewOutput(&dataFormat,BufferCallBack, self, nil, nil, 0, &queue);
    //计算单位时间内包含的包数
    if(dataFormat.mBytesPerPacket == 0 || dataFormat.mFramesPerPacket == 0)
    {
        size = sizeof(maxPacketSize);
        AudioFileGetProperty(audioFile, kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize);
        if(maxPacketSize > gBufferSizeBytes)
        {
            maxPacketSize = gBufferSizeBytes;
        }
        //算出单位时间内包含的包数
        numPacketsToRead = gBufferSizeBytes/maxPacketSize;
        packetDescs = malloc(sizeof(AudioStreamPacketDescription)*numPacketsToRead);
    }
    else
    {
        numPacketsToRead = gBufferSizeBytes/dataFormat.mBytesPerPacket;
        packetDescs = nil;
    }
    
    //设置magic cookie
    AudioFileGetProperty(audioFile, kAudioFilePropertyMagicCookieData, &size, nil);
    if(size > 0)
    {
        cookie = malloc(sizeof(char)*size);
        AudioFileGetProperty(audioFile, kAudioFilePropertyMagicCookieData, &size, cookie);
        AudioQueueSetProperty(queue, kAudioQueueProperty_MagicCookie, cookie, size);
    }
    
    //创建并分配缓冲空间
    packetIndex = 0;
    for(i = 0; i < NUM_BUFFERS; i++)
    {
        AudioQueueAllocateBuffer(queue, gBufferSizeBytes, &buffers[i]);
        //读取包数据
        if([self readPacketsIntoBuffer:buffers[i]] == 1)
        {
            break;
        }
    }
    
    //    Float32 gain = 1.0;
    //    //音量设置
    //    AudioQueueSetParameter(queue, kAudioQueueParam_Volume, gain);
    //    AudioQueueStart(queue, nil);
    //
    return queue;
}

- (AudioQueueRef)startInterval
{
    UInt32 size,maxPacketSize;
    char *cookie;
    int i;
    OSStatus status;
    
    //打开音频文件
    status = AudioFileOpenURL((CFURLRef)[NSURL fileURLWithPath:audioPath], kAudioFileReadPermission, 0, &audioFile);
    if(status != noErr)
    {
        NSLog(@"*** Error *** PlayAudio - Play:Path could not open audio file. Path given was : %@",audioPath);
        return nil;
    }
    
    for(int i = 0;i < NUM_BUFFERS; i++)
    {
        AudioQueueEnqueueBuffer(queue, buffers[i], 0, nil);
    }
    
    //取得音频数据格式
    size = sizeof(dataFormat);
    AudioFileGetProperty(audioFile, kAudioFilePropertyDataFormat, &size, &dataFormat);
    
    //创建播放用的音频队列
    AudioQueueNewOutput(&dataFormat,BufferCallBack, self, nil, nil, 0, &queue);
    //计算单位时间内包含的包数
    if(dataFormat.mBytesPerPacket == 0 || dataFormat.mFramesPerPacket == 0)
    {
        size = sizeof(maxPacketSize);
        AudioFileGetProperty(audioFile, kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize);
        if(maxPacketSize > gBufferSizeBytes)
        {
            maxPacketSize = gBufferSizeBytes;
        }
        //算出单位时间内包含的包数
        numPacketsToRead = gBufferSizeBytes/maxPacketSize;
        packetDescs = malloc(sizeof(AudioStreamPacketDescription)*numPacketsToRead);
    }
    else
    {
        numPacketsToRead = gBufferSizeBytes/dataFormat.mBytesPerPacket;
        packetDescs = nil;
    }
    
    //设置magic cookie
    AudioFileGetProperty(audioFile, kAudioFilePropertyMagicCookieData, &size, nil);
    if(size > 0)
    {
        cookie = malloc(sizeof(char)*size);
        AudioFileGetProperty(audioFile, kAudioFilePropertyMagicCookieData, &size, cookie);
        AudioQueueSetProperty(queue, kAudioQueueProperty_MagicCookie, cookie, size);
    }
    
    //创建并分配缓冲空间
    packetIndex = 0;
    for(i = 0; i < NUM_BUFFERS; i++)
    {
        AudioQueueAllocateBuffer(queue, gBufferSizeBytes, &buffers[i]);
        //读取包数据
        if([self readPacketsIntoBuffer:buffers[i]] == 1)
        {
            break;
        }
    }
    
//    Float32 gain = 1.0;
//    //音量设置
//    AudioQueueSetParameter(queue, kAudioQueueParam_Volume, gain);
//    AudioQueueStart(queue, nil);
//    
    return queue;

}

//定义回调(Callback)函数
static void BufferCallBack(void *inUserData,AudioQueueRef inAQ,
                          AudioQueueBufferRef buffer)
{
    AudioStreamer *player = (AudioStreamer*)inUserData;
    [player audioQueueOutputWithQueue:inAQ queueBuffer:buffer];
}

//定义缓存数据读取方法
//-(void)audioQueueOutputWithQueue:(AudioQueueRef)audioQueue
//                     queueBuffer:(AudioQueueBufferRef)audioQueueBuffer
-(void)audioQueueOutputWithQueue:(AudioQueueRef)audioQueue
                     queueBuffer:(AudioQueueBufferRef)queueBuffer
{
    OSStatus status;
    
    //读取包数据
    UInt32 numBytes;
    UInt32 numPackets=numPacketsToRead;
    status = AudioFileReadPackets(audioFile, NO, &numBytes, packetDescs, packetIndex,&numPackets, queueBuffer->mAudioData);
    
    //成功读取时
    if (numPackets>0) {
        //将缓冲的容量设置为与读取的音频数据一样大小(确保内存空间)
        queueBuffer->mAudioDataByteSize=numBytes;
        //完成给队列配置缓存的处理
        status = AudioQueueEnqueueBuffer(audioQueue, queueBuffer, numPackets, packetDescs);
        //移动包的位置
        packetIndex += numPackets;
    }
}

-(UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer
{
    UInt32 numBytes,numPackets;
    //从文件中接受数据并保存到缓存(buffer)中
    numPackets = numPacketsToRead;
    AudioFileReadPackets(audioFile, NO, &numBytes, packetDescs, packetIndex, &numPackets, buffer->mAudioData);
    if(numPackets >0){
        buffer->mAudioDataByteSize=numBytes;
        AudioQueueEnqueueBuffer(queue, buffer, (packetDescs ? numPackets : 0), packetDescs);
        packetIndex += numPackets;
    }
    else{
        return 1;//意味着我们没有读到任何的包
    }
    return 0;//0代表正常的退出
}
@end

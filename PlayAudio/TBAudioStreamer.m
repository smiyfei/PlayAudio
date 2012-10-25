//
//  TBAudioStreamer.m
//  PlayAudio
//
//  Created by 杨飞 on 10/25/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import "TBAudioStreamer.h"

@interface TBAudioStreamer()

- (void)handlePropertyChangeForFileStream:(AudioFileStreamID)inAudioFileStream
                     fileStreamPropertyID:(AudioFileStreamPropertyID)inPropertyID
                                  ioFlags:(UInt32 *)ioFlags;

- (void)handleAudioPackets:(const void *)inInputData
               numberBytes:(UInt32)inNumberBytes
             numberPackets:(UInt32)inNumberPackets
        packetDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions;

- (void)handleBufferCompleteForQueue:(AudioQueueRef)inAQ
                              buffer:(AudioQueueBufferRef)inBuffer;

- (void)handlePropertyChangeForQueue:(AudioQueueRef)inAQ
                          propertyID:(AudioQueuePropertyID)inID;

#if TARGET_OS_IPHONE
- (void)handleInterruptionChangeToState:(AudioQueuePropertyID)inInterruptionState;
#endif

- (void)internalSeekToTime:(double)newSeekTime;

- (void)enqueueBuffer;

- (void)handleReadFromStream:(CFReadStreamRef)aStream
                   eventType:(CFStreamEventType)eventType;

@end
static UInt32 gBufferSizeBytes=0x10000;//It muse be pow(2,x)

@interface TBAudioStreamer()

//定义回调(Callback)函数
static void BufferCallack(void *inUserData,AudioQueueRef inAQ,
                          AudioQueueBufferRef buffer);
//定义缓存数据读取方法
-(void)audioQueueOutputWithQueue:(AudioQueueRef)audioQueue
                     queueBuffer:(AudioQueueBufferRef)audioQueueBuffer;
-(UInt32)readPacketsIntoBuffer:(AudioQueueBufferRef)buffer;

@end

#pragma mark Audio Callback Function Implementations

//
// ASPropertyListenerProc
//
// Receives notification when the AudioFileStream has audio packets to be
// played. In response, this function creates the AudioQueue, getting it
// ready to begin playback (playback won't begin until audio packets are
// sent to the queue in ASEnqueueBuffer).
//
// This function is adapted from Apple's example in AudioFileStreamExample with
// kAudioQueueProperty_IsRunning listening added.
//
static void ASPropertyListenerProc(void *						inClientData,
                                   AudioFileStreamID				inAudioFileStream,
                                   AudioFileStreamPropertyID		inPropertyID,
                                   UInt32 *						ioFlags)
{
	// this is called by audio file stream when it finds property values
	TBAudioStreamer* streamer = (TBAudioStreamer *)inClientData;
	[streamer handlePropertyChangeForFileStream:inAudioFileStream
                           fileStreamPropertyID:inPropertyID
                                        ioFlags:ioFlags];
}

//
// ASPacketsProc
//
// When the AudioStream has packets to be played, this function gets an
// idle audio buffer and copies the audio packets into it. The calls to
// ASEnqueueBuffer won't return until there are buffers available (or the
// playback has been stopped).
//
// This function is adapted from Apple's example in AudioFileStreamExample with
// CBR functionality added.
//
static void ASPacketsProc(void *							inClientData,
                          UInt32							inNumberBytes,
                          UInt32							inNumberPackets,
                          const void *					inInputData,
                          AudioStreamPacketDescription	*inPacketDescriptions)
{
	// this is called by audio file stream when it finds packets of audio
	TBAudioStreamer* streamer = (TBAudioStreamer *)inClientData;
	[streamer
     handleAudioPackets:inInputData
     numberBytes:inNumberBytes
     numberPackets:inNumberPackets
     packetDescriptions:inPacketDescriptions];
}

//
// ASAudioQueueOutputCallback
//
// Called from the AudioQueue when playback of specific buffers completes. This
// function signals from the AudioQueue thread to the AudioStream thread that
// the buffer is idle and available for copying data.
//
// This function is unchanged from Apple's example in AudioFileStreamExample.
//
static void ASAudioQueueOutputCallback(void*				inClientData,
                                       AudioQueueRef			inAQ,
                                       AudioQueueBufferRef		inBuffer)
{
	// this is called by the audio queue when it has finished decoding our data.
	// The buffer is now free to be reused.
	TBAudioStreamer* streamer = (TBAudioStreamer*)inClientData;
	[streamer handleBufferCompleteForQueue:inAQ buffer:inBuffer];
}

//
// ASAudioQueueIsRunningCallback
//
// Called from the AudioQueue when playback is started or stopped. This
// information is used to toggle the observable "isPlaying" property and
// set the "finished" flag.
//
static void ASAudioQueueIsRunningCallback(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID)
{
	TBAudioStreamer* streamer = (TBAudioStreamer *)inUserData;
	[streamer handlePropertyChangeForQueue:inAQ propertyID:inID];
}

#if TARGET_OS_IPHONE
//
// ASAudioSessionInterruptionListener
//
// Invoked if the audio session is interrupted (like when the phone rings)
//
static void ASAudioSessionInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	TBAudioStreamer* streamer = (TBAudioStreamer *)inClientData;
	[streamer handleInterruptionChangeToState:inInterruptionState];
}
#endif

#pragma mark CFReadStream Callback Function Implementations

//
// ReadStreamCallBack
//
// This is the callback for the CFReadStream from the network connection. This
// is where all network data is passed to the AudioFileStream.
//
// Invoked when an error occurs, the stream ends or we have data to read.
//
static void ASReadStreamCallBack(CFReadStreamRef aStream,CFStreamEventType eventType,void* inClientInfo)
{
	TBAudioStreamer* streamer = (TBAudioStreamer *)inClientInfo;
	[streamer handleReadFromStream:aStream eventType:eventType];
}

@implementation TBAudioStreamer

@synthesize audioPath;
@synthesize queue;

//web
@synthesize bitRate;
@synthesize httpHeaders;
@synthesize fileExtension;


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

//播放网络文件初始化
- (id)initWithContentsOfURL:(NSURL *)url error:(NSError **)outError
{
    if(self = [super init])
    {
        audioUrl = [url retain];
    }
    
    return self;
}


- (void)dealloc
{
    [audioPath release];
    [super dealloc];
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
    
    Float32 gain = 1.0;
    //音量设置
    AudioQueueSetParameter(queue, kAudioQueueParam_Volume, gain);
    AudioQueueStart(queue, nil);
    
    return queue;

}

//定义回调(Callback)函数
static void BufferCallBack(void *inUserData,AudioQueueRef inAQ,
                          AudioQueueBufferRef buffer)
{
    TBAudioStreamer *player = (TBAudioStreamer*)inUserData;
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


//******************************************************************************************
//*********web
//*********
//******************************************************************************************
//
// startInternal
//
// This is the start method for the AudioStream thread. This thread is created
// because it will be blocked when there are no audio buffers idle (and ready
// to receive audio data).
//
// Activity in this thread:
//	- Creation and cleanup of all AudioFileStream and AudioQueue objects
//	- Receives data from the CFReadStream
//	- AudioFileStream processing
//	- Copying of data from AudioFileStream into audio buffers
//  - Stopping of the thread because of end-of-file
//	- Stopping due to error or failure
//
// Activity *not* in this thread:
//	- AudioQueue playback and notifications (happens in AudioQueue thread)
//  - Actual download of NSURLConnection data (NSURLConnection's thread)
//	- Creation of the AudioStreamer (other, likely "main" thread)
//	- Invocation of -start method (other, likely "main" thread)
//	- User/manual invocation of -stop (other, likely "main" thread)
//
// This method contains bits of the "main" function from Apple's example in
// AudioFileStreamExample.
//
- (void)startInternal
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	@synchronized(self)
	{
//		if (state != AS_STARTING_FILE_THREAD)
//		{
//			if (state != AS_STOPPING &&
//				state != AS_STOPPED)
//			{
//				NSLog(@"### Not starting audio thread. State code is: %ld", (long)state);
//			}
//			self.state = AS_INITIALIZED;
//			[pool release];
//			return;
//		}
		
#if TARGET_OS_IPHONE
		//
		// Set the audio session category so that we continue to play if the
		// iPhone/iPod auto-locks.
		//
		AudioSessionInitialize (
                                NULL,                          // 'NULL' to use the default (main) run loop
                                NULL,                          // 'NULL' to use the default run loop mode
                                ASAudioSessionInterruptionListener,  // a reference to your interruption callback
                                self                       // data to pass to your interruption listener callback
                                );
		UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty (
                                 kAudioSessionProperty_AudioCategory,
                                 sizeof (sessionCategory),
                                 &sessionCategory
                                 );
		AudioSessionSetActive(true);
#endif
        
		// initialize a mutex and condition so that we can block on buffers in use.
		pthread_mutex_init(&queueBuffersMutex, NULL);
		pthread_cond_init(&queueBufferReadyCondition, NULL);
		
		if (![self openReadStream])
		{
			goto cleanup;
		}
	}
	
	//
	// Process the run loop until playback is finished or failed.
	//
	BOOL isRunning = YES;
	do
	{
		isRunning = [[NSRunLoop currentRunLoop]
                     runMode:NSDefaultRunLoopMode
                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
		
		@synchronized(self) {
			if (seekWasRequested) {
				[self internalSeekToTime:requestedSeekTime];
				seekWasRequested = NO;
			}
		}
		
		//
		// If there are no queued buffers, we need to check here since the
		// handleBufferCompleteForQueue:buffer: should not change the state
		// (may not enter the synchronized section).
		//
		if (buffersUsed == 0)
		{
			err = AudioQueuePause(webQueue);
			if (err)
			{
//				[self failWithErrorCode:AS_AUDIO_QUEUE_PAUSE_FAILED];
                NSLog(@"%@",@"AS_AUDIO_QUEUE_PAUSE_FAILED");
				return;
			}
//			self.state = AS_BUFFERING;
		}
//	} while (isRunning && ![self runLoopShouldExit]);
    } while(isRunning);
	
cleanup:
    
	@synchronized(self)
	{
		//
		// Cleanup the read stream if it is still open
		//
		if (stream)
		{
			CFReadStreamClose(stream);
			CFRelease(stream);
			stream = nil;
		}
		
		//
		// Close the audio file strea,
		//
		if (audioFileStream)
		{
			err = AudioFileStreamClose(audioFileStream);
			audioFileStream = nil;
			if (err)
			{
//				[self failWithErrorCode:AS_FILE_STREAM_CLOSE_FAILED];
                NSLog(@"%@",@"AS_FILE_STREAM_CLOSE_FAILED");
			}
		}
		
		//
		// Dispose of the Audio Queue
		//
		if (webQueue)
		{
			err = AudioQueueDispose(webQueue, true);
			webQueue = nil;
			if (err)
			{
//				[self failWithErrorCode:AS_AUDIO_QUEUE_DISPOSE_FAILED];
                NSLog(@"%@",@"AS_AUDIO_QUEUE_DISPOSE_FAILED");
			}
		}
        
		pthread_mutex_destroy(&queueBuffersMutex);
		pthread_cond_destroy(&queueBufferReadyCondition);
        
#if TARGET_OS_IPHONE
		AudioSessionSetActive(false);
#endif
        
		[httpHeaders release];
		httpHeaders = nil;
        
		bytesFilled = 0;
		packetsFilled = 0;
		seekByteOffset = 0;
		packetBufferSize = 0;
//		self.state = AS_INITIALIZED;
        
		[internalThread release];
		internalThread = nil;
	}
    
	[pool release];
}

//
// presentAlertWithTitle:message:
//
// Common code for presenting error dialogs
//
// Parameters:
//    title - title for the dialog
//    message - main test for the dialog
//
- (void)presentAlertWithTitle:(NSString*)title message:(NSString*)message
{
#if TARGET_OS_IPHONE
	UIAlertView *alert = [
                          [[UIAlertView alloc]
                           initWithTitle:title
                           message:message
                           delegate:self
                           cancelButtonTitle:NSLocalizedString(@"OK", @"")
                           otherButtonTitles: nil]
                          autorelease];
	[alert
     performSelector:@selector(show)
     onThread:[NSThread mainThread]
     withObject:nil
     waitUntilDone:NO];
#else
	NSAlert *alert =
    [NSAlert
     alertWithMessageText:title
     defaultButton:NSLocalizedString(@"OK", @"")
     alternateButton:nil
     otherButton:nil
     informativeTextWithFormat:message];
	[alert
     performSelector:@selector(runModal)
     onThread:[NSThread mainThread]
     withObject:nil
     waitUntilDone:NO];
#endif
}

//
// openReadStream
//
// Open the audioFileStream to parse data and the fileHandle as the data
// source.
//
- (BOOL)openReadStream
{
	@synchronized(self)
	{
		NSAssert([[NSThread currentThread] isEqual:internalThread],
                 @"File stream download must be started on the internalThread");
		NSAssert(stream == nil, @"Download stream already initialized");
		
		//
		// Create the HTTP GET request
		//
		CFHTTPMessageRef message= CFHTTPMessageCreateRequest(NULL, (CFStringRef)@"GET", (CFURLRef)audioUrl, kCFHTTPVersion1_1);
		
		//
		// If we are creating this request to seek to a location, set the
		// requested byte range in the headers.
		//
		if (fileLength > 0 && seekByteOffset > 0)
		{
			CFHTTPMessageSetHeaderFieldValue(message, CFSTR("Range"),
                                             (CFStringRef)[NSString stringWithFormat:@"bytes=%d-%d", seekByteOffset, fileLength]);
			discontinuous = YES;
		}
		
		//
		// Create the read stream that will receive data from the HTTP request
		//
		stream = CFReadStreamCreateForHTTPRequest(NULL, message);
		CFRelease(message);
		
		//
		// Enable stream redirection
		//
		if (CFReadStreamSetProperty(
                                    stream,
                                    kCFStreamPropertyHTTPShouldAutoredirect,
                                    kCFBooleanTrue) == false)
		{
			[self presentAlertWithTitle:NSLocalizedStringFromTable(@"File Error", @"Errors", nil)
								message:NSLocalizedStringFromTable(@"Unable to configure network read stream.", @"Errors", nil)];
			return NO;
		}
		
		//
		// Handle proxies
		//
		CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
		CFReadStreamSetProperty(stream, kCFStreamPropertyHTTPProxy, proxySettings);
		CFRelease(proxySettings);
		
		//
		// Handle SSL connections
		//
		if( [[audioUrl absoluteString] rangeOfString:@"https"].location != NSNotFound )
		{
			NSDictionary *sslSettings =
            [NSDictionary dictionaryWithObjectsAndKeys:
             (NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL, kCFStreamSSLLevel,
             [NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredCertificates,
             [NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredRoots,
             [NSNumber numberWithBool:YES], kCFStreamSSLAllowsAnyRoot,
             [NSNumber numberWithBool:NO], kCFStreamSSLValidatesCertificateChain,
             [NSNull null], kCFStreamSSLPeerName,
             nil];
            
			CFReadStreamSetProperty(stream, kCFStreamPropertySSLSettings, sslSettings);
		}
		
		//
		// We're now ready to receive data
		//
//		self.state = AS_WAITING_FOR_DATA;
        
		//
		// Open the stream
		//
		if (!CFReadStreamOpen(stream))
		{
			CFRelease(stream);
			[self presentAlertWithTitle:NSLocalizedStringFromTable(@"File Error", @"Errors", nil)
								message:NSLocalizedStringFromTable(@"Unable to configure network read stream.", @"Errors", nil)];
			return NO;
		}
		
		//
		// Set our callback function to receive the data
		//
		CFStreamClientContext context = {0, self, NULL, NULL, NULL};
		CFReadStreamSetClient(
                              stream,
                              kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered,
                              ASReadStreamCallBack,
                              &context);
		CFReadStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
	}
	
	return YES;
}


@end

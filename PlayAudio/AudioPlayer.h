//
//  TBAudioPlayer.h
//  PlayAudio
//
//  Created by 杨飞 on 10/25/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioToolBox/AudioToolBox.h"

@class PlayLocal;
@class AudioStreamer;
@protocol PlayAudio;

@interface AudioPlayer : NSObject
{    
    double seekTime;//跳转到的时间
    double lastProgress;//最近计算进度点
    
    id<PlayAudio> playAudio;
    
    NSTimer *timer;
}

@property (nonatomic,assign) double seekTime;
@property (readonly) double progress;
@property (readonly) double duration;

/* all data must be in the form of an audio file understood by CoreAudio */
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

@end

//
//  PlayAudio.h
//  PlayAudio
//
//  Created by 杨飞 on 11/1/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PlayAudio <NSObject>

- (void)start;
- (void)stop;
- (void)pause;
- (BOOL)isFinishing;
- (BOOL)isPlaying;
- (BOOL)isPaused;
- (BOOL)isWaiting;
- (BOOL)isIdle;
- (void)seekToTime:(double)newSeekTime;
- (double)calculatedBitRate;
- (float)currentTime;
- (float)duration;

@end

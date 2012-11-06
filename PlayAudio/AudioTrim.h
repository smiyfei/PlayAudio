//
//  AudioTrim.h
//  PlayAudio
//
//  Created by 杨飞 on 10/31/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVAsset.h"
//音频剪切
@interface AudioTrim : NSObject

//avAsset 代表定时视听媒体如视频和声音，可通过AVPlayer获得
//filePath 剪切文件目标路径
- (BOOL)exportAsset:(AVAsset *)avAsset toFilePath:(NSString *)filePath startTime:(CMTime)startTime stopTime:(CMTime)stopTime;

@end

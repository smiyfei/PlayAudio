//
//  AudioTrim.h
//  PlayAudio
//
//  Created by 杨飞 on 10/31/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"

//音频剪切
@interface AudioTrim : NSObject
{
    
}

- (BOOL)exportAsset:(AVAsset *)avAsset toFilePath:(NSString *)filePath;
- (void)trimAudio:(NSString *)audioPath startTime:(CMTime *)startTime endTime:(CMTime *)endTime;

@end

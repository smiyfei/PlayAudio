//
//  AudioTrim.m
//  PlayAudio
//
//  Created by 杨飞 on 10/31/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import "AudioTrim.h"
#import "AVFoundation/AVFoundation.h"

@implementation AudioTrim

- (BOOL)exportAsset:(AVAsset *)avAsset toFilePath:(NSString *)filePath startTime:(CMTime)startTime stopTime:(CMTime)stopTime
{
    CMTime assetTime = [avAsset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
    
    if (duration < 50.0)
    {
        return NO;
    }

    NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
    if ([tracks count] == 0)
    {
        return NO;
    }
    
    AVAssetTrack *track = [tracks objectAtIndex:0];

    // 创建输出线程
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:avAsset
                                           presetName:AVAssetExportPresetAppleM4A];
    if (nil == exportSession)
    {
        return NO;
    }
    
    // create trim time range - 20 seconds starting from 30 seconds into the asset
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    // create fade in time range - 10 seconds starting at the beginning of trimmed asset
    CMTime startFadeInTime = startTime;
    CMTime endFadeInTime = CMTimeMake(40, 1);
    CMTimeRange fadeInTimeRange = CMTimeRangeFromTimeToTime(startFadeInTime,
                                                            endFadeInTime);
    // setup audio mix
    AVMutableAudioMix *exportAudioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *exportAudioMixInputParameters =
    [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    [exportAudioMixInputParameters setVolumeRampFromStartVolume:0.0 toEndVolume:1.0
                                                      timeRange:fadeInTimeRange];
    exportAudioMix.inputParameters = [NSArray
                                      arrayWithObject:exportAudioMixInputParameters];
    // configure export session  output with all our parameters
    exportSession.outputURL = [NSURL fileURLWithPath:filePath]; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    exportSession.timeRange = exportTimeRange; // trim time range
    exportSession.audioMix = exportAudioMix; // fade in audio mix
    // perform the export
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            NSLog(@"AVAssetExportSessionStatusFailed");
        } else {
            NSLog(@"Export Session Status: %d", exportSession.status);
        }
    }];
    
    return YES;
}
@end

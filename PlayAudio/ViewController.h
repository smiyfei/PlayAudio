//
//  ViewController.h
//  PlayAudio
//
//  Created by 杨飞 on 10/24/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioStreamer.h"
#import "AudioTableView.h"
#import "AudioPlayer.h"

@interface ViewController : UIViewController<AudioTableViewDelegate>
{
    AudioPlayer *_audioPlayer;
    
    AudioStreamer *_audio;
    AudioTableView *_audioTableView;
}

@property (nonatomic,retain) AudioPlayer *audioPlayer;
@property (nonatomic, retain) AudioStreamer *audio;
@property (nonatomic,retain) AudioTableView *audioTableView;

- (NSArray *)artworksForFileAtPath:(NSString *)path;

@end

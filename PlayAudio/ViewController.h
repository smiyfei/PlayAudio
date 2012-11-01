//
//  ViewController.h
//  PlayAudio
//
//  Created by 杨飞 on 10/24/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioTableView.h"
@class AudioPlayer;

@interface ViewController : UIViewController<AudioTableViewDelegate>

@property (nonatomic,retain) AudioPlayer *audioPlayer;
@property (nonatomic,retain) AudioTableView *audioTableView;

- (NSArray *)artworksForFileAtPath:(NSString *)path;

@end

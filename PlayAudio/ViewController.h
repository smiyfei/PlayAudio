//
//  ViewController.h
//  PlayAudio
//
//  Created by 杨飞 on 10/24/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioPlayer;

@interface ViewController : UIViewController

@property (nonatomic,retain) AudioPlayer *audioPlayer;

- (NSArray *)artworksForFileAtPath:(NSString *)path;

@end

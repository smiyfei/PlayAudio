//
//  AudioTableViewCell.h
//  PlayAudio
//
//  Created by 杨飞 on 10/24/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioTableViewCell : UITableViewCell
{
    UILabel *_audioName;
    UILabel *_audioDuration;
}

@property (nonatomic,retain) UILabel *audioName;
@property (nonatomic,retain) UILabel *audioDuration;
@end

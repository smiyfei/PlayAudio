//
//  AudioTableViewCell.m
//  PlayAudio
//
//  Created by 杨飞 on 10/24/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import "AudioTableViewCell.h"

@implementation AudioTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _audioName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
        _audioName.text = @"只想一个人";
        
        _audioDuration = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 100, 40)];
        _audioDuration.text = @"03:46";
        
        [self addSubview:_audioName];
        [self addSubview:_audioDuration];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

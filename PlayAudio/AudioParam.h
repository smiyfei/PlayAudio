//
//  AudioParam.h
//  PlayAudio
//
//  Created by 杨飞 on 10/25/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioParam : NSObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *artist;
@property (nonatomic,copy) NSString *album;
@property (nonatomic,copy) NSString *duration;
@property (nonatomic,copy) UIImage  *artwork;

//获取音乐名称、艺术家、插图等信息
- (NSMutableDictionary *)audioParamWithAudioPath:(NSString *)path;
//获取音乐插图
- (NSArray *)artworksForFileAtPath:(NSString *)path;
@end

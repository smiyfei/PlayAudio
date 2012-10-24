//
//  AudioTableView.h
//  PlayAudio
//
//  Created by 杨飞 on 10/24/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AudioTableViewDelegate;

@interface AudioTableView : UITableView<UITableViewDataSource,UITableViewDelegate>
{
    id<AudioTableViewDelegate> _audioDelegate;
}

@property (assign) id<AudioTableViewDelegate> audioDelegate;

@end

@protocol AudioTableViewDelegate <NSObject>
@optional
- (void)AudioTableViewDelegate:(AudioTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)AudioTableViewDelegate:(AudioTableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end


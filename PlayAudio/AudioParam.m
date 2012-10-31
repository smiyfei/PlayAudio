//
//  AudioParam.m
//  PlayAudio
//
//  Created by 杨飞 on 10/25/12.
//  Copyright (c) 2012 self. All rights reserved.
//

#import "AudioParam.h"
#import "AVFoundation/AVFoundation.h"

@implementation AudioParam

@synthesize title;
@synthesize artist;
@synthesize album;
@synthesize duration;
@synthesize artwork;

- (id)init
{
    if (self == [super init]) {
        
    }
    
    return self;
}

- (void)dealloc
{
    [title release];
    [artist release];
    [album release];
    [duration release];
    [artwork release];
    [super dealloc];
}

- (NSMutableDictionary *)audioParamWithAudioPath:(NSString *)path
{
//    NSURL *fileURL=[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"kaibulekou" ofType:@"mp3"]];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    NSString *fileExtension = [[fileURL path] pathExtension];
    NSMutableDictionary *piDict = nil;
    if ([fileExtension isEqual:@"mp3"]||[fileExtension isEqual:@"m4a"])
    {
        AudioFileID fileID  = nil;
        OSStatus err        = noErr;
        
        err = AudioFileOpenURL( (CFURLRef) fileURL, kAudioFileReadPermission, 0, &fileID );//open file
        if( err != noErr ) {
            NSLog( @"AudioFileOpenURL failed" );
        }
        
        UInt32 id3DataSize  = 0;
        err = AudioFileGetPropertyInfo( fileID,   kAudioFilePropertyID3Tag, &id3DataSize, NULL );
        if( err != noErr ) {
            NSLog( @"AudioFileGetPropertyInfo failed for ID3 tag" );
        }

        UInt32 piDataSize   = sizeof( piDict );
        err = AudioFileGetProperty( fileID, kAudioFilePropertyInfoDictionary, &piDataSize, &piDict);
        if( err != noErr ) {
            NSLog( @"AudioFileGetProperty failed for property info dictionary" );
        }

        NSArray *artWorkImages = [self artworksForFileAtPath:path];
        [piDict setObject:artWorkImages forKey:@"artwork"];
    }

    return piDict;
}

- (NSArray *)artworksForFileAtPath:(NSString *)path
{
    //    NSArray *artworkImages = [self artworksForFileAtPath:@"/Users/comtongbu/Downloads/149508041351105261.mp3"];
    //    for (UIImage *image in artworkImages)
    //    {
    //        NSData *imgData = UIImageJPEGRepresentation(image, 0.8);
    //        if (imgData) {
    //            imgData = UIImagePNGRepresentation(image);
    //        }
    //        [imgData writeToFile:@"/Users/comtongbu/Desktop/test.jpg" atomically:YES];
    //    }
    NSMutableArray *artworkImages = [NSMutableArray array];
    NSURL *u = [NSURL fileURLWithPath:path];
    AVURLAsset *a = [AVURLAsset URLAssetWithURL:u options:nil];
    
    NSArray *artworks = [AVMetadataItem metadataItemsFromArray:a.commonMetadata  withKey:AVMetadataCommonKeyArtwork keySpace:AVMetadataKeySpaceCommon];
    
    for (AVMetadataItem *i in artworks)
    {
        NSString *keySpace = i.keySpace;
        UIImage *im = nil;
        
        if ([keySpace isEqualToString:AVMetadataKeySpaceID3])
        {
            NSDictionary *d = [i.value copyWithZone:nil];
            im = [UIImage imageWithData:[d objectForKey:@"data"]];
        }
        else if ([keySpace isEqualToString:AVMetadataKeySpaceiTunes])
            im = [UIImage imageWithData:[i.value copyWithZone:nil]];
        
        if (im)
            [artworkImages addObject:im];
    }
    
    NSLog(@"array description is %@", [artworkImages description]);
    return artworkImages;
    
}
@end

//
//  ImageResize.m
//
//  Created by Florian Rival on 19/11/15.
//  Forked by Jnuine on 02/11/16.
//

#include "RCTImageResizer.h"
#import <React/RCTImageLoader.h>

@implementation ImageResizer

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

bool saveImage(NSString * fullPath, UIImage * image, float quality)
{
    NSData* data = UIImageJPEGRepresentation(image, quality / 100.0);

    if (data == nil) {
        return NO;
    }

    NSFileManager* fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:fullPath contents:data attributes:nil];
    return YES;
}

NSString * generateFilePath() {
    NSString* directory;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    directory = [paths firstObject];

    NSString* name = [[NSUUID UUID] UUIDString];
    NSString* fullName = [NSString stringWithFormat:@"%@.%@", name, @"jpg"];
    NSString* fullPath = [directory stringByAppendingPathComponent:fullName];

    return fullPath;
}

RCT_EXPORT_METHOD(saveImage:(NSString *)path
                  width:(float)width
                  height:(float)height
                  quality:(float)quality
                  callback:(RCTResponseSenderBlock)callback)
{
    CGSize newSize = CGSizeMake(width, height);
    NSString* fullPath = generateFilePath();

    [_bridge.imageLoader loadImageWithURLRequest:[RCTConvert NSURLRequest:path]
                                            size:newSize
                                           scale:1.0
                                         clipped:false
                                      resizeMode:RCTResizeModeContain
                                   progressBlock:nil
                                partialLoadBlock:nil
                                 completionBlock:^(NSError *error, UIImage *image) {
        if (error) {
            callback(@[@"Can't retrieve the file from the path.", @""]);
            return;
        }

        // Compress and save the image
        if (!saveImage(fullPath, image, quality)) {
            callback(@[@"Can't save the image.", @""]);
            return;
        }

        CGSize imageSize = image.size;
        callback(@[[NSNull null], fullPath, @{ @"width": @(imageSize.width), @"height": @(imageSize.height) }]);
    }];
}

@end

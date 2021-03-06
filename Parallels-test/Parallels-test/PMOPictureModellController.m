//
//  PMOPictureModelController.m
//  Parallels-test
//
//  Created by Peter Molnar on 28/04/2016.
//  Copyright © 2016 Peter Molnar. All rights reserved.
//

#import "PMOPictureModellController.h"
#import "PMOPictureDownloaderWithQueues.h"
#import "PMOThumbnailCreator.h"
#import "PMOThumbnailCreatorNotification.h"
#import "PMOPicture.h"
#import "PMODownloadTaskQueues.h"

@implementation PMOPictureModellController

#pragma mark - Accessors
- (UIImage *)image {
    // Small trick: returns back the picture's image or triggers the download
    if (!self.picture.image) {
        [self requestDownloadOfThePictureImage];
    }
    return self.picture.image;
}

- (UIImage *)thumbnailImage {
    // Small trick: returns back the picture's thumbnailImage or triggers the download
    if (!self.picture.image) {
        [self requestDownloadOfThePictureImage];
    }
    return self.picture.thumbnailImage;
}

- (NSString *)imageFileName {
    if (self.picture) {
        return self.picture.imageFileName;
    } else {
        return nil;
    }
}

- (NSString *)imageTitle {
    if (self.picture) {
        return self.picture.imageTitle;
    } else {
        return nil;
    }
}

- (NSString *)imageDescription {
    if (self.picture) {
        return self.picture.imageDescription;
    } else {
        return nil;
    }
}

- (NSString *)pictureKey {
    if (self.picture) {
        return self.picture.pictureKey;
    } else {
        return nil;
    }
}



#pragma mark - observer helpers
- (void)addDownloadObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDownloadNotification:)
                                                 name:PMOPictureDownloaderImageDidDownloaded
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDownloadErrorNotification:) name:PMODataDownloaderError
                                               object:nil];
    
}

- (void)removeDownloadObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PMODataDownloaderDidDownloadEnded
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PMODataDownloaderError
                                                  object:nil];
    
}

#pragma mark - Observer triggers
- (BOOL)isNotificationForThePicture:(NSNotification *)notification {
    NSString *notificationForPictureWithKey = [notification.userInfo valueForKey:@"pictureKey"];
    return [notificationForPictureWithKey isEqualToString:self.pictureKey];
}

- (void)didReceiveDownloadNotification:(NSNotification *)notification {
    
    if ([self isNotificationForThePicture:notification]) {
        [self removeDownloadObservers];
        // Update the model with KVO compliant mode
        [self willChangeValueForKey:@"picture.image"];
        [self.picture setValue:[UIImage imageWithData:[notification.userInfo valueForKey:@"data"]]
                        forKey:@"image"];
        [self didChangeValueForKey:@"picture.image"];
        [self requestThumbnailImageFromImage:self.picture.image];
    }
}

- (void)didReceiveImageTransformationNotification:(NSNotification *) notification {
    
    if ([self isNotificationForThePicture:notification]) {
        // Update the model with KVO compliant mode
        [self willChangeValueForKey:@"thumbnailImage"];
        [self.picture setValue:[notification.userInfo valueForKey:@"image"]
                        forKey:@"thumbnailImage"];
        [self didChangeValueForKey:@"thumbnailImage"];
        
    }
}

- (void)didReceiveDownloadErrorNotification:(NSNotification *)notification {
    
    if ([self isNotificationForThePicture:notification])  {
        [self removeDownloadObservers];
        NSError *error = [notification.userInfo objectForKey:@"error"];
        NSLog(@"Image downlad failed: %@",[error localizedDescription]);
    }
}

#pragma mark - Dynamic image retrieving
- (void)requestDownloadOfThePictureImage {
    
    [self addDownloadObservers];
    PMOPictureDownloaderWithQueues *downloader = [[PMOPictureDownloaderWithQueues alloc] init];
    
    downloader.queues = self.queues;
    downloader.pictureKey = self.pictureKey;
    [downloader downloadDataFromURL:self.picture.imageURL];
}


- (void)requestThumbnailImageFromImage:(UIImage *)image {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveImageTransformationNotification:)
                                                 name:PMOThumbnailImageGenerated
                                               object:nil];
    PMOThumbnailCreator *thumbnailCreator = [[PMOThumbnailCreator alloc] init];
    thumbnailCreator.size = CGSizeMake(88.0, 88.0);
    NSDictionary *options = @{@"pictureKey" : self.pictureKey};
    [thumbnailCreator processData:self.image withOptions:options];
    
    
}

- (void)changePictureDownloadPriorityToHigh {
    [self.queues changeDownloadTaskToHighPriorityQueueFromURL:self.picture.imageURL];
}

- (void)changePictureDownloadPriorityToDefault {
    [self.queues changeDownloadTaskToNormalPriorityQueueFromURL:self.picture.imageURL];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PMOThumbnailImageGenerated
                                                  object:nil];

}
@end

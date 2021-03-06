//
//  PMOPictureModellControllerFactory.m
//  Parallels-test
//
//  Created by Peter Molnar on 05/06/2016.
//  Copyright © 2016 Peter Molnar. All rights reserved.
//

#import "PMOPictureModellControllerFactory.h"
#import "PMOPictureModellController.h"
#import "PMODownloadTaskQueues.h"
#import "PMOPicture.h"

@implementation PMOPictureModellControllerFactory

#pragma mark - Helper functions
+ (NSString *)updateURLAsStringWithTrailingSlash:(NSString *)URLstring {
    
    // Check if the URL ends with slash (/) character.
    if (![[URLstring substringFromIndex:[URLstring length]-1] isEqual:@"/"]) {
        URLstring= [URLstring stringByAppendingString:@"/"];
    }
    return URLstring;
}

+ (PMOPicture *)setupPictureDetailsFromDictionary:(NSDictionary *)pictureDetails  baseURLAsStringForImage:(NSString *)baseURLAsString {
    
    PMOPicture *picture = [[PMOPicture alloc] init];
    
    NSUUID *uuid = [[NSUUID alloc] init];
    [picture setPictureKey:[uuid UUIDString]];
    [picture setImageDescription:[pictureDetails objectForKey:@"description"]];
    [picture setImageFileName:[pictureDetails objectForKey:@"image"]];
    [picture setImageTitle:[pictureDetails objectForKey:@"name"]];
    [picture setImageURL:[NSURL URLWithString:[[self updateURLAsStringWithTrailingSlash:baseURLAsString] stringByAppendingString:picture.imageFileName]]];
    
    return picture;
}

#pragma mark - Factory main function
+ (PMOPictureModellController *)modellControllerFromDictionary:(NSDictionary *)dictionary baseURLAsStringForImage:(NSString *)baseURLAsString downloadQueues:(PMODownloadTaskQueues *)queues {
    
    PMOPictureModellController *modellController = [[PMOPictureModellController alloc] init];
    
    modellController.picture = [self setupPictureDetailsFromDictionary:dictionary
                                               baseURLAsStringForImage:baseURLAsString                                                             ];
    modellController.queues = queues;
    return modellController;
}


@end

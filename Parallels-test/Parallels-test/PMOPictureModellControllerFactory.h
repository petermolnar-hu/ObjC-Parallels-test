//
//  PMOPictureModellControllerFactory.h
//  Parallels-test
//
//  Created by Peter Molnar on 05/06/2016.
//  Copyright © 2016 Peter Molnar. All rights reserved.
//

@import Foundation;

@class PMOPictureModellController;
@class PMODownloadTaskQueues;

@interface PMOPictureModellControllerFactory : NSObject

+ (PMOPictureModellController *)modellControllerFromDictionary:(NSDictionary *)dictionary baseURLAsStringForImage:(NSString *)baseURLAsString downloadQueues:(PMODownloadTaskQueues *)queues;
+ (NSString *)updateURLAsStringWithTrailingSlash:(NSString *)URLstring;

@end

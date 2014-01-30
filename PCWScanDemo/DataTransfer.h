//
//  DataTransfer.h
//  PCWScanDemo
//
//  Created by Kyle Thompson on 1/30/14.
//  Copyright (c) 2014 Prairie Cloudware. All rights reserved.
//

//This is a singleton class to handle data transfer between the device and server

#import <Foundation/Foundation.h>

#define LoginURLString @""

@interface DataTransfer : NSObject {
    
    NSURLConnection * loginConnection;

}


+ (DataTransfer *) sharedManager;  // class method to return the singleton object

- (void) authenticateToServer:(NSString *)userName withPass:(NSString *)pass delegate:(id) loginDelegate;

@end

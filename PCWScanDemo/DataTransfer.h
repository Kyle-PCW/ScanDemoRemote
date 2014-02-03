//
//  DataTransfer.h
//  PCWScanDemo
//
//  Created by Kyle Thompson on 1/30/14.
//  Copyright (c) 2014 Prairie Cloudware. All rights reserved.
//

//This is a singleton class to handle data transfer between the device and server

#import <Foundation/Foundation.h>

#define LoginURLString @"http://localhost:8080/test"

@interface DataTransfer : NSObject {

}


@property (strong, nonatomic) NSURLConnection * loginConnection;
@property (strong, nonatomic) NSMutableData * returnedLoginData;

@property (strong, nonatomic) NSString * accessToken;
@property (strong, nonatomic) NSString * tokenLife;  //number of seconds token is valid


+ (DataTransfer *) sharedManager;  // class method to return the singleton object

- (void) authenticateToServer:(NSString *)userName withPass:(NSString *)pass delegate:(id) loginDelegate;

@end

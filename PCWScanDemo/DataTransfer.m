//
//  DataTransfer.m
//  PCWScanDemo
//
//  Created by Kyle Thompson on 1/30/14.
//  Copyright (c) 2014 Prairie Cloudware. All rights reserved.
//

#import "DataTransfer.h"

@implementation DataTransfer

static DataTransfer * sharedInstance = nil;  //Static instance variable

+ (DataTransfer *) sharedManager{
    if (sharedInstance == nil) {
        sharedInstance = [[super alloc] init];
    }
    return sharedInstance;
}

- (id)init {

    if (self = [super init]) {
        //Custom initialization here
        loginConnection = nil;
    }
    return self;
}


//Method to perfrom the Login request to the server
- (void) authenticateToServer:(NSString *)userName withPass:(NSString *)password delegate:(id) loginDelegate{
    
    
    //Get device info
    UIDevice * device = [[UIDevice alloc] init];
    NSString * UUID = [device.identifierForVendor UUIDString];
    NSString * systemVersion = device.systemVersion;
    
    //Build a NSDictionary to hold the data
    //TODO  -  Update to format from Al
    NSDictionary * loginData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                   // @"Value", @"Key",
                                                    @"UserName",userName,
                                                    @"Password",password,
                                                    @"UUID",UUID,
                                                    @"SystemVersion",systemVersion,
                                                    nil];
    
    //Convert data dictionary int JSON data
    NSLog(@"Creating json with data:\n%@",loginData);
    NSError *error;
    NSData * jsonLoginData = [NSJSONSerialization dataWithJSONObject:loginData
                                                             options:NSJSONWritingPrettyPrinted
                                                               error:&error];
    
    if(!jsonLoginData){
        NSLog(@"Converting to json error: %@",error);
        
        //possibly throw error here to calling object
        return;
    }
    
    //Setup the URL
    NSURL * loginURL = [NSURL URLWithString:LoginURLString]; // LoginURL defined in header file
    
    //Build the request
    NSMutableURLRequest * loginRequest = [[NSMutableURLRequest alloc] init];
    [loginRequest setURL:loginURL];
    [loginRequest setHTTPMethod:@"POST"];
    [loginRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];   //Need to verify this
    [loginRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    //set the body of the request to the json data created above
    [loginRequest setHTTPBody:jsonLoginData];
    
    //Cancel the loginConnection if it is active
    if( loginConnection ){
        [loginConnection cancel];
        loginConnection = nil;
    }
    
    //Set up and start the connection to send the request
    //The request is sent asynchronously and the response will be handeled in the delegate methods
    loginConnection = [[NSURLConnection alloc] initWithRequest:loginRequest delegate:loginDelegate];
    [loginConnection start];
    
}

@end

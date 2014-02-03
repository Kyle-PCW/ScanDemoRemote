//
//  DataTransfer.m
//  PCWScanDemo
//
//  Created by Kyle Thompson on 1/30/14.
//  Copyright (c) 2014 Prairie Cloudware. All rights reserved.
//

#import "DataTransfer.h"

@implementation DataTransfer

@synthesize loginConnection;
@synthesize returnedLoginData;

@synthesize accessToken;
@synthesize tokenLife;

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
  //  NSString * systemVersion = device.systemVersion;
    
    //Build a NSDictionary to hold the data
    //TODO  -  Update to format from Al
    NSDictionary * loginData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                   // @"Value", @"Key",
                                                    @"devLoginRq",@"type",
                                                    UUID,@"req-uuid",
                                                    @"1.0",@"req-version",
                                                    @"null",@"device-id",   //Don't know if this is available
                                                    userName,@"user-id",
                                                    password,@"user-secret",
                                                    UUID,@"UUID",
                                                    nil];
    
    //Convert data dictionary int JSON data
    NSLog(@"Creating json with data:\n%@",loginData);
    NSError *error;
    NSData * jsonLoginData = [NSJSONSerialization dataWithJSONObject:loginData
                                                             options:NSJSONWritingPrettyPrinted
                                                               error:&error];
    
    if(!jsonLoginData){
        NSLog(@"Converting to json error: %@ \n",error);
        
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
        NSLog(@"Previous login request was canceled.\n");
    }
    
    //Set up the connection to send the request
    loginConnection = [[NSURLConnection alloc] initWithRequest:loginRequest delegate:loginDelegate];
    
    //Start the request
    //The request is sent asynchronously and the response will be handeled in the delegate methods
    NSLog(@"Starting login request.\n");
    [loginConnection start];
    
}

@end

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
@synthesize sendDataConnection;

@synthesize returnedLoginData;
@synthesize device;

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
        returnedLoginData = [[NSMutableData alloc] init];
        
        //Get a handle on the device info
        device = [[UIDevice alloc] init];
    }
    return self;
}




//Method to perfrom the Login request to the server
- (void) authenticateToServer:(NSString *)userName withPass:(NSString *)password delegate:(id) loginDelegate{
    
    
    //Get device info
    NSString * UUID = [self.device.identifierForVendor UUIDString];
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
                                                    UUID,@"UUID",           //added this because requ-uuid was causing problems on server
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

// Method to send cardinfo to the server
// Multipart data:  JSON card info and an image of the front of the card
- (void) sendCardInfoToServer:(CardIOCreditCardInfo *) cardInfo withImage:(UIImage *) image delegate:(id) sendCardDelegate{

    //Get device info
    NSString * UUID = [self.device.identifierForVendor UUIDString];
    
    
    //Build a dictionary to hold the card data  //TODO *** define card data and finish building dictionary
    NSDictionary * cardData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                    //@"Value", @"Key",
                                                    cardInfo.cardNumber, @"cardNum",
                                                    cardInfo.cvv, @"cardCVV",
                                                    nil];
    
    //Build a NSDictionary to hold the data
    //TODO  -  Update to format from Al
    NSDictionary * sendData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                // @"Value", @"Key",
                                @"instumentScanRq",@"type",
                                UUID,@"req-uuid",
                                @"1.0",@"req-version",
                                accessToken, @"access-tkn",
                                @"creditCard", @"instr-type",
                                cardData, @"instr-data",
                                nil];
    
    //Convert data dictionary int JSON data
    NSLog(@"Creating json with data:\n%@",sendData);
    NSError *error;
    NSData * jsonSendData = [NSJSONSerialization dataWithJSONObject:sendData
                                                             options:NSJSONWritingPrettyPrinted
                                                               error:&error];
    
    if(!jsonSendData){
        NSLog(@"Converting to json error: %@ \n",error);
        //possibly throw error here to calling object
        return;
    }
    
    //Convert Image to NSData
    NSData * dataImage = UIImageJPEGRepresentation(image, 1.0f);
    
    //Set a name for the Image
    NSString * filename = @"testCardImage";
    
    //Setup the URL
    NSURL * loginURL = [NSURL URLWithString:sendCardURLString]; // LoginURL defined in header file
    
    // Create a 'POST' MutableRequest with Data and other Image Attachment.
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
    [request setURL:loginURL];
    [request setHTTPMethod:@"POST"];
    NSString * boundary = @"---------------------------14737809831466499882746641449";
    NSString * contentType = [NSString stringWithFormat:@"multipart/form-data; boundry=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData * postBody = [NSMutableData data];
    
    //This is a part of the multipart request ********** (JSON)
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"cardInfo\"; \"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"Content-Type: application/json\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[NSData dataWithData:jsonSendData]];
    
    //This is another part of the multipart request ************* (Image data)
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"cardImage\"; filename=\"%@.jpg\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[NSData dataWithData:dataImage]];
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Set the body of the request
    [request setHTTPBody:postBody];
    
    //Cancel the loginConnection if it is active
    if( sendDataConnection ){
        [sendDataConnection cancel];
        sendDataConnection = nil;
        NSLog(@"Previous login request was canceled.\n");
    }
    
    //Set up the connection to send the request
    sendDataConnection = [[NSURLConnection alloc] initWithRequest:request delegate:sendCardDelegate];
    
    //Start the request
    //The request is sent asynchronously and the response will be handeled in the delegate methods
    NSLog(@"Starting sendDataConnection request.\n");
    [sendDataConnection start];
    
}

@end

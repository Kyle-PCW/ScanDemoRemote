//
//  LoginViewController.m
//  PCWScanDemo
//
//  Created by Kyle Thompson on 1/31/14.
//  Copyright (c) 2014 Prairie Cloudware. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize dataTransfer;
@synthesize userIDTextField;
@synthesize userPassTextField;
@synthesize loginActivityIndicator;
@synthesize loginButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self textFieldChangedAction:nil];
    [loginActivityIndicator setHidden:YES];
    
    dataTransfer = [DataTransfer sharedManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonClick:(id)sender {
    
    NSString * uid = userIDTextField.text;
    NSString * pass = userPassTextField.text;
    
    NSLog(@"Calling authenticate to server\n");
    
    [dataTransfer authenticateToServer:uid withPass:pass delegate:self];
    [loginActivityIndicator setHidden:NO];
    [loginActivityIndicator startAnimating];
    
}

- (IBAction)textFieldChangedAction:(id)sender {
    
    int idL = userIDTextField.text.length;
    int pL  = userPassTextField.text.length;
    
    if(idL < 4 || pL < 4){
        [loginButton setEnabled:NO];
    }else{
        [loginButton setEnabled:YES];
    }
    
}

#pragma -mark NSURLConnectionDelegate methods

//**********************************************************
// NSURL DELEGATE METHODS
//**********************************************************

//These methods handle the response from the login request


// This method is called when there is return data.  It may be called multiple times for a connection
// and you should reset the data if it is.
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response{
    
    //reset the data
    [dataTransfer.returnedLoginData setLength:0];
    
}

// This method is called when some or all of the data from the API call is returned.
// We will append the data to the apiReturnXMLData instance variable.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{

    [dataTransfer.returnedLoginData appendData:data];
}

// This method is called when there is a termial error.  There will be no other method calls on this
// connection if it is received.  In this case, we are just going to log the error.
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    [loginActivityIndicator stopAnimating];
    [loginActivityIndicator setHidden:YES];
    
    NSLog(@"Login Connection Failed!  Reason: %@\n",error);
    
    dataTransfer.loginConnection = nil;
}

// This method is called when the call is complete and all the data has been received.
// We will parse the return data from this method.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [loginActivityIndicator stopAnimating];
    [loginActivityIndicator setHidden:YES];
    
    NSLog(@"connectionDidFinishLoading.\n");
    
    dataTransfer.loginConnection = nil;
    
    NSError * error;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:dataTransfer.returnedLoginData options:0 error:&error];
    
    //Check for JSON error
    if(jsonDictionary){
        NSLog(@"Received login response JSON: %@\n", jsonDictionary);
    }else{
        NSLog(@"JSON serialization error: %@",error);
        return;
    }
    
    //Verify the respons is of the devLoginRs type
    if( [jsonDictionary[@"type"] isEqualToString:@"devLoginRs"] ){
        
        //Verify that the response contains the same uuid sent in the request
        UIDevice * device = [[UIDevice alloc] init];
        NSString * myUUID = [[device identifierForVendor] UUIDString];
        NSString * rsUUID = jsonDictionary[@"req-uuid"];
        
        if( ![myUUID isEqualToString:rsUUID] ){
            NSLog(@"ERROR: Response uuid did not match request uuid.\n");
            return;
        }
        
        //Check for error response status
        if( [jsonDictionary[@"resp-status"] isEqualToString:@"error"] ){
            
            //Check the error code and detaiil
            NSDictionary * respDetail = jsonDictionary[@"responseDetail"];
            NSString * code = respDetail[@"code"];
            NSString * message = respDetail[@"message"];
            
            NSLog(@"Login request failed with error code: %@, Message: %@",code,message);
            return;
        }
        
        //If we get to here the were no errors
        //Grab the access token and life
        [dataTransfer setAccessToken:jsonDictionary[@"access-tkn"]];
        [dataTransfer setTokenLife:jsonDictionary[@"access-tkn-life"]];
        
        //Procede to the next screen
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    
    }
    

    
}

@end

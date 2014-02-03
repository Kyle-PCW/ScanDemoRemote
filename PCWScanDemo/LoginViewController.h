//
//  LoginViewController.h
//  PCWScanDemo
//
//  Created by Kyle Thompson on 1/31/14.
//  Copyright (c) 2014 Prairie Cloudware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataTransfer.h"

@interface LoginViewController : UIViewController <NSURLConnectionDelegate>

@property (strong, nonatomic) DataTransfer * dataTransfer;

@property (strong, nonatomic) IBOutlet UITextField *userIDTextField;

@property (strong, nonatomic) IBOutlet UITextField *userPassTextField;

@property (strong, nonatomic) IBOutlet UIButton *loginButton;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicator;


- (IBAction)loginButtonClick:(id)sender;

- (IBAction)textFieldChangedAction:(id)sender;

@end

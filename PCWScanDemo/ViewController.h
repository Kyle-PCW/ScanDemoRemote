//
//  ViewController.h
//  PCWScanDemo
//
//  Created by Kyle Thompson on 1/28/14.
//  Copyright (c) 2014 Prairie Cloudware. All rights reserved.
//

//Tesing change from github


#import <UIKit/UIKit.h>
#import "CardIO.h"


@interface ViewController : UIViewController <CardIOPaymentViewControllerDelegate>


#pragma -mark properties

@property (strong, nonatomic) IBOutlet UIView *cardContainerView;

@property (strong, nonatomic) IBOutlet UILabel *cardNumberLabel;

@property (strong, nonatomic) IBOutlet UILabel *cardNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *cardExpirationLabel;

@property (strong, nonatomic) IBOutlet UILabel *cardCVVLabel;

@property (strong, nonatomic) IBOutlet UIImageView *cardTypeImageView;


#pragma -mark actions
- (IBAction)scanCardButtonAction:(id)sender;

//Method add a space between every 4-digit section
- (NSString *) sectionizeCardNumber:(NSString * ) cardNum;


@end

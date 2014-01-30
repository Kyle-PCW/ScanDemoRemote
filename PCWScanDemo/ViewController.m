//
//  ViewController.m
//  PCWScanDemo
//
//  Created by Kyle Thompson on 1/28/14.
//  Copyright (c) 2014 Prairie Cloudware. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize cardContainerView;
@synthesize cardNumberLabel;
@synthesize cardNameLabel;
@synthesize cardExpirationLabel;
@synthesize cardTypeImageView;
@synthesize cardCVVLabel;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    //Tweak the cardContainerView to look like a credit card
    cardContainerView.layer.masksToBounds = NO;
    cardContainerView.layer.cornerRadius = 8; // if you like rounded corners
    cardContainerView.layer.shadowOffset = CGSizeMake(-10, 15);
    cardContainerView.layer.shadowRadius = 5;
    cardContainerView.layer.shadowOpacity = 0.5;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanCardButtonAction:(id)sender {
    
    
    //If the card view is on the screan, move it off
    //If it's already off, nothing happens
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [cardContainerView setCenter:CGPointMake(160, 600)];
    [UIView commitAnimations];

    //Create the Card.IO view contoller and set app token
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.appToken = CardIOAppToken; // get your app token from the card.io website

    //Display the Card.io view controller
    NSLog(@"%@", @"Presenting the Card.io view contoller");
    [self presentViewController:scanViewController animated:YES completion:nil];

}

//This method takes a contiguous string of numbers and add spaces after every 4 numbers to simulate the look on a credit card
- (NSString *) sectionizeCardNumber:(NSString * ) cardNumStr{
    
    //Check if the input string is a valid length (16 digits)
    if(cardNumStr.length != 16){
        return cardNumStr;
    }
    
    NSMutableString * result = [[NSMutableString alloc] init];
    
    NSString * remainder = [NSString stringWithString:cardNumStr];
    
    //loop through the 4 logical sections of numbers and add a space in between
    //we take 4 digits at a time from the remainder string and add to result, then add a space
    //then we remove those digits from remainder and repeat
    for (int i = 0; i < 3; i++) {
        [result appendString:[remainder substringToIndex:4]];
        [result appendString:@" "];
        remainder = [remainder substringFromIndex:4];
    }
    
    //add the last section of numbers
    [result appendString:remainder];

    return result;
}

#pragma mark - CardIO Delegate

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    NSLog(@"User canceled payment info");
    // Handle user cancellation here...
    
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    
    // The full card number is available as info.cardNumber, but don't log that!
    NSLog(@"Received card info");
    // Use the card info...
    
    //Set the labels for the sudo card view
    
    NSString * sectionedNumber = [self sectionizeCardNumber:info.cardNumber];
    
    [cardNumberLabel setText:sectionedNumber];
    [cardNameLabel setText:@""];  //Why no name returned in card info????
    [cardCVVLabel setText:info.cvv];
    
    //concat the card expiration Month and Year
    
    
    
    NSString * expirationMonth = [[NSNumber numberWithUnsignedInt:(unsigned int)info.expiryMonth] stringValue];
    
    NSString * expirationYear = [[NSNumber numberWithUnsignedInt:(unsigned int)info.expiryYear] stringValue];
    
    NSString * completeExpiration = [expirationMonth stringByAppendingString:@"/"];
    completeExpiration = [completeExpiration stringByAppendingString:expirationYear];
    
    [cardExpirationLabel setText:completeExpiration];
    
    
    //set the card type image for the sudo card
    [cardTypeImageView setImage:[CardIOCreditCardInfo logoForCardType:info.cardType]];
    
    //dismiss the Card.io view controller
    NSLog(@"Dismissing Card.io view contoller");
    [scanViewController dismissViewControllerAnimated:YES completion:^(){
    
        //animate the sudo card view
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [cardContainerView setCenter:self.view.center];
        [UIView commitAnimations];
        
    }];
}

@end
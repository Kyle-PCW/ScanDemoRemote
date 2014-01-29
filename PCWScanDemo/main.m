//
//  main.m
//  PCWScanDemo
//
//  Created by Kyle Thompson on 1/28/14.
//  Copyright (c) 2014 Prairie Cloudware. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        
        @try {
                    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }

        
        

    }
}

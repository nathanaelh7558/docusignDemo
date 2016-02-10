//
//  ViewController.m
//  testDocSign
//
//  Created by Nathanael Holmes on 03/02/2016.
//  Copyright © 2016 Nathanael Holmes. All rights reserved.
//

#import "ViewController.h"
#import <DocuSign-iOS-SDK/DocuSign-iOS-SDK.h>

NSString * const DSIntegratorKey = @"DEMO-cc0db294-5892-458d-8711-a251227dd654";
NSString * const DSEmail = @""; // optional

@interface ViewController () <UINavigationControllerDelegate, DSLoginViewControllerDelegate, DSSigningViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic) DSSessionManager *sessionManager;

@end

@implementation ViewController

-(void)viewDidAppear:(BOOL)animated {
    DSLoginViewController *loginViewController = [[DSLoginViewController alloc]
                                                  initWithIntegratorKey:DSIntegratorKey
                                                  forEnvironment:DSRestAPIEnvironmentDemo
                                                  email:DSEmail
                                                  delegate:self];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)loginViewController:(DSLoginViewController *)controller didLoginWithSessionManager:(DSSessionManager *)sessionManager {
    self.sessionManager = sessionManager;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self.sessionManager startCreateSelfSignEnvelopeTaskWithFileName:nil
                                                             fileURL:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"]]
                                                   completionHandler:^(DSCreateEnvelopeResponse *response, NSError *error) {
                                                       if (error) {
                                                           // Handle the error
                                                           return;
                                                       }
                                                       DSSigningViewController *signingViewController = [self.sessionManager signingViewControllerForRecipientWithID:nil
                                                                                                                                                    inEnvelopeWithID:response.envelopeID
                                                                                                                                                            delegate:self];
                                                       UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:signingViewController];
                                                       [controller presentViewController:navController animated:YES completion:nil];
                                                   }];
    
}
-(void) returntoSender {

}

- (void)loginViewControllerCancelled:(DSLoginViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signingViewController:(DSSigningViewController *)signingViewController completedWithStatus:(DSSigningCompletedStatus)status {
    [self dismissViewControllerAnimated:YES completion:^{
        switch (status) {
            case DSSigningCompletedStatusSigned: {
                // Handle signed envelope
                NSLog(@"Koala Bears");
                break;
            }
            case DSSigningCompletedStatusDeferred:
                // Handle deferred envelope
                break;
            case DSSigningCompletedStatusDeclined:
                // Handle declined envelope
                break;
        }
    }];
}


- (void)signingViewController:(DSSigningViewController *)signingViewController failedWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{
        // handle error
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

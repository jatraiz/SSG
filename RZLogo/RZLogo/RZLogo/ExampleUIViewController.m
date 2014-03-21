//
//  ExampleUIViewController.m
//  RZLogo
//
//  Created by John Stricker on 3/21/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//

#import "ExampleUIViewController.h"
#import "RZLogoViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface ExampleUIViewController ()<UIAccelerometerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) RZLogoViewController *logoView;
@property (strong, nonatomic) CMMotionManager *motionManager;

- (void)handleRotationData:(CMRotationRate)rotation;

@end

@implementation ExampleUIViewController

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
    // Do any additional setup after loading the view from its nib.
    self.logoView = [[RZLogoViewController alloc] init];
    [self.view addSubview:self.logoView.view];
    [self.logoView.view setOpaque:NO];
    
    //the view's frame should be twice as wide as it is tall
    self.logoView.view.frame = CGRectMake(self.view.frame.size.width / 2.0f - 200, self.view.frame.size.height / 2.0f, 400, 200);
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    

}


@end

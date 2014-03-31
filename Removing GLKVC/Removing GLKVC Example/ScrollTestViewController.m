//
//  ScrollTestViewController.m
//  Removing GLKVC Example
//
//  Created by John Stricker on 3/31/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//

#import "ScrollTestViewController.h"
#import "PlainViewController.h"

@interface ScrollTestViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) PlainViewController *glViewController;
@end

@implementation ScrollTestViewController

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
    
    self.glViewController = [PlainViewController new];
    [self.view addSubview:self.glViewController.view];
    [self.glViewController.view setOpaque:NO];
    
    CGRect frame =  CGRectMake(self.view.frame.size.width / 2.0f - 100, self.view.frame.size.height / 2.0f - 50.0f, 200, 100);
    frame.origin.y = 30.0f;
    self.glViewController.view.frame = frame;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIAlertView *uav = [[UIAlertView alloc] initWithTitle:@"TOUCH" message:@"TOUCH" delegate:nil cancelButtonTitle:@"GO AWAY" otherButtonTitles: nil];
    [uav show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

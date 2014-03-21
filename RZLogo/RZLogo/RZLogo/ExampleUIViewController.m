//
//  ExampleUIViewController.m
//  RZLogo
//
//  Created by John Stricker on 3/21/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//

#import "ExampleUIViewController.h"
#import "RZLogoViewController.h"

@interface ExampleUIViewController ()
@property (nonatomic, strong) RZLogoViewController *logoView;
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
    self.logoView.view.frame = CGRectMake(self.view.frame.size.width / 2.0f - 100, self.view.frame.size.height / 2.0f - 50.0f, 200, 100);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  ButtonViewController.m
//  CardDeckExample
//
//  Created by John Stricker on 3/28/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//

#import "ButtonViewController.h"

@interface ButtonViewController ()
- (IBAction)sortPressed:(id)sender;
- (IBAction)stackPressed:(id)sender;
- (IBAction)dealPressed:(id)sender;

@end

@implementation ButtonViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sortPressed:(id)sender {
    [self.delgate buttonViewSortPressed];
}

- (IBAction)stackPressed:(id)sender {
    [self.delgate buttonViewStackPressed];
}

- (IBAction)dealPressed:(id)sender {
    [self.delgate buttonViewDealPressed];
}
@end

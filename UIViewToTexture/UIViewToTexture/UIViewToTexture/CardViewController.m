//
//  CardViewController.m
//  UIViewToTexture
//
//  Created by John Stricker on 4/3/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//

#import "CardViewController.h"

@interface CardViewController ()

@end

@implementation CardViewController

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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.textView.isFirstResponder)
    {
        [self.textView resignFirstResponder];
    }
}

@end

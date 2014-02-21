//
//  SSGHud.m
//  SSGOGLDevSpace
//
//  Created by John Stricker on 12/13/13.
//  Copyright (c) 2013 Sway Software. All rights reserved.
//

#import "SSGHud.h"

@interface SSGHud ()
@property (weak, nonatomic) IBOutlet UIButton *focusButton;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
- (IBAction)actionButtonPressed:(id)sender;
- (IBAction)focusButtonPressed:(id)sender;
- (IBAction)switchChanged:(id)sender;
- (IBAction)resetButtonPressed:(id)sender;
- (NSString*)getStringForTransformationState:(SSGHudTransformationState)state;
- (void)switchToNextTransformationState;
@end

@implementation SSGHud

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _currentState = SSGHudTransformationStateTranslate;
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

- (NSString*)getStringForTransformationState:(SSGHudTransformationState)state
{
    if(state == SSGHudTransformationStateTranslate)
        return @"Translate";
    else if(state == SSGHudTransformationStateRotateX)
        return @"Rotate X";
    else if(state == SSGHudTransformationStateRotateY)
        return @"Rotate Y";
    else if(state == SSGHudTransformationStateRotateZ)
        return @"Rotate Z";
    else
        return @"Undefined";
}

- (void)switchToNextTransformationState
{
    if(_currentState == SSGHudTransformationStateTranslate)
        _currentState = SSGHudTransformationStateRotateX;
    else if(_currentState == SSGHudTransformationStateRotateX)
        _currentState = SSGHudTransformationStateRotateY;
    else if(_currentState == SSGHudTransformationStateRotateY)
        _currentState = SSGHudTransformationStateRotateZ;
    else if(_currentState == SSGHudTransformationStateRotateZ)
        _currentState = SSGHudTransformationStateTranslate;
        }

- (IBAction)actionButtonPressed:(id)sender
{
    [self switchToNextTransformationState];
    [self.actionButton setTitle:[self getStringForTransformationState:self.currentState] forState:UIControlStateNormal];
}

- (IBAction)focusButtonPressed:(id)sender
{
    if(_moveObj)
    {
        self.moveObj = NO;
        [self.focusButton setTitle:@"Camera" forState:UIControlStateNormal];
    }
    else
    {
        self.moveObj = YES;
        [self.focusButton setTitle:@"Object" forState:UIControlStateNormal];
    }
}

- (IBAction)switchChanged:(id)sender
{
    self.switchOn = !_switchOn;
}

- (IBAction)resetButtonPressed:(id)sender {
    if(self.switchOn)
    {
        [self.delegate hudResetToStartingPosition];
    }
}
@end

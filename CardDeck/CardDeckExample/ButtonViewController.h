//
//  ButtonViewController.h
//  CardDeckExample
//
//  Created by John Stricker on 3/28/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ButtonViewControllerDelegate <NSObject>

- (void)buttonViewDealPressed;
- (void)buttonViewStackPressed;
- (void)buttonViewSortPressed;

@end

@interface ButtonViewController : UIViewController
@property (nonatomic, weak) id <ButtonViewControllerDelegate> delgate;
@end

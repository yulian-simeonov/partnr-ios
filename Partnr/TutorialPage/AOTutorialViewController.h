//
//  AOTutorialViewController.h
//  AOTutorial
//
//  Created by Loïc GRIFFIE on 11/10/2013.
//  Copyright (c) 2013 Appsido. All rights reserved.
//

#import <UIKit/UIKit.h>

enum  {
    AOTutorialButtonNone,
    AOTutorialButtonSignup,
    AOTutorialButtonLogin
};
typedef NSUInteger AOTutorialButton;

@interface AOTutorialViewController : UIViewController

/**
 * Used to define which buttons will be shown to the user.
 *
 * @see AOTutorialButton enum.
 */

@property (assign, nonatomic) AOTutorialButton buttons;

/**
 * Header image. Can be used to add a logo
 */

@property (retain, nonatomic) UIImage *header;

/**
 * Signup button
 */

@property (weak, nonatomic) IBOutlet UIButton *signupButton;

/**
 * Login button
 */

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

/**
 * Dismiss button
 */

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

/**
 * Custom init method to create a new AOTutorialController object
 *
 * @param NSArray collection of background images (ie. @[@"bg_1.jpg", @"bg_2.jpg", @"bg_3.jpg"])
 * @param NSArray collection of labels (ie. @[@{@"Header": @"Header 1", @"Label": @"label 1"}, @{@"Header": @"Header 2", @"Label": @"label 2"}, @{@"Header": @"Header 3", @"Label": @"label 3"}])
 *
 * @return AOTutorialController
 */

@property (strong, nonatomic) NSMutableArray *backgroundImages;
@property (strong, nonatomic) NSMutableArray *informationLabels;

- (instancetype)initWithBackgroundImages:(NSArray *)images andInformations:(NSArray *)informations;

/**
 * Load method to setup images and titles
 *
 * @param NSArray collection of background images (ie. @[@"bg_1.jpg", @"bg_2.jpg", @"bg_3.jpg"])
 * @param NSArray collection of labels (ie. @[@{@"Header": @"Header 1", @"Label": @"label 1"}, @{@"Header": @"Header 2", @"Label": @"label 2"}, @{@"Header": @"Header 3", @"Label": @"label 3"}])
 *
 *
 */
- (void)loadBackgroundImages:(NSArray *)images andInformations:(NSArray *)informations;

/**
 * Define a header image
 *
 * @param UIImage image used for header
 */

- (void)setHeaderImage:(UIImage *)logo;

/**
 * Callback for Signup button being touched up
 */

- (IBAction)signup:(id)sender;

/**
 * Callback for Login button being touched up
 */


- (IBAction)login:(id)sender;

/**
 * Callback for Dismiss button being touched up
 */


- (IBAction)dismiss:(id)sender;

@end
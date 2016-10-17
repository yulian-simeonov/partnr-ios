//
//  AOTutorialViewController.m
//  AOTutorial
//
//  Created by Loïc GRIFFIE on 11/10/2013.
//  Copyright (c) 2013 Appsido. All rights reserved.
//

#import "AOTutorialViewController.h"
#import "SharedDataManager-Swift.h"

#define headerLeftMargin    20.0f
#define headerFontSize      15.0f

#define headerFontType      @"Helvetica"
#define headerColor         [UIColor whiteColor]

#define labelLeftMargin     40.0f
#define labelFontSize       12.0f
#define labelFontType       @"Helvetica-Light"
#define labelColor          [UIColor whiteColor]

#define buttonColorTop      @"#FFFFFF"
#define buttonColorBottom   @"#D5D5D5"

#define loginLabelColor     @"#000000"
#define signupLabelColor    @"#B80000"
#define dismissLabelColor   @"#000000"

#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)


@interface UIColor (AOAdditions)

/**
 * Generate UIColor with given Hexadecimal color such as 0x123456
 *
 * @param UInt32 The hexadecimal color
 * @return UIColor translation
 */

+ (UIColor *)colorWithHex:(UInt32)col;

/**
 * Generate UIColor with given Hexadecimal color string representationsuch as #123456
 *
 * @param NSString The hexadecimal color
 * @return UIColor translation
 */

+ (UIColor *)colorWithHexString:(NSString *)str;

@end

@implementation UIColor (AOAdditions)

+ (UIColor *)colorWithHexString:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [UIColor colorWithHex:(int)x];
}

+ (UIColor *)colorWithHex:(UInt32)col {
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}

@end

@interface AOTutorialViewController ()
{
    NSUInteger _index;
    UIButton *readyButton;
}



@property (weak, nonatomic) IBOutlet UIImageView *backgroundBottomImage;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundTopImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;

@property (weak, nonatomic) IBOutlet UIImageView *logo;


@end

@implementation AOTutorialViewController

#pragma mark - Helper function

CGSize ACMStringSize(NSString *string, CGSize size, NSDictionary *attributes)
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:string];
    [textStorage setAttributes:attributes range:NSMakeRange(0, [textStorage length])];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:size];
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    return [layoutManager usedRectForTextContainer:textContainer].size;
}

#pragma mark - Load data
- (void)loadBackgroundImages:(NSArray *)images andInformations:(NSArray *)informations
{
    self.backgroundImages = [NSMutableArray arrayWithArray:images];
    self.informationLabels = [NSMutableArray arrayWithArray:informations];
}

#pragma mark - Life cycle methods

- (instancetype)initWithBackgroundImages:(NSArray *)images andInformations:(NSArray *)informations
{
    if (self = [super initWithNibName:@"AOTutorialViewController" bundle:nil])
    {
        _index = 0;
        _buttons = AOTutorialButtonNone;
        
        [self loadBackgroundImages:images andInformations:informations];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder])
    {
        _index = 0;
        _buttons = AOTutorialButtonNone;
        
        self.backgroundImages = [NSMutableArray array];
        self.informationLabels = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        _index = 0;
        _buttons = AOTutorialButtonNone;
        
        self.backgroundImages = [NSMutableArray array];
        self.informationLabels = [NSMutableArray array];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    [self.view setFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, SCREEN_HEIGHT)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundImages = [[NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Config.plist"]] valueForKeyPath:@"Tutorial.Images"];
    self.informationLabels = [[NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Config.plist"]] valueForKeyPath:@"Tutorial.Labels"];
    
//    if (self.header)
//    {
//        [self.logo setHidden:NO];
//        [self.logo setImage:self.header];
//    }
    self.dismissButton.hidden = YES;
    
    
    [self.pageController setNumberOfPages:[self.backgroundImages count]];
    
    [self layoutViews];
    [self.scrollview setContentSize:CGSizeMake(SCREEN_WIDTH * [self.backgroundImages count], SCREEN_HEIGHT)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self defineLabelLayout];
}

- (void)addButton
{
    [self.loginButton setTitleColor:[UIColor colorWithHexString:loginLabelColor] forState:UIControlStateNormal];
    [self.signupButton setTitleColor:[UIColor colorWithHexString:signupLabelColor] forState:UIControlStateNormal];
    [self.dismissButton setTitleColor:[UIColor colorWithHexString:dismissLabelColor] forState:UIControlStateNormal];
    
    
    [self.dismissButton setHidden:YES];
    
    switch (self.buttons) {
        case AOTutorialButtonSignup:
            [self.signupButton setHidden:NO];
            break;
        case AOTutorialButtonLogin:
            [self.loginButton setHidden:NO];
            break;
        case AOTutorialButtonSignup | AOTutorialButtonLogin:
            [self.signupButton setHidden:NO];
            [self.loginButton setHidden:NO];
            break;
        default:
            [self.signupButton setHidden:YES];
            [self.loginButton setHidden:YES];
            [self.dismissButton setHidden:NO];
    }
}

- (void)layoutViews
{
//    [self addButton];
//    [self addInformationsLabels];
    [self resetBackgroundImageState];
    [self addIamreadyButton];
    [self.backgroundBottomImage setImage:[UIImage imageNamed:[self.backgroundImages objectAtIndex:_index+1]]];
}

- (void)addIamreadyButton
{
    readyButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH * 5) + (SCREEN_WIDTH - 176) / 2, SCREEN_HEIGHT / 2 - 22.5, 176, 45)];
    
    [readyButton setImage:[UIImage imageNamed:@"btn-imready"] forState:UIControlStateNormal];
    readyButton.tag = 1;
    [readyButton addTarget:self action:@selector(onClickImReady:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollview addSubview:readyButton];
}

- (void)addInformationsLabels
{
    NSUInteger index = 0;
    for (NSDictionary *labels in self.informationLabels)
    {
        CGSize hSize = ACMStringSize([labels valueForKey:@"Header"], CGSizeMake(([[UIScreen mainScreen] bounds].size.width - (headerLeftMargin * 2)), 60.0f), [self headerTextStyleAttributes]);
        CGSize lSize = ACMStringSize([labels valueForKey:@"Label"], CGSizeMake(([[UIScreen mainScreen] bounds].size.width - (labelLeftMargin * 2)), 60.0f), [self labelTextStyleAttributes]);
        
        UILabel *header = nil;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            header = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + (SCREEN_WIDTH * index) + headerLeftMargin,
                                                               SCREEN_HEIGHT - 120.0f - lSize.height,
                                                               SCREEN_WIDTH - (headerLeftMargin * 2),
                                                               hSize.height + 5.0f)];
            
        } else {
            
            header = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + (SCREEN_WIDTH * index) + headerLeftMargin,
                                                                        SCREEN_HEIGHT - 120.0f - lSize.height,
                                                                        SCREEN_WIDTH - (headerLeftMargin * 2),
                                                                        hSize.height + 5.0f)];
            
        }

        [header setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
        [header setNumberOfLines:1];
        [header setTag:index];
        [header setLineBreakMode:NSLineBreakByTruncatingTail];
        [header setShadowOffset:CGSizeMake(1, 1)];
        [header setShadowColor:[UIColor blackColor]];
        [header setText:[labels valueForKey:@"Header"]];
        [header setTextAlignment:NSTextAlignmentCenter];
        [header setBackgroundColor:[UIColor clearColor]];
        [header setTextColor:headerColor];
        [header setFont:[UIFont fontWithName:headerFontType size:headerFontSize]];
        
        [self.scrollview addSubview:header];
        
        UILabel *label = nil;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + (SCREEN_WIDTH * index) + labelLeftMargin, header.frame.origin.y + hSize.height + 5.0f, (SCREEN_WIDTH - (labelLeftMargin * 2)), lSize.height)];
            
        } else {
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + (SCREEN_WIDTH * index) + labelLeftMargin, header.frame.origin.y + hSize.height + 5.0f, (SCREEN_WIDTH - (labelLeftMargin * 2)), lSize.height)];
            
        }
        
 
        [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
        [label setNumberOfLines:0];
        [label setTag:index];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [label setShadowOffset:CGSizeMake(1, 1)];
        [label setShadowColor:[UIColor blackColor]];
        [label setText:[labels valueForKey:@"Label"]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:labelColor];
        [label setFont:[UIFont fontWithName:labelFontType size:labelFontSize]];
        [self.scrollview addSubview:label];
        
        index++;
    }
}

- (void)defineLabelLayout
{
    [self.scrollview setContentSize:CGSizeMake(SCREEN_WIDTH * [self.backgroundImages count], SCREEN_HEIGHT)];
    
    for (UIView *v in [self.scrollview subviews])
    {
        if ([v isKindOfClass:[UILabel class]])
        {
            CGRect f = [v frame];
            f.size.width = (SCREEN_WIDTH - (labelLeftMargin * 2));
            f.origin.x = (SCREEN_WIDTH * [v tag]) + labelLeftMargin;
            [v setFrame:f];
        }
    }
    
    [self.scrollview setContentOffset:CGPointMake(SCREEN_WIDTH * _index, self.scrollview.contentOffset.y)];
}

- (void)resetBackgroundImageState
{
    [self.backgroundTopImage setImage:[UIImage imageNamed:[self.backgroundImages objectAtIndex:_index]]];
    [self.backgroundTopImage setAlpha:1.0];
    [self.backgroundBottomImage setAlpha:0.0];
}

- (void)setHeaderImage:(UIImage *)logo
{
    [self setHeader:logo];
}

#pragma mark - Labels methods

- (NSDictionary *)headerTextStyleAttributes
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineSpacing:5.0f];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowBlurRadius = 0.0;
    shadow.shadowOffset = CGSizeMake(1.0, 1.0);
    
    return @{NSFontAttributeName:[UIFont fontWithName:headerFontType size:headerFontSize], NSForegroundColorAttributeName:headerColor, NSParagraphStyleAttributeName:style, NSShadowAttributeName:shadow};
}

- (NSDictionary *)labelTextStyleAttributes
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineSpacing:5.0f];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowBlurRadius = 0.0;
    shadow.shadowOffset = CGSizeMake(1.0, 1.0);
    
    return @{NSFontAttributeName:[UIFont fontWithName:labelFontType size:labelFontSize], NSForegroundColorAttributeName:labelColor, NSParagraphStyleAttributeName:style, NSShadowAttributeName:shadow};
}

#pragma mark - User interface methods

- (IBAction)signup:(id)sender
{
    
}

- (IBAction)login:(id)sender
{
    
}

- (IBAction)dismiss:(id)sender
{
    
}

#pragma mark - Scrollview delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat alpha = [scrollView contentOffset].x / SCREEN_WIDTH - _index;
    
    NSInteger newIndex = (alpha < 0 ? _index-1 : _index+1);
    
    UIImage *nextImage = [UIImage imageNamed:[self.backgroundImages objectAtIndex:(newIndex < 0 ? 0 : (newIndex >= [self.backgroundImages count] ? [self.backgroundImages count]-1 : newIndex))]];
    
    if (![[self.backgroundBottomImage image] isEqual:nextImage]) [self.backgroundBottomImage setImage:nextImage];
     
    [self.backgroundTopImage setAlpha:1-fabs(alpha)];
    [self.backgroundBottomImage setAlpha:fabs(alpha)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.scrollview.frame.size.width;
    _index = floor((self.scrollview.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    [self.pageController setCurrentPage:_index];
    
    [self resetBackgroundImageState];
}

- (void)onClickImReady:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        [SharedDataManager.sharedInstance.rootVC performSegueWithIdentifier:@"ShowWelcome" sender:nil];
    }];
}

@end

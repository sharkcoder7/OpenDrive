//
//  WelcomeVC.m
//  OpenDrive
//
//  Created by ioshero on 12/27/15.
//  Copyright © 2015 ioshero. All rights reserved.
//

#import "WelcomeVC.h"
#import "OVBounceAnimation.h"

@interface WelcomeVC ()

@property (strong, nonatomic) IBOutlet UIImageView *imageViewLogo;
@property (strong, nonatomic) IBOutlet UIButton *buttonSignUp;
@property (strong, nonatomic) IBOutlet UIButton *buttonLogin;

@property (assign, nonatomic) CGRect rtSignUpOriginal;
@property (assign, nonatomic) CGRect rtLoginOriginal;

@property (assign, nonatomic) CGRect rtSignUp;
@property (assign, nonatomic) CGRect rtLogin;

@property (strong, nonatomic) NSTimer* timerAnimation;

- (void)initialize;
- (void)initAnimation;
- (void)addBounceAnimation:(UIView*)button distance:(CGFloat)length;

@end

@implementation WelcomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    static BOOL isAnimate = NO;
    if (!isAnimate)
    {
        isAnimate = YES;
        
        [self initialize];
        [self initAnimation];
    }
}

- (void)viewDidLayoutSubviews
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)initialize
{
    _rtSignUpOriginal = _buttonSignUp.frame;
    _rtLoginOriginal = _buttonLogin.frame;
    
    _rtLogin = _rtLoginOriginal;
    _rtLogin.origin.y = -_rtLoginOriginal.size.height;
    [_buttonLogin setFrame:_rtLogin];
    
    _rtSignUp = _rtSignUpOriginal;
    _rtSignUp.origin.y = -_rtSignUpOriginal.size.height;
    [_buttonSignUp setFrame:_rtSignUp];
}

- (void)initAnimation
{
    CGFloat moveDistance = _rtLoginOriginal.origin.y + _rtLoginOriginal.size.height;
    [self addBounceAnimation:_buttonLogin distance:moveDistance];
    
    moveDistance = _rtSignUpOriginal.origin.y + _rtSignUpOriginal.size.height;
    [self addBounceAnimation:_buttonSignUp distance:moveDistance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addBounceAnimation:(UIView*)target distance:(CGFloat)length
{
    NSString *keyPath = @"position.y";
    id finalValue = [NSNumber numberWithFloat:length];
    
    OVBounceAnimation *bounceAnimation = [OVBounceAnimation animationWithKeyPath:keyPath];
    bounceAnimation.fromValue = [NSNumber numberWithFloat:target.frame.origin.y];
    bounceAnimation.toValue = finalValue;
    bounceAnimation.duration = 2.5f;
    bounceAnimation.numberOfBounces = 4;
    bounceAnimation.stiffness = OVBounceAnimationStiffnessLight;
    bounceAnimation.shouldOvershoot = YES;
    
    [target.layer addAnimation:bounceAnimation forKey:@"someKey"];
    [target.layer setValue:finalValue forKeyPath:keyPath];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

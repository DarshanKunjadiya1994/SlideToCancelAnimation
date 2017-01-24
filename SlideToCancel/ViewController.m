//
//  ViewController.m
//  SlideToCancel
//
//  Created by Darshan Kunjadiya on 24/01/17.
//  Copyright © 2017 Darshan Kunjadiya. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

static const CGFloat kScrapDriveUpAnimationHeight = 200;

static NSString *kAnimationNameKey = @"animation_name";
static NSString *kScrapDriveUpAnimationName = @"scrap_drive_up_animation";
static NSString *kScrapDriveDownAnimationName = @"scrap_drive_down_animation";
static NSString *kBucketDriveUpAnimationName = @"bucket_drive_up_animation";
static NSString *kBucketDriveDownAnimationName = @"bucket_drive_down_animation";

@implementation ViewController

- (void)viewDidLoad {
    
    [self manageTextView];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)manageTextView
{
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, kScreenWidth, 50)];
    containerView.backgroundColor=[UIColor blackColor];
    
    txtMessage = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(35, 8, kScreenWidth - 80, 50)];
    txtMessage.isScrollable = YES;
    txtMessage.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    txtMessage.minNumberOfLines = 1;
    txtMessage.maxNumberOfLines = 6;
    
    // you can also set the maximum height in points with maxHeight
    txtMessage.returnKeyType = UIReturnKeyGo; //just as an example
    txtMessage.font = [UIFont systemFontOfSize:15];
    txtMessage.delegate = self;
    txtMessage.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    txtMessage.backgroundColor = [UIColor whiteColor];
    txtMessage.placeholder = @"What do you have to say?";
    txtMessage.returnKeyType=UIReturnKeyDefault;
    txtMessage.animateHeightChange = NO; //turns off animation
    [self.view addSubview:containerView];
    txtMessage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    // view hierachy
    [containerView addSubview:txtMessage];
    
    
    
    audioBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    audioBtn.frame = CGRectMake(containerView.frame.size.width - 50, 12, 50, 27);
    audioBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [audioBtn setImage:[UIImage imageNamed:@"inline-mic-icon.png"] forState:UIControlStateNormal];
    [audioBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    audioBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    [audioBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(onLongPressAudio:)];
    [audioBtn addGestureRecognizer:lpgr];
    [containerView addSubview:audioBtn];
    
    audioContainer=[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-40, 50)];
    audioContainer.backgroundColor=[UIColor blackColor];
    [containerView addSubview:audioContainer];
    audioContainer.hidden=true;
    
    lblSlideCancel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, audioContainer.bounds.size.width, 50)];
    lblSlideCancel.center=audioContainer.center;
    lblSlideCancel.text=@"       slide to cancel";
    lblSlideCancel.textColor=[UIColor whiteColor];
    lblSlideCancel.font=[UIFont systemFontOfSize:18];
    lblSlideCancel.textAlignment=NSTextAlignmentCenter;
    [audioContainer addSubview:lblSlideCancel];
    [self AddShineAnimationToView:lblSlideCancel];
    
    lblAudioRecord=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
    lblAudioRecord.text=@"        0:00";
    [lblAudioRecord adjustsFontSizeToFitWidth];
    lblAudioRecord.backgroundColor=[UIColor blackColor];
    lblAudioRecord.textColor=[UIColor whiteColor];
    lblAudioRecord.font=[UIFont fontWithName:@"CircularStd-Book" size:18];
    lblAudioRecord.textAlignment=NSTextAlignmentLeft;
    [audioContainer addSubview:lblAudioRecord];
    
    // set animation duration
    self.duration = 0.6;
    self.bucketContainerLayer.zPosition = 98;
    self.scrapLayer.zPosition = 97;
    
    
    CGRect rect = [self CGRectIntegralCenteredInRect:CGRectMake(0, 0, 200, 40) withRect:self.view.frame];
    self.baseviewYOrigin = rect.origin.y + 100;
    
    // scrap layer
    UIImage *img = [UIImage imageNamed:@"input_mic.png"];
    rect = [self CGRectIntegralCenteredInRect:CGRectMake(0, 200, img.size.width - 5, img.size.height - 5) withRect:self.view.frame];
    rect.origin.x=10;
    rect.origin.y = kScreenHeight-38;
    
    self.scrapLayer = [CALayer layer];
    self.scrapLayer.frame = rect;
    self.scrapLayer.bounds = rect;
    [self.scrapLayer setContents:(id)img.CGImage];
    [self.view.layer addSublayer:self.scrapLayer];
    
    self.scrapLayer.hidden=true;
    
    // trash layer
    rect.origin.x=5;
    rect.origin.y = kScreenHeight-37;
    
    self.bucketContainerLayer = [CALayer layer];
    self.bucketContainerLayer.frame = rect;
    self.bucketContainerLayer.bounds = rect;
    self.bucketContainerLayer.hidden = YES;
    [self.view.layer addSublayer:self.bucketContainerLayer];
    
    
    // bucket layer
    CGRect centeredRect = [self CGRectIntegralCenteredInRect:CGRectMake(0, 0, 22, 20 + 12) withRect:rect]; //image size(20x32)
    centeredRect.origin.x = CGRectGetMinX(rect);
    centeredRect.origin.y = kScreenHeight-35;
    
    self.bucket = [[GLBucket alloc] initWithFrame:centeredRect inLayer:self.bucketContainerLayer];
    self.bucket.bucketStyle = BucketStyle2OpenFromRight;
    
    
    // set bucket-container-layer actual y origin
    self.bucketContainerLayerActualYPos = kScreenHeight-35; //divide by 2 considering center from y-
    
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

#pragma mark Audio Click
-(void)onLongPressAudio:(UILongPressGestureRecognizer*)pGesture
{
    
    if (pGesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
        
        CGPoint translation = [pGesture locationInView:self.view];
        NSLog(@"Swipe - start location: %f,%f", translation.x, translation.y);
        if (translation.x < kScreenWidth-kScreenWidth/2.8) {
            [self scrapDriveUpAnimation];
        } else {
            
            //Temp code
            audioContainer.hidden=true;
            self.scrapLayer.hidden=true;
            self.bucketContainerLayer.hidden = YES;
        }
        // Back to the original position
        [containerView addSubview:audioBtn];
        lblSlideCancel.frame=CGRectMake(0, 0, audioContainer.frame.size.width, lblSlideCancel.bounds.size.height);
        audioBtn.frame = CGRectMake(containerView.frame.size.width - 50, 12, 50, 27);
    }
    else if (pGesture.state == UIGestureRecognizerStateBegan){
        
        [audioContainer addSubview:audioBtn];
        [audioContainer bringSubviewToFront:lblAudioRecord];
        
        audioContainer.hidden=false;
        self.scrapLayer.hidden=false;
        
        lblAudioRecord.text=@"        0:00";
        
        NSLog(@"start");
        
    } else if (pGesture.state ==  UISwipeGestureRecognizerDirectionLeft) {
        
        NSLog(@"Left");
        
        CGPoint translation = [pGesture locationInView:self.view];
        NSLog(@"Swipe - start location: %f,%f", translation.x, translation.y);
        
        lblSlideCancel.frame=CGRectMake(translation.x-lblSlideCancel.bounds.size.width, 0, lblSlideCancel.bounds.size.width, lblSlideCancel.bounds.size.height);
        audioBtn.frame=CGRectMake(translation.x-audioBtn.bounds.size.width/2, 12, audioBtn.bounds.size.width, audioBtn.bounds.size.height);
        
        if (translation.x < kScreenWidth-kScreenWidth/2.8) {
            [pGesture setValue:@(UIGestureRecognizerStateEnded) forKey:@"state"];
        }
    }
}

-(void)audioTimerGM
{
    
}

#pragma mark - Animation boilerplate
- (void)scrapDriveUpAnimation
{
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnimation.fromValue = [NSValue valueWithCGPoint:self.scrapLayer.position];
    moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.scrapLayer.frame), CGRectGetMidY(self.scrapLayer.frame) - kScrapDriveUpAnimationHeight)];
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeForwards;
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    NSArray* keyFrameValues = @[
                                @(0.0),
                                @(M_PI),
                                @(M_PI*1.5),
                                @(M_PI*2.0)
                                ];
    CAKeyframeAnimation* rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    [rotateAnimation setValues:keyFrameValues];
    [rotateAnimation setValueFunction:[CAValueFunction functionWithName: kCAValueFunctionRotateZ]];
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.fillMode = kCAFillModeForwards;
    rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.delegate = self;
    [animGroup setValue:kScrapDriveUpAnimationName forKey:kAnimationNameKey];
    animGroup.animations = @[moveAnimation, rotateAnimation];
    animGroup.duration = self.duration;
    animGroup.removedOnCompletion = NO;
    animGroup.fillMode = kCAFillModeForwards;
    [self.scrapLayer addAnimation:animGroup forKey:nil];
}

- (void)scrapDriveDownAnimation
{
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnimation.delegate = self;
    [moveAnimation setValue:kScrapDriveDownAnimationName forKey:kAnimationNameKey];
    moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.scrapLayer.position.x, self.scrapLayer.position.y - 5)];
    moveAnimation.duration = self.duration;
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeForwards;
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.scrapLayer addAnimation:moveAnimation forKey:nil];
}

- (void)bucketDriveUpAnimation
{
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnimation.delegate = self;
    [moveAnimation setValue:kBucketDriveUpAnimationName forKey:kAnimationNameKey];
    moveAnimation.fromValue = [NSValue valueWithCGPoint:self.bucketContainerLayer.position];
    moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.scrapLayer.frame), self.bucketContainerLayerActualYPos)];
    moveAnimation.duration = self.duration;
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeForwards;
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.bucketContainerLayer addAnimation:moveAnimation forKey:nil];
}

- (void)bucketDriveDownAnimation
{
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnimation.delegate = self;
    [moveAnimation setValue:kBucketDriveDownAnimationName forKey:kAnimationNameKey];
    moveAnimation.toValue = [NSValue valueWithCGPoint:self.bucketContainerLayer.position];
    moveAnimation.duration = self.duration;
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeForwards;
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.bucketContainerLayer addAnimation:moveAnimation forKey:nil];
}

#pragma mark - Animation Delegate methods

- (void)animationDidStart:(CAAnimation *)anim
{
    NSString *animationName = [anim valueForKey:kAnimationNameKey];
    if ([animationName isEqualToString:kScrapDriveDownAnimationName]) {
        [self bucketDriveUpAnimation];
        
    } else if ([animationName isEqualToString:kBucketDriveUpAnimationName]) {
        self.bucketContainerLayer.hidden = NO;
        [self.bucket performSelector:@selector(openBucket) withObject:nil afterDelay:self.duration * 0.3];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        NSString *animationName = [anim valueForKey:kAnimationNameKey];
        if ([animationName isEqualToString:kScrapDriveUpAnimationName]) {
            [self performSelector:@selector(scrapDriveDownAnimation) withObject:nil afterDelay:self.duration * 0.1];
            
        } else if ([animationName isEqualToString:kScrapDriveDownAnimationName]) {
            self.scrapLayer.hidden = YES;
            [self.bucket performSelector:@selector(closeBucket) withObject:nil afterDelay:self.duration * 0.1];
            [self performSelector:@selector(bucketDriveDownAnimation) withObject:nil afterDelay:self.duration * 1.0];
            
        } else if ([animationName isEqualToString:kBucketDriveDownAnimationName]) {
            audioContainer.hidden=true;
            self.scrapLayer.hidden=true;
            self.bucketContainerLayer.hidden = YES;
        }
    }
}


// Add shine animation to View
-(void)AddShineAnimationToView:(UILabel*)aView
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [gradient setStartPoint:CGPointMake(0, 0)];
    [gradient setEndPoint:CGPointMake(1, 0)];
    gradient.frame = CGRectMake(0, 0, aView.bounds.size.width*3, aView.bounds.size.height);
    float lowerAlpha = 0.78;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithWhite:1 alpha:lowerAlpha] CGColor],
                       (id)[[UIColor colorWithWhite:1 alpha:lowerAlpha] CGColor],
                       (id)[[UIColor colorWithWhite:1 alpha:1.0] CGColor],
                       (id)[[UIColor colorWithWhite:1 alpha:1.0] CGColor],
                       (id)[[UIColor colorWithWhite:1 alpha:1.0] CGColor],
                       (id)[[UIColor colorWithWhite:1 alpha:lowerAlpha] CGColor],
                       (id)[[UIColor colorWithWhite:1 alpha:lowerAlpha] CGColor],
                       nil];
    
    gradient.locations = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.0],
                          [NSNumber numberWithFloat:0.4],
                          [NSNumber numberWithFloat:0.45],
                          [NSNumber numberWithFloat:0.5],
                          [NSNumber numberWithFloat:0.55],
                          [NSNumber numberWithFloat:0.6],
                          [NSNumber numberWithFloat:1.0],
                          nil];
    
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    theAnimation.duration = 2;
    theAnimation.repeatCount = INFINITY;
    theAnimation.autoreverses = NO;
    theAnimation.removedOnCompletion = NO;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.fromValue=[NSNumber numberWithFloat:-aView.frame.size.width*2];
    theAnimation.toValue=[NSNumber numberWithFloat:0];
    [gradient addAnimation:theAnimation forKey:@"animateLayer"];
    
    aView.layer.mask = gradient;
}


// Get center Rect
- (CGRect)CGRectIntegralCenteredInRect:(CGRect)innerRect withRect:(CGRect)outerRect
{
    CGFloat originX = floorf((outerRect.size.width - innerRect.size.width) * 0.5f);
    CGFloat originY = floorf((outerRect.size.height - innerRect.size.height) * 0.5f);
    CGRect bounds = CGRectMake(originX, originY, innerRect.size.width, innerRect.size.height);
    return bounds;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

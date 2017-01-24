//
//  ViewController.h
//  SlideToCancel
//
//  Created by Darshan Kunjadiya on 24/01/17.
//  Copyright © 2017 Darshan Kunjadiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLBucket.h"
#import "HPGrowingTextView.h"

@interface ViewController : UIViewController<HPGrowingTextViewDelegate,UIGestureRecognizerDelegate,CAAnimationDelegate>
{
    UIView *containerView;
    HPGrowingTextView *txtMessage;
    UIButton *doneBtn;
    UIButton *audioBtn;
    UIButton *imgBtn;
    
    UILabel *lblSlideCancel;
    UIView *audioContainer;
    UILabel *lblAudioRecord;

}
@property (nonatomic, strong) CALayer *scrapLayer;
@property (nonatomic, strong) CALayer *bucketContainerLayer;
@property (nonatomic, strong) GLBucket *bucket;
@property (nonatomic, assign) CFTimeInterval duration;
@property (nonatomic, assign) CGFloat baseviewYOrigin;
@property (nonatomic, assign) CGFloat bucketContainerLayerActualYPos;

@end


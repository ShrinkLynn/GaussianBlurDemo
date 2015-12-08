//
//  ViewController.m
//  blurAnimation
//
//  Created by lynn on 15/12/3.
//  Copyright © 2015年 lynn. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

#import "SecondViewController.h"

@interface ViewController ()
@property (nonatomic,strong) UIImageView *imgView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _imgView.backgroundColor = [UIColor greenColor];
    _imgView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:_imgView];
    [self.view bringSubviewToFront:self.imgView];

    SecondViewController *vc = [[SecondViewController alloc]init];
    //后台执行：
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        
        NSLog(@"begin");
        //截图
        NSInteger width = vc.view.frame.size.width;
        NSInteger heihgt = vc.view.frame.size.height;
        CGSize size = CGSizeMake(width,heihgt);
        UIGraphicsBeginImageContext(size);
        [vc.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imgView.image = [self blurryImage:image withBlurLevel:0.05f];
        });
        NSLog(@"end");
    });
    
    
    
    
    
    
    
    
    //效率低
    //        UIImage *backgroundImage = [UIImage imageNamed:@"bgimage"];
    //        //reduce the image quality
    //        NSData *imgData = UIImageJPEGRepresentation(backgroundImage,0.1);
    //
    //        CIContext *context = [CIContext contextWithOptions:nil];
    //        CIImage *CIimage = [CIImage imageWithData:imgData];
    //        CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    //        [filter setValue:CIimage forKey:kCIInputImageKey];
    //        [filter setValue:@2.0f forKey: @"inputRadius"];
    //        CIImage *result = [filter valueForKey:kCIOutputImageKey];
    //        CGImageRef outImage = [context createCGImage: result fromRect:[result extent]];
    //        UIImage * blurImage = [UIImage imageWithCGImage:outImage];
    //        
    //        imgView.image = blurImage;
    
}

//毛玻璃效果。
- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 100);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) *
                         CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer,
                                       &outBuffer,
                                       NULL,
                                       0,
                                       0,
                                       boxSize,
                                       boxSize,
                                       NULL,
                                       kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

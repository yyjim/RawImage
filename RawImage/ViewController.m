//
//  ViewController.m
//  RawImage
//
//  Created by yyjim on 9/6/16.
//  Copyright © 2016 cardinalblue. All rights reserved.
//


#import "ViewController.h"

typedef struct RGBAPixel
{
    Byte alpha;
    Byte red;
    Byte green;
    Byte blue;
    
} RGBAPixel;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"test.png"];
    
    CGContextRef context = CGBitmapContextCreateWithARGB(image.size);
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height),
                       image.CGImage);
    
    NSMutableArray *pixelsArray = [NSMutableArray array];
    
    const RGBAPixel* pixels = (const RGBAPixel*)CGBitmapContextGetData(context);
    NSInteger height = image.size.height;
    NSInteger width  = image.size.width;
    for (NSUInteger y = 0; y < height; y++) {
        for (NSUInteger x = 0; x < width; x++) {
            const NSUInteger index = x + y * width;
            RGBAPixel pixel = pixels[index];
            NSValue *v = [NSValue value:&pixel withObjCType:@encode(RGBAPixel)];
//            Byte a = pixel.alpha;
//            Byte r = pixel.red;
//            Byte g = pixel.green;
//            Byte b = pixel.blue;
//            NSLog(@"a:%@, r:%@, g:%@, b:%@", @(a), @(r), @(g), @(b));
            [pixelsArray addObject:v];
        }
    }
    CGContextRelease(context);

    //UIImage *outImage  = [self createImageFromARGBPixels:pixels];
    UIImage *outImage2 = [self createImageFromARGBArray:pixelsArray];
}

- (UIImage *)createImageFromARGBPixels:(RGBAPixel *)pixels
{
    UIImage *image = [UIImage imageNamed:@"test.png"];
    CGSize size = image.size;
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaPremultipliedFirst;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels,
                                                 size.width,
                                                 size.height,
                                                 8,
                                                 size.width * 4,
                                                 colorSpace,
                                                 bitmapInfo);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *outImage = [UIImage imageWithCGImage:imageRef];
    return outImage;

}

- (UIImage *)createImageFromARGBArray:(NSArray<NSValue *> *)array
{
    UIImage *image = [UIImage imageNamed:@"test.png"];
    CGSize size = image.size;
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaPremultipliedFirst;
    
    RGBAPixel *pixels = malloc(size.height * size.width * sizeof(RGBAPixel));
    RGBAPixel *pixel = pixels;
    for (int i = 0; i < array.count; i++) {
        NSValue *value = array[i];
        RGBAPixel _pixel;
        [value getValue:&_pixel];
        *pixel++ = _pixel;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels,
                                                 size.width,
                                                 size.height,
                                                 8,
                                                 size.width * 4,
                                                 colorSpace,
                                                 bitmapInfo);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *outImage = [UIImage imageWithCGImage:imageRef];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(pixels);
    return outImage;
}


CGContextRef CGBitmapContextCreateWithARGB(CGSize size)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    void *bitmapData = malloc(size.width * size.height * 4);
    if (bitmapData == NULL) {
        fprintf (stderr, "Error: Memory not allocated!");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    // From CGBitmapContext Reference
    // bitmapInfo:
    //  The constants for specifying the alpha channel information are declared with the CGImageAlphaInfo type
    //  but can be passed to this parameter safely.
    // Casting to avoid compiler warning.
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaPremultipliedFirst;
    
    CGContextRef context = CGBitmapContextCreate(bitmapData,
                                                 size.width,
                                                 size.height,
                                                 8,
                                                 size.width * 4,
                                                 colorSpace,
                                                 bitmapInfo);
    
    CGColorSpaceRelease(colorSpace );
    if (context == NULL) {
        fprintf (stderr, "Error: Context not created!");
        free (bitmapData);
        return NULL;
    }
    return context;
}


@end

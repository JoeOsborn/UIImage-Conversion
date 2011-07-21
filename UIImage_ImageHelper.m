/*
 * The MIT License
 *
 * Copyright (c) 2011 Paul Solt, PaulSolt@gmail.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "UIImage_ImageHelper.h"


@implementation UIImage(ImageHelper)


- (unsigned char *)newBRGA8Bitmap {
	CGImageRef image = self.CGImage;
	CGContextRef context = NULL;
	CGColorSpaceRef colorSpace;
	uint8_t *bitmapData;
	
	size_t bitsPerPixel = 32;
	size_t bitsPerComponent = 8;
	size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
	
	size_t width = CGImageGetWidth(image);
	size_t height = CGImageGetHeight(image);
	
	size_t bytesPerRow = width * bytesPerPixel;
	size_t bufferLength = bytesPerRow * height;
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	if(!colorSpace) {
		NSLog(@"Error allocating color space RGB\n");
		return NULL;
	}
	
	// Allocate memory for image data
	bitmapData = (uint8_t *)malloc(sizeof(uint8_t)*bufferLength);
	
	if(!bitmapData) {
		NSLog(@"Error allocating memory for bitmap\n");
		CGColorSpaceRelease(colorSpace);
		return NULL;
	}
	
	//Also known as "BGRA8", thank you Duncan http://osdir.com/ml/quartz-dev/2009-05/msg00031.html
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
	
	//Create bitmap context with this memory block (which we still own, 
	//although we will transfer ownership to the caller on return).
	context = CGBitmapContextCreate(bitmapData, 
																	width, 
																	height, 
																	bitsPerComponent, 
																	bytesPerRow, 
																	colorSpace, 
																	bitmapInfo);	// RGBA
	
	if(!context) {
		free(bitmapData);
		NSLog(@"Bitmap context not created");
	}
	
	CGColorSpaceRelease(colorSpace);
	
	if(!context) {
		return NULL;
	}
	
	CGRect rect = CGRectMake(0, 0, width, height);
	
	// Draw image into the context to get the raw image data
	CGContextDrawImage(context, rect, image);

	CGContextRelease(context);
	
	return bitmapData;	
}

+ (UIImage *)imageWithSize:(CGSize)size
					 fromBRGA8Bitmap:(unsigned char *)buffer {
	size_t width = size.width;
	size_t height = size.height;
	
	size_t bitsPerComponent = 8;
	size_t bitsPerPixel = 32;
	size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
	
	size_t bufferLength = width * height * bytesPerPixel;

	size_t bytesPerRow = 4 * width;

	//caller still owns the buffer
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
	
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	if(colorSpaceRef == NULL) {
		NSLog(@"Error allocating color space");
		CGDataProviderRelease(provider);
		return nil;
	}
	
	//Also known as "BGRA8", thank you Duncan http://osdir.com/ml/quartz-dev/2009-05/msg00031.html
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
	
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	CGImageRef iref = CGImageCreate(width, 
																	height, 
																	bitsPerComponent, 
																	bitsPerPixel, 
																	bytesPerRow, 
																	colorSpaceRef, 
																	bitmapInfo, 
																	provider,	// data provider
																	NULL,		  // decode
																	YES,			// should interpolate
																	renderingIntent);
	float scale = [[UIScreen mainScreen] scale];
	UIImage *ret = [UIImage imageWithCGImage:iref 
																		 scale:scale 
															 orientation:UIImageOrientationUp];
	CGImageRelease(iref);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpaceRef);
	//caller _still_ owns the buffer, this function does not take ownership of it!
	return ret;
}

@end

//
//  AppDelegate.m
//  ImageConversion
//
//  Created by Paul Solt on 9/22/10.
//  Copyright 2010 RIT. All rights reserved.
//

#import "AppDelegate.h"
#import "UIImage_ImageHelper.h"

@implementation AppDelegate

@synthesize window, imageView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	// Override point for customization after application launch.
	
	UIImage *image = [UIImage imageNamed:@"Icon4.png"];
	int width = image.size.width;
	int height = image.size.height;
	
	// Create a bitmap
	unsigned char *bitmap = [image newBRGA8Bitmap];
	
	// Create a UIImage using the bitmap
	UIImage *imageCopy = [UIImage imageWithSize:CGSizeMake(width, height) fromBRGA8Bitmap:bitmap];
	
	// Cleanup
	if(bitmap) {
		free(bitmap);	
		bitmap = NULL;
	}
	
	self.imageView.image = imageCopy;
	
	[self.window makeKeyAndVisible];
	
	return YES;
}

@end

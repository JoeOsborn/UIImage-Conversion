/*
 * The MIT License
 *
 * Copyright (c) 2011 Paul Solt, PaulSolt@gmail.com
 * Modifications Copyright (c) 2011 Joe Osborn, josborn@universalhappymaker.com
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

/*
 * Changes from origin:
 * * ImageHelper is now a category on UIImage with convention-following method names
 * * We now convert to and from BGRA8 for better drawing performance
 * * To simplify malloc/free responsibilities, the bitmap context is now created within 
 *   the to-RGBA8 (now BGRA8) conversion method. Before, its bitmap could leak if the 
 *   context creation method were used improperly.
 * * An unnecessary memory copy was removed.
 * * An unnecessary context creation and image draw were removed.
 */

#import <Foundation/Foundation.h>


@interface UIImage(ImageHelper)

/** Converts a UIImage to BGRA8 bitmap.
 @return a BGRA8 bitmap owned by the caller of length image.size.width*image.size.height, or NULL if memory could not be allocated
 */
- (unsigned char *)newBGRA8Bitmap;

/** Converts a BGRA8 bitmap to a UIImage. Transfers ownership of the bitmap to the newly allocated object. This is to avoid cases where client code naively manipulates or frees the buffer immediately after calling this method; CGDataProvider is used internally and Quartz is much cleverer with memory than you or I.
 @param size - the size in pixels
 @param scale - the image scale
 @param buffer - the BGRA8 bitmap, consumed by this method. do not
 attempt to modify or use buffer in any way after calling this method.
 @return an image of the given size composed of the bytes in buffer
 */
+ (UIImage *)imageWithSize:(CGSize)size
										 scale:(CGFloat)scale
					 fromBGRA8Bitmap:(unsigned char *)buffer;

@end


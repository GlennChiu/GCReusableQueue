//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Copyright (c) 2013 Glenn Chiu
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>

/* Make sure that objects conform to this protocol and return -reuseIdentifier. */
@protocol GCReusableObject <NSObject>

- (NSString *)reuseIdentifier;

@optional
- (void)prepareForReuse;

@end

@interface GCReusableQueue : NSObject

+ (instancetype)sharedInstance;

- (void)enqueueReusableObject:(id)obj;

- (void)enqueueReusableObject:(id)obj withReuseIdentifier:(NSString *)reuseIdentifier;

/* If no identifier is specified, the pool will try to return a queued object of the same class
 * with no reuse identifier. If none exists, it will return one of the same class with any reuse
 * identifier. If a reuse identifier is explicitely specified here, this will only return an object
 * bearing it, or nil if none exists.
 */
- (id)dequeueReusableObjectOfClass:(Class)class withIdentifier:(NSString *)identifier;

/* This method should not be used, as the queue will discard objects automatically
   when memory gets tight. Use this method to discard objects manually. */
- (void)clearQueue;

@end
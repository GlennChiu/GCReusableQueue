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

#import "GCReusableQueue.h"
#import <TargetConditionals.h>

NSString *const GCNoReuseIdentifierKey = @"GCNoReuseIdentifierKey";

@implementation GCReusableQueue
{
    NSCache *_reusableObjects;
    id _observer;
}

+ (instancetype)sharedInstance {
    static GCReusableQueue *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GCReusableQueue alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
#if TARGET_OS_IPHONE
        GCReusableQueue * __weak w_self = self;
        
        self->_observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                                                            object:nil
                                                                             queue:nil
                                                                        usingBlock:^(NSNotification *note) {
                                                                            
                                                                            GCReusableQueue *s_self = w_self;
                                                                            
                                                                            if (s_self) [s_self clearQueue];
                                                                        }];
#endif
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self->_observer];
}

- (NSCache *)reusableObjects
{
    return self->_reusableObjects ?: (self->_reusableObjects = [NSCache new]);
}

- (id)dequeueReusableObjectOfClass:(Class)class withIdentifier:(NSString *)identifier
{
	NSParameterAssert(class);
	
    id obj = nil;
    
	NSDictionary *objectsByIdentifier = [[self reusableObjects] objectForKey:NSStringFromClass(class)];
    
    if (![identifier length]) {
        if ([[objectsByIdentifier valueForKey:GCNoReuseIdentifierKey] count]) {
            NSMutableSet *objects = [objectsByIdentifier valueForKey:GCNoReuseIdentifierKey];
            obj = [objects anyObject];
            if (obj) {
                [objects removeObject:obj];
            }
        } else {
            // Look for an object with any reuse identifier
            for (NSString *identifier in objectsByIdentifier) {
                NSMutableSet *objects = objectsByIdentifier[identifier];
                obj = [objects anyObject];
                
                if (obj) {
                    [objects removeObject:obj];
                    break;
                }
            }
        }
    } else {
        NSMutableSet *objects = [objectsByIdentifier valueForKey:identifier];
        obj = [objects anyObject];
        if (obj) {
            [objects removeObject:obj];
        }
    }
    
    if (obj && [obj respondsToSelector:@selector(prepareForReuse)]) {
        [obj prepareForReuse];
    }
	
	return obj;
}

- (void)enqueueReusableObject:(id)obj
{
    [self enqueueReusableObject:obj withReuseIdentifier:nil];
}

- (void)enqueueReusableObject:(id)obj withReuseIdentifier:(NSString *)reuseIdentifier {
    NSMutableDictionary *objectsByReuseIdentifier = [[self reusableObjects] objectForKey:NSStringFromClass([obj class])];
    
    if (!objectsByReuseIdentifier) {
        objectsByReuseIdentifier = [NSMutableDictionary new];
        [[self reusableObjects] setObject:objectsByReuseIdentifier forKey:NSStringFromClass([obj class])];
    }
    
    if (![reuseIdentifier length] && [obj respondsToSelector:@selector(reuseIdentifier)]) {
        reuseIdentifier = [obj valueForKey:NSStringFromSelector(@selector(reuseIdentifier))];
    }
    if (![reuseIdentifier length]) {
        reuseIdentifier = GCNoReuseIdentifierKey;
    }
    
    NSMutableSet *objects = [objectsByReuseIdentifier objectForKey:reuseIdentifier];
    if (!objects) {
        objects = [NSMutableSet set];
        [objectsByReuseIdentifier setObject:objects forKey:reuseIdentifier];
    }
    
    [objects addObject:obj];
}

- (void)clearQueue
{
    [[self reusableObjects] removeAllObjects];
}

@end

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

@implementation GCReusableQueue
{
    NSCache *_reusableObjects;
    id _observer;
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

- (id <ReusableObject>)dequeueReusableObjectWithIdentifier:(NSString *)identifier
{
	NSParameterAssert(identifier);
	
	NSMutableSet *objects = [[self reusableObjects] objectForKey:identifier];
	
	id <ReusableObject> obj = [objects anyObject];
	
	if (obj) [objects removeObject:obj];
	
	return obj;
}

- (void)enqueueReusableObject:(id <ReusableObject>)obj
{
	NSMutableSet *objects = [[self reusableObjects] objectForKey:[obj reuseIdentifier]];
	
	if (!objects)
	{
		objects = [NSMutableSet set];
		[[self reusableObjects] setObject:objects forKey:[obj reuseIdentifier]];
	}
	
    [objects addObject:obj];
}

- (void)clearQueue
{
    [[self reusableObjects] removeAllObjects];
}

@end

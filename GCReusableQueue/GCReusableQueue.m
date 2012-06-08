//
//  GCReusableQueue.m
//  GCReusableQueue
//
//  Created by Glenn Chiu on 31-05-12.
//  Copyright (c) 2012 Dot Square. All rights reserved.
//

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
        
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        
        __weak GCReusableQueue *w_self = self;
        
        self->_observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification 
                                                                            object:nil 
                                                                             queue:nil 
                                                                        usingBlock:^(NSNotification *note) {
                                                                            GCReusableQueue *s_self = w_self;
                                                                            
                                                                            [s_self clearQueue];
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
    if (!self->_reusableObjects)
    {
        self->_reusableObjects = [NSCache new];
    }
    
    return self->_reusableObjects;
}

- (id <ReusableObject>)dequeueReusableObjectWithIdentifier:(NSString *)identifier
{
	NSParameterAssert(identifier);
	
	NSMutableSet *objects = [[self reusableObjects] objectForKey:identifier];
	
	id <ReusableObject> obj = [objects anyObject];
	
	if (obj)
	{
		[objects removeObject:obj];
	}
	
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
	else
	{
        [objects addObject:obj];
	}
}

- (void)clearQueue
{
    [[self reusableObjects] removeAllObjects];
}

@end

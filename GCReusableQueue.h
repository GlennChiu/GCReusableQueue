//
//  GCReusableQueue.h
//  GCReusableQueue
//
//  Created by Glenn Chiu on 31-05-12.
//  Copyright (c) 2012 Dot Square. All rights reserved.
//

#import <Foundation/Foundation.h>

/* Make sure that objects conform to this protocol and return -reuseIdentifier. */
@protocol ReusableObject <NSObject>

- (NSString *)reuseIdentifier;

@end

@interface GCReusableQueue : NSObject

- (void)enqueueReusableObject:(id <ReusableObject>)obj;
- (id <ReusableObject>)dequeueReusableObjectWithIdentifier:(NSString *)identifier;

/* This method should not be used, as the queue will discard objects automatically
   when memory gets tight. Use this method to discard objects manually. */
- (void)clearQueue;

@end
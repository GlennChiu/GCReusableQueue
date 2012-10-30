GCReusableQueue
===============

Class to store objects in a reusable queue to minimize memory allocations for better efficiency. Any type of object can be used, but it was specially designed to queue NSView, UIView and CALayer classes in conjunction with reuse identifiers.

The queue gets cleared automatically when the memory gets tight and it listens to memory warnings (iOS only).

It works just like `UITableView` on iOS. It supports multiple reuse identifiers.

Installation
------------

Just drag and drop the header and implementation file into your project.

If you use the class in a non-ARC project, make sure you add the `-fobjc-arc` compiler flag for the implementation file.

Methods
-------

Enqueue the object for later use:
```objectivec
- (void)enqueueReusableObject:(id <ReusableObject>)obj;
```
Dequeue an object, if any is available. Returns nil otherwise:
```objectivec
- (id <ReusableObject>)dequeueReusableObjectWithIdentifier:(NSString *)identifier;
```
If necessary, call this method to clear the queue:
```objectivec
- (void)clearQueue;
```
Protocol
--------

Make sure you use a custom subclass which conforms to the `ReusableObject` protocol. This method returns the reuse identifier, which you should set when the object gets initialized:
```objectivec
- (NSString *)reuseIdentifier;
```
Usage
-----

This is an example on how to get a reusable object, in this case a CATransformLayer subclass:
```objectivec
- (CubeLayer *)pathView:(PathView *)pathView cubeForItemAtIndex:(NSUInteger)index
{
    static NSString *kCubeIdentifier = @"cube_identifier";
    	
    /* Get an instance from an object by dequeueing an object with a reuse identifier from the queue, just like a UITableViewCell */
    CubeLayer *cube = (CubeLayer *)[pathView.cubeQueue dequeueReusableObjectWithIdentifier:kCubeIdentifier];
    /* If no object is available in the queue, it'll return nil. If it is nil, create a new instance */
    if (cube == nil)
    {
        /* It's best practice to use a custom designated initializer to store the reuse identifier */
		cube = [[CubeLayer alloc] initWithReuseIdentifier:kCubeIdentifier];
    }
    	
    NSDictionary *dict = [_dataCollection objectAtIndex:index];
    	
    CGFloat width = [[dict objectForKey:@"width"] floatValue];
    UIColor *color = [dict objectForKey:@"color"];
    	
    cube.width = width;
    cube.color = color;
    	
    return cube;
}
```
When you're done with a certain object (e.g. a view element gets removed from the screen) you can enqueue the object this way:
```objectivec
    UIView *view = [[UIView alloc] initWithFrame:...];
        
    ...
        
    [view removeFromSuperview];
    /* Done with the object, enqueue it for later use */
    [_reusableQueue enqueueReusableObject:view];
```
Make sure that the objects conform to the `ReusableObject` protocol:
```objectivec
@interface ViewSubclass : UIView <ReusableObject>  
{  
    NSString *reuseIdentifier;  
}
```
In case you need to clear the queue manually you can call `-clearQueue`. However you should not call the method if you don't have to.

License
-------

This code is distributed under the terms and conditions of the MIT license. 

Copyright (c) 2012 Glenn Chiu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
//
//  NWMethodWrapper.h
//  NWMethodWrapper
//
//  Created by Martijn Thé on 10/30/11.
//  Copyright (c) 2011 Noodlewerk BV. All rights reserved.
//

// aspect oriented programming
// point cuts

#import <Foundation/Foundation.h>

typedef id(^ImpBlock)(id _self, ...);

NS_CLASS_AVAILABLE(10_7, 4_3)
/**
 *  Using NWMethodWrapper objects, method calls to instances of a specified class, or method calls to
 *  a specified class itself can be "wrapped" between 2 blocks that will be called resp. before and after
 *  calling the original method implementation.
 *
 *  Example: 
 *  Let's assume we have a class called NWMediaPlayer, which e.g. implements an instance method -playSource:
 *  Using a method wrapper we can have a block executed before the actual -playSource: is called, and we can
 *  have a block executed after the actual -playSource: is called:
 *
 *  [NWMethodWrapper wrap:[NWMediaPlayer class] instanceMethodForSelector:@selector(playSource:)
                   before:(ImpBlock)^(id _self, id<NPOSource> _source) {
                                // This block will be executed BEFORE the original implementation of -playSource:
                          }
                    after:(ImpBlock)^(id _self, id<NPOSource> _source) {
                                // This block will be executed AFTER the original implementation of -playSource:
                          }];
 *
 *  Also note that the first argument is id _self. This will contain a reference to the object on which the
 *  -playSource: is being called. After the first argument, optional arguments are passed, that were passed
 *  in when calling the -playSource: method. The number of arguments is currently limited to 6. Also the
 *  supported types of arguments is limited. Structs, unions and C arrays are not supported. This could be
 *  fixed in the future by using libffi to call the variadic blocks / original implemenation.
 *  Note that the block is typecasted to a generic ImpBlock. This is to avoid compiler errors.
 *
 *  The +wrap:... convenience methods return an autoreleased NWMethodWrapper instance. The wrapping will be
 *  activated for you by this convenience method.
 *  Note that once the instance gets deallocated, the wrapping will be cleaned up, so you need to retain the
 *  wrapper instances to keep the wrapping in effect.
 */

@interface NWMethodWrapper : NSObject

/**
 *  The affected (class) method selector, as specified in the wrapper's initializer or one
 *  of the convenience methods.
 */
@property (atomic, assign, readonly) SEL selector;

/**
 *  Returns YES when the wrapper affects a class method, NO when the wrapper affects an instance method.
 *  As specified in the wrapper's initializer or one of the convenience methods.
 */
@property (atomic, assign, readonly) BOOL isClassMethod;

/**
 *	The class (of objects) that will be targeted by this wrapper, as specified in the wrapper's initializer
 *   or one of the convenience methods.
 */
@property (atomic, assign, readonly) Class targetClass;

/**
 *  The block that will be called when the wrapper is active and before the original method implementation
 *  will be called. The resulting return value of calling the block is not used. The block can be
 *  changed while the wrapper is active.
 */
@property (atomic, copy, readwrite) ImpBlock beforeBlock;

/**
 *  The block that will be called when the wrapper is active and after the original method implementation
 *  has been called. The resulting return value of calling the block is not used. The block can be
 *  changed while the wrapper is active.
 */
@property (atomic, copy, readwrite) ImpBlock afterBlock;

/**
 *	Convenience method to create a NWMethodWrapper object to add blocks before and after
 *  calls to an instance method of a particular class.
 *
 *	@param aClass The wrapper will affect instances of this class.
 *	@param selector The selector of the instance method that will be wrapped.
 *	@param beforeBlock The block that will be executed prior to the method call specified by selector.
 *	@param afterBlock The block that will be executed after the method call specified by selector.
 *	@returns An autoreleased NWMethodWrapper instance configured with the given parameters.
 *  -setWrapped:YES is called just before returning the object.
 *  @discussion When called, the return values of beforeBlock and afterBlock are not used.
 */
+ (NWMethodWrapper*)wrap:(Class)aClass instanceMethodForSelector:(SEL)selector before:(ImpBlock)beforeBlock after:(ImpBlock)afterBlock;

/**
 *	Convenience method to create a NWMethodWrapper object to add blocks before and after
 *  calls to a class method of a particular class.
 *
 *	@param aClass The wrapper will affect this class.
 *	@param selector The selector of the class method that will be wrapped.
 *	@param beforeBlock The block that will be executed prior to the method call specified by selector.
 *	@param afterBlock The block that will be executed after the method call specified by selector.
 *	@returns An autoreleased NWMethodWrapper instance configured with the given parameters.
 *  -setWrapped:YES is called just before returning the object.
 *  @discussion When called, the return values of beforeBlock and afterBlock are not used.
 */
+ (NWMethodWrapper*)wrap:(Class)aClass classMethodForSelector:(SEL)selector before:(ImpBlock)beforeBlock after:(ImpBlock)afterBlock;

/**
 *	The designated initializer.
 *	@param aClass The wrapper will affect instances of this class.
 *	@param selector The selector of the method that will be wrapped.
 *	@param isClassMethod If YES, the wrapper will be used to wrap a class method and an instance method otherwise.
 *	@returns The partially configured instance. The beforeBlock and afterBlock properties still
 *  need to be set, and -setWrapped:YES still needs to be called to active the wrapper.
 */
- (NWMethodWrapper*)initForClass:(Class)aClass methodForSelector:(SEL)selector isClassMethod:(BOOL)isClassMethod;

/**
 *	Activates or deactivates the wrapper.
 *	@param wrapped Provide YES and the wrapper will replace the current method implementation,
 *  with a wrapper implementation that calls (optionally) beforeBlock and (optionally) afterBlock, before and
 *  after the original implementation. Provide NO to restore the original implementation.
 */
- (void)setWrapped:(BOOL)wrapped;

/**
 *	@returns YES when the wrapper is currently wrapping the implementation of the method
 *  specified using the targetClass and selector properties. NO if the original implementation
 *  of the method is untouched.
 */
- (BOOL)isWrapped;

@end
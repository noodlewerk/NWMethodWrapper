//
//  NWMethodWrapper.m
//  NWMethodWrapper
//
//  Created by Martijn Thé on 10/30/11.
//  Copyright (c) 2011 Noodlewerk BV. All rights reserved.
//

#import "NWMethodWrapper.h"
#import <objc/runtime.h>

@implementation NWMethodWrapper {
    BOOL wrapped;
    IMP originalImplementation;
    Method method;
}
@synthesize selector;
@synthesize isClassMethod;
@synthesize targetClass;
@synthesize beforeBlock;
@synthesize afterBlock;

- (void)dealloc {
    [self setWrapped:NO];
    self.beforeBlock = nil;
    self.afterBlock = nil;
    [super dealloc];
}

+ (BOOL)hasClass:(Class)clas method:(Method)method {
    unsigned int outCount = 0;
    Method *methods = class_copyMethodList(clas, &outCount);
    for (NSUInteger i = 0; i < outCount; i++) {
        Method m = methods[i];
        if (method == m) {
            free(methods);
            return YES;
        }
    }
    free(methods);
    return NO;
}

- (NWMethodWrapper*)initForClass:(Class)_class methodForSelector:(SEL)_selector isClassMethod:(BOOL)_isClassMethod {
    if ((self = [super init])) {
        targetClass = _class;
        selector = _selector;
        isClassMethod = _isClassMethod;
        
        if (isClassMethod) {
            method = class_getClassMethod(targetClass, selector);
            if (![NWMethodWrapper hasClass:object_getClass(targetClass) method:method]) {
                [NSException raise:@"NWMethodWrapper" format:[NSString stringWithFormat:@"Class %@ does not implement %@", targetClass, NSStringFromSelector(selector)]];
            }
        } else {
            method = class_getInstanceMethod(targetClass, selector);
            if (![NWMethodWrapper hasClass:targetClass method:method]) {
                [NSException raise:@"NWMethodWrapper" format:[NSString stringWithFormat:@"Instance of %@ does not implement %@", targetClass, NSStringFromSelector(selector)]];
            }
        }
        
        // 6 + 2 extra for _self and selector:
        unsigned int numberOfArguments = method_getNumberOfArguments(method);
        if (numberOfArguments > 6 + 2) {
            [NSException raise:@"Methods with more than 6 arguments are not supported!" format:nil];
        }
        
        char buffer[64];
        for (unsigned int idx = 0; idx < numberOfArguments; ++idx) {
            memset(&buffer, 0, 64);
            method_getArgumentType(method, idx, buffer, 64);
            for (unsigned int jdx = 0; jdx < 64; ++jdx) {
                switch (buffer[jdx]) {
                    case _C_STRUCT_B:
                    case _C_STRUCT_E:
                    case _C_UNION_B:
                    case _C_UNION_E:
                    case _C_ARY_B:
                    case _C_ARY_E: {
                        [NSException raise:@"struct, union and array arguments are not supported!" format:nil];
                        break;
                    }
                        
                    default:
                        break;
                }
            }
        }
    }
    return self;
}

+ (NWMethodWrapper*)wrap:(Class)aClass instanceMethodForSelector:(SEL)selector before:(ImpBlock)beforeBlock after:(ImpBlock)afterBlock {
    NWMethodWrapper* wrapper = [[NWMethodWrapper alloc] initForClass:aClass methodForSelector:selector isClassMethod:NO];
    wrapper.beforeBlock = beforeBlock;
    wrapper.afterBlock = afterBlock;
    [wrapper setWrapped:YES];
    return [wrapper autorelease];
}

+ (NWMethodWrapper*)wrap:(Class)aClass classMethodForSelector:(SEL)selector before:(ImpBlock)beforeBlock after:(ImpBlock)afterBlock {
    NWMethodWrapper* wrapper = [[NWMethodWrapper alloc] initForClass:aClass methodForSelector:selector isClassMethod:YES];
    wrapper.beforeBlock = beforeBlock;
    wrapper.afterBlock = afterBlock;
    [wrapper setWrapped:YES];
    return [wrapper autorelease];
}

- (void)setWrapped:(BOOL)_wrapped {
    @synchronized(self) {
        if (wrapped == _wrapped) {
            return;
        }
        
        if (_wrapped) {
            // wrap:
            originalImplementation = method_getImplementation(method);
            
            // This is the block that will replace the original implementation:
            __block NWMethodWrapper* wrapper = self;
            
            // NOTE:
            // IMP functions are variadic, which means that there can be a variable number of arguments,
            // which are basically pushed onto the stack one after the other (by the compiler).
            // There is no way in C to pass on the whole block of arguments to the next function.
            // To avoid writing manual, platform dependent function calls in assembly,
            // we're just "pretending" that we are expecting and passing on 6 arguments here.
            // This is kinda hacky and of course limited, but kinda works.
            // There is an assert in the initializer to check if the max. number of arguments isn't exceeded.
            
            ImpBlock wrappedBlock = (ImpBlock) ^id(id _self, id u, id v, id w, id x, id y, id z) {

                // Call wrapper.beforeBlock if not NULL:
                ImpBlock localBeforeBlock = wrapper.beforeBlock;
                if (localBeforeBlock != NULL) localBeforeBlock(_self, u, v, w, x, y, z);
                
                // Call original implementation:
                id returnValue = wrapper->originalImplementation(_self, wrapper->selector, u, v, w, x, y, z);
                
                // Call wrapper.afterBlock if not NULL:
                ImpBlock localAfterBlock = wrapper.afterBlock;
                if (localAfterBlock != NULL) localAfterBlock(_self, u, v, w, x, y, z);
                
                // Return value of original implementation:
                return returnValue;
            };
            
            // Replace the original implementation with our wrapper block:
            IMP wrappedImplementation = imp_implementationWithBlock((__bridge void*)wrappedBlock);
            method_setImplementation(method, wrappedImplementation);
            
        } else {
            // unwrap:
            // Restore the original implementation:
            IMP wrappedImplementation = method_setImplementation(method, originalImplementation);
            // Cleanup:
            imp_removeBlock(wrappedImplementation);
            originalImplementation = NULL;
        }
        
        wrapped = _wrapped;
    }
}

- (BOOL)isWrapped {
    @synchronized(self) {
        return wrapped;
    }
}

@end

//
//  NWMethodWrapperTests.m
//  NWMethodWrapperTests
//
//  Created by Martijn Thé on 10/30/11.
//  Copyright (c) 2011 Noodlewerk BV. All rights reserved.
//

#import "NWMethodWrapperTests.h"
#import "NWMethodWrapper.h"



@implementation Dummy {
@private
    int foo;
}

- (void)bar {
    ++foo;
}

- (id)foo:(int)x bar:(id)obj {
    foo += x;
    return [NSString stringWithFormat:@"%@", obj];
}

- (id)foo:(int)x foo:(int)y {
    foo = x + y;
    return [NSString stringWithFormat:@"%i", foo];
}

- (NSString*)all:(unsigned char)chr kinds:(id)obj of:(BOOL)yesNo different:(id*)objPtr types:(long long)longLong {
    return [NSString stringWithFormat:@"%c %@ %i %@ %i", chr, obj, yesNo, *objPtr, longLong];
}

- (void)to:o m:a n:y ar:g u:m e:n t:s {
    // This methos is not allowed to be wrapped (more than 6 arguments)
}

- (struct someStruct)takesStruct:(struct someStruct)s {
    return s;
}

@end



@implementation NWMethodWrapperTests {
    int a;
}


- (void)testNoArgumentsNoReturnValue {
    Dummy* d = [[Dummy alloc] init];
    
    a = 0;
    NWMethodWrapper* wrapper = [NWMethodWrapper wrap:[Dummy class] instanceMethodForSelector:@selector(bar) before:^id(id sender, ...) {
        STAssertTrue(a == 0, @"expected: a == 0");
        ++a;
        return nil;
    } after:^id(id sender, ...) {
        STAssertTrue(a == 1, @"expected: a == 1");
        ++a;
        return nil;
    }];
    
    [d bar];
    STAssertTrue(a == 2, @"expected: a == 2");
    
    [wrapper setWrapped:NO];
    
    [d bar];
    STAssertTrue(a == 2, @"expected: a == 2");
    
    [d release];
}


- (void)testIntAndIdArgumentsAndIdReturnValue {
    Dummy* d = [[Dummy alloc] init];
    
    a = 0;
    NWMethodWrapper* wrapper = [NWMethodWrapper wrap:[Dummy class] instanceMethodForSelector:@selector(foo:bar:) before:(ImpBlock)^void(id _self, int x, id obj) {
        STAssertTrue(a == 0, @"expected: a == 0");
        a = x + 1;
    } after:(ImpBlock)^void(id _self, int x, id obj) {
        STAssertTrue(a == 11, @"expected: a == 1");
        ++a;
    }];
    
    NSString* hello1 = @"hello";
    NSLog(@"hello1 lives at %p", hello1);
    
    id returnVal = [d foo:10 bar:hello1];
    STAssertTrue([returnVal isEqual:hello1], @"expected: returnVal ==  %@", hello1);
    STAssertTrue(a == 12, @"expected: a == 12");
    
    [wrapper setWrapped:NO];
    
    NSString* hello2 = @"hellowww";
    NSLog(@"hello2 lives at %p", hello2);

    id returnVal2 = [d foo:10 bar:hello2];
    STAssertTrue([returnVal2 isEqual:hello2], @"expected: returnVal == %@", hello2);
    STAssertTrue(a == 12, @"expected: a == 12");
    
    wrapper = nil;
    [d release];
    d = nil;
}

- (void)test2IntArgumentsAndIdReturnValue {
    Dummy* d = [[Dummy alloc] init];
    
    a = 0;
    NWMethodWrapper* wrapper = [NWMethodWrapper wrap:[Dummy class] instanceMethodForSelector:@selector(foo:foo:) before:(ImpBlock)^void(id _self, int x, int y) {
        STAssertTrue(a == 0, @"expected: a == 0");
        a = x + y;
    } after:(ImpBlock)^void(id _self, int x, int y) {
        STAssertTrue(a == x + y, @"expected: a == x + y");
        ++a;
    }];
    
    id returnVal = [d foo:10 foo:0x55];
    NSLog(@"%@", returnVal);
    STAssertTrue(a == 10 + 0x55 + 1, @"expected: a == 10 + 0x55 + 1");
    STAssertTrue([returnVal isEqualToString:@"95"], @"expected: '95'");
    
    wrapper = nil;
    [d release];
}

- (void)testDifferentTypes {
    Dummy* d = [[Dummy alloc] init];

    [NWMethodWrapper wrap:[Dummy class] instanceMethodForSelector:@selector(all:kinds:of:different:types:) before:(ImpBlock)^void(id sender, unsigned char all, id kinds, BOOL of, id* different, long long types) {
        STAssertTrue(all == 0xFF, @"expected: all == 0xFF");
        STAssertTrue([kinds isEqual:@"hello"], @"expected: kinds == 'hello'");
        STAssertTrue(of == YES, @"expected: of == YES");
        STAssertTrue(*different == kinds, @"expected: *different == kinds");
        STAssertTrue(types == LONG_MAX, @"expected: types == LONG_MAX");
    } after:(ImpBlock)^void(id sender, unsigned char all, id kinds, BOOL of, id* different, long long types) {
        STAssertTrue(all == 0xFF, @"expected: all == 0xFF");
        STAssertTrue([kinds isEqual:@"hello"], @"expected: kinds == 'hello'");
        STAssertTrue(of == YES, @"expected: of == YES");
        STAssertTrue(*different == kinds, @"expected: *different == kinds");
        STAssertTrue(types == LONG_MAX, @"expected: types == LONG_MAX");
    }];
    
    NSString* hello = @"hello";
    [d all:0xFF kinds:hello of:YES different:&hello types:LONG_MAX];
    
    [d release];
}


- (void)testStructType {
    STAssertThrows([NWMethodWrapper wrap:[Dummy class] instanceMethodForSelector:@selector(takesStruct:) before:(ImpBlock)^void(id sender, struct someStruct s) {
        //        STAssertTrue(s.x[0] == LONG_MAX, @"s.x[0] == LONG_MAX");
        //        STAssertTrue(s.x[1] == LONG_MIN, @"s.x[1] == LONG_MIN");
        //        STAssertTrue(s.x[2] == LONG_MAX, @"s.x[2] == LONG_MAX");
//        STAssertTrue(s.x[3] == LONG_MIN, @"s.x[3] == LONG_MIN");
    } after:NULL], @"expected to throw exception, because structs are not supported.");

}

- (void)testTooManyArgs {
    STAssertThrows([NWMethodWrapper wrap:[Dummy class] instanceMethodForSelector:@selector(to:m:n:ar:u:e:t:) before:NULL after:NULL], @"This should throw a 'too many arguments' exception");
}

@end

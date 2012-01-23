//
//  NWMethodWrapperTests.h
//  NWMethodWrapperTests
//
//  Created by Martijn Thé on 10/30/11.
//  Copyright (c) 2011 Noodlewerk BV. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

struct someStruct {
    long long x[4];
};

@interface Dummy : NSObject
- (void)bar;
- (id)foo:(int)x bar:(id)obj;
- (id)foo:(int)x foo:(int)y;
- (NSString*)all:(unsigned char)chr kinds:(id)obj of:(BOOL)yesNo different:(id*)objPtr types:(long long)longLong;
- (void)to:o m:a n:y ar:g u:m e:n t:s;
- (struct someStruct)takesStruct:(struct someStruct)s;
@end

@interface NWMethodWrapperTests : SenTestCase

@end

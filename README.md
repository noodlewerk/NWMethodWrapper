NWMethodWrapper
=============

<em>Allows you to run custom code before and after Objective-C methods.</em>


### About
NWMethodWrapper provides an aspect-oriented way to insert code around method calls. For example to add logging to a method without modifying its source. It does this by swizzling the implementation with one that invokes custom code blocks before and after running the original implemenation.


### Code example
The following code snippets illustrate a basic method wrapping:

Orignal.m:

    - (void)boogie {
        NSLog(@"boogie!");
    }

Wrapper.m:

    - (void)wrap {
        ImpBlock beforeBlock = (ImpBlock)^void(id _self) {
            NSLog(@"before %@ boogies", _self);
        };
        ImpBlock afterBlock = (ImpBlock)^void(id _self) {
            NSLog(@"after %@ boogied", _self);
        };
        [NWMethodWrapper wrap:[Orignal class] 
        instanceMethodForSelector:@selector(boogie) 
        before:beforeBlock after:afterBlock];
    }

If we first execute `wrap` followed by `boogie`, we get:

    before Original boogies
    boogie!
    after Original boogied


### Build in XCode
The source comes with an XCode 4 project file that should take care of building the library and running the demo app. To use NWMethodWrapper in your project, it is recommended to directly include those source files needed.


### License
NWMethodWrapper is licensed under the terms of the BSD 2-Clause License, see the included LICENSE file.


### Authors
- [Noodlewerk](http://www.noodlewerk.com/)
- [Martijn Thé](http://www.martijnthe.nl/)
- [Leonard van Driel](http://www.leonardvandriel.nl/)
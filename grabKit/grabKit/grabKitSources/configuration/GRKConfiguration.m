//  GRKConfiguration.h
//  GrabKit
//
//  Based on SHKConfiguration.h, from the ShareKit project
//  Created by Edward Dale on 10/16/10.
//  Modified by Pierre-Olivier Simonard on 2012/07/21 
//    to make an ARC version for the GrabKit project
//
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
//
//

#import "GRKConfiguration.h"
#import "GRKConfiguratorProtocol.h"

static GRKConfiguration *sharedInstance = nil;


@interface GRKConfiguration ()

- (id)initWithConfigurator:(id<GRKConfiguratorProtocol>)config;

@end


@implementation GRKConfiguration

@synthesize configurator;

#pragma mark -
#pragma mark Singleton methods


+ (GRKConfiguration*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil) {
            [NSException raise:@"IllegalStateException" format:@"GrabKit must be configured before use. Use an object conforming to the GRKConfiguratorProtocol protocol. For more info, refer to the Demo project"];
        }
    }
    return sharedInstance;
}

+ (void)initializeWithConfigurator:(id<GRKConfiguratorProtocol>)config
{
    @synchronized(self)
    {
		if (sharedInstance != nil) {
			[NSException raise:@"IllegalStateException" format:@"GRKConfiguration has already been configured"];
		}
		sharedInstance = [[GRKConfiguration alloc] initWithConfigurator:config];
    }
    
}

+(void)initializeWithConfiguratorClassName:(NSString*)className; {
    
    Class configuratorClass = NSClassFromString(className);
    id config = [[configuratorClass alloc] init];
    
    if ( ! [config conformsToProtocol:@protocol(GRKConfiguratorProtocol)] ){
        [NSException raise:@"IllegalConfiguratorException" format:@"Trying to configure GrabKit with an object which doesn't conform to GRKConfiguratorProtocol. Refer to the example file GRKDemoConfigurator in the demo app."];    
    }
    
    sharedInstance = [[GRKConfiguration alloc] initWithConfigurator:config];

}


- (id)initWithConfigurator:(id<GRKConfiguratorProtocol>)config
{
    if ((self = [super init])) {
		configurator = config;
    }
    return self;
}


@end

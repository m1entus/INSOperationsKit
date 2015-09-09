//
//  INSParseOperation.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

#import <INSOperationsKit/INSOperationsKit.h>
#import "INSCoreDataParsable.h"
#import <CoreData/CoreData.h>

@interface INSParseOperation : INSOperation <INSChainableOperationProtocol>

- (instancetype)initWithParsableClass:(Class <INSCoreDataParsable>)objectClass context:(NSManagedObjectContext *)context;
@end

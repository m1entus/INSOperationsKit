//
//  INSDownloadOperation.h
//  INSOperationsKit Demo
//
//  Created by Michal Zaborowski on 07.09.2015.
//  Copyright © 2015 Michal Zaborowski. All rights reserved.
//

@import INSOperationsKit;
#import <CoreData/CoreData.h>

typedef id(^INSDownloadOperationResponseFilterBlock)(id responseObject);

@interface INSDownloadOperation : INSOperation <INSChainableOperationProtocol>
@property (nonatomic, copy) INSDownloadOperationResponseFilterBlock responseFilteringBlock;

- (instancetype)initWithURL:(NSURL *)URL responseFiltering:(INSDownloadOperationResponseFilterBlock)responseFiltering;
@end

//
//  INSReachabilityManager.m
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//
// INSReachabilityManager.m
// Copyright (c) 2011–2015 Alamofire Software Foundation (http://alamofire.org/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "INSReachabilityManager.h"
#if !TARGET_OS_WATCH

#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

NSString * const INSReachabilityDidChangeNotification = @"io.inspace.reachability.change";
NSString * const INSReachabilityNotificationStatusItem = @"INSReachabilityNotificationStatusItem";

typedef void (^INSReachabilityStatusBlock)(INSReachabilityStatus status);

typedef NS_ENUM(NSUInteger, INSReachabilityAssociation) {
    INSReachabilityForAddress = 1,
    INSReachabilityForAddressPair = 2,
    INSReachabilityForName = 3,
};

NSString * INSStringFromNetworkReachabilityStatus(INSReachabilityStatus status) {
    switch (status) {
        case INSReachabilityStatusNotReachable:
            return NSLocalizedStringFromTable(@"Not Reachable", @"INSing", nil);
        case INSReachabilityStatusReachableViaWWAN:
            return NSLocalizedStringFromTable(@"Reachable via WWAN", @"INSing", nil);
        case INSReachabilityStatusReachableViaWiFi:
            return NSLocalizedStringFromTable(@"Reachable via WiFi", @"INSing", nil);
        case INSReachabilityStatusUnknown:
        default:
            return NSLocalizedStringFromTable(@"Unknown", @"INSing", nil);
    }
}

static INSReachabilityStatus INSReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    INSReachabilityStatus status = INSReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = INSReachabilityStatusNotReachable;
    }
#if	TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = INSReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = INSReachabilityStatusReachableViaWiFi;
    }
    
    return status;
}

static void INSReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    INSReachabilityStatus status = INSReachabilityStatusForFlags(flags);
    INSReachabilityStatusBlock block = (__bridge INSReachabilityStatusBlock)info;
    if (block) {
        block(status);
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ INSReachabilityNotificationStatusItem: @(status) };
        [notificationCenter postNotificationName:INSReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });
    
}

static const void * INSReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}

static void INSReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface INSReachabilityManager ()
@property (readwrite, nonatomic, strong) id networkReachability;
@property (readwrite, nonatomic, assign) INSReachabilityAssociation networkReachabilityAssociation;
@property (readwrite, atomic, assign) INSReachabilityStatus networkReachabilityStatus;
@property (readwrite, nonatomic, copy) INSReachabilityStatusBlock networkReachabilityStatusBlock;
@property (readwrite, nonatomic, assign, getter=isMonitoring) BOOL monitoring;
@property (nonatomic, strong) NSHashTable *blockTable;
@property (nonatomic, strong) dispatch_queue_t syncQueue;
@end

@implementation INSReachabilityManager

+ (instancetype)sharedManager {
    static INSReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [self managerForLocalAddress];
    });
    
    return _sharedManager;
}

+ (instancetype)managerForLocalAddress {
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    return [self managerForAddress:&address];
}

+ (instancetype)managerForDomain:(NSString *)domain {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);
    
    INSReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    manager.networkReachabilityAssociation = INSReachabilityForName;
    
    return manager;
}

+ (instancetype)managerForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
    
    INSReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    manager.networkReachabilityAssociation = INSReachabilityForAddress;
    
    return manager;
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.syncQueue = dispatch_queue_create("io.inspace.insoperationkit.insreachabilitymanager.sync", DISPATCH_QUEUE_SERIAL);
    self.blockTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsCopyIn];
    self.networkReachability = CFBridgingRelease(reachability);
    self.networkReachabilityStatus = INSReachabilityStatusUnknown;
    
    return self;
}

- (instancetype)init NS_UNAVAILABLE
{
    return nil;
}

- (void)dealloc {
    [self stopMonitoring];
    [self.blockTable removeAllObjects];
}

#pragma mark -

- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN {
    return self.networkReachabilityStatus == INSReachabilityStatusReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return self.networkReachabilityStatus == INSReachabilityStatusReachableViaWiFi;
}

#pragma mark -

- (void)startMonitoring {
    [self stopMonitoring];
    
    if (!self.networkReachability) {
        return;
    }
    
    self.monitoring = YES;
    
    __weak __typeof(self)weakSelf = self;
    INSReachabilityStatusBlock callback = ^(INSReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.networkReachabilityStatus = status;
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }

        __block NSArray *blockObjects = @[];

        dispatch_sync(self.syncQueue, ^{
            blockObjects = [[strongSelf.blockTable allObjects] copy];
        });

        [blockObjects enumerateObjectsUsingBlock:^(INSReachabilityStatusBlock obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj(status);
        }];

        dispatch_sync(self.syncQueue, ^{
            for (id obj in blockObjects) {
                [strongSelf.blockTable removeObject:obj];
            }
        });
    };
    
    id networkReachability = self.networkReachability;
    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, INSReachabilityRetainCallback, INSReachabilityReleaseCallback, NULL};
    SCNetworkReachabilitySetCallback((__bridge SCNetworkReachabilityRef)networkReachability, INSReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop((__bridge SCNetworkReachabilityRef)networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    switch (self.networkReachabilityAssociation) {
        case INSReachabilityForName:
            break;
        case INSReachabilityForAddress:
        case INSReachabilityForAddressPair:
        default: {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                SCNetworkReachabilityFlags flags;
                SCNetworkReachabilityGetFlags((__bridge SCNetworkReachabilityRef)networkReachability, &flags);
                INSReachabilityStatus status = INSReachabilityStatusForFlags(flags);
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(status);
                    
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:INSReachabilityDidChangeNotification object:nil userInfo:@{ INSReachabilityNotificationStatusItem: @(status) }];
                    
                    
                });
            });
        }
            break;
    }
}

- (void)stopMonitoring {
    self.monitoring = NO;
    if (!self.networkReachability) {
        return;
    }
    
    SCNetworkReachabilityUnscheduleFromRunLoop((__bridge SCNetworkReachabilityRef)self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark -

- (NSString *)localizedNetworkReachabilityStatusString {
    return INSStringFromNetworkReachabilityStatus(self.networkReachabilityStatus);
}

#pragma mark -

- (void)setReachabilityStatusChangeBlock:(void (^)(INSReachabilityStatus status))block {
    self.networkReachabilityStatusBlock = block;
}

- (void)addSingleCallReachabilityStatusChangeBlock:(nonnull void (^)(INSReachabilityStatus status))block {

    if (self.networkReachabilityStatus == INSReachabilityStatusUnknown) {
        dispatch_sync(self.syncQueue, ^{
            [self.blockTable addObject:block];
        });
    } else {
        block(self.networkReachabilityStatus);
    }
}

#pragma mark - NSKeyValueObserving

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"reachable"] || [key isEqualToString:@"reachableViaWWAN"] || [key isEqualToString:@"reachableViaWiFi"]) {
        return [NSSet setWithObject:@"networkReachabilityStatus"];
    }
    
    return [super keyPathsForValuesAffectingValueForKey:key];
}

@end
#endif

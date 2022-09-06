//
//  INSReachabilityManager.h
//  INSOperationsKit
//
//  Created by Michal Zaborowski on 04.09.2015.
//  Copyright (c) 2015 Michal Zaborowski. All rights reserved.
//
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

#import <Foundation/Foundation.h>

#if !TARGET_OS_WATCH
#import <SystemConfiguration/SystemConfiguration.h>

#ifndef NS_DESIGNATED_INITIALIZER
#if __has_attribute(objc_designated_initializer)
#define NS_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
#else
#define NS_DESIGNATED_INITIALIZER
#endif
#endif

typedef NS_ENUM(NSInteger, INSReachabilityStatus) {
    INSReachabilityStatusUnknown          = -1,
    INSReachabilityStatusNotReachable     = 0,
    INSReachabilityStatusReachableViaWWAN = 1,
    INSReachabilityStatusReachableViaWiFi = 2,
};

NS_ASSUME_NONNULL_BEGIN

/**
 `INSReachabilityManager` monitors the reachability of domains, and addresses for both WWAN and WiFi network interfaces.
 Reachability can be used to determine background information about why a network operation failed, or to trigger a network operation retrying when a connection is established. It should not be used to prevent a user from initiating a network request, as it's possible that an initial request may be required to establish reachability.
 See Apple's Reachability Sample Code (https://developer.apple.com/library/ios/samplecode/reachability/)
 @warning Instances of `INSReachabilityManager` must be started with `-startMonitoring` before reachability status can be determined.
 */
@interface INSReachabilityManager : NSObject

/**
 The current network reachability status.
 */
@property (readonly, atomic, assign) INSReachabilityStatus networkReachabilityStatus;

/**
 Whether or not the network is currently reachable.
 */
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;

/**
 Whether or not the network is currently reachable via WWAN.
 */
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;

/**
 Whether or not the network is currently reachable via WiFi.
 */
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

@property (readonly, atomic, assign, getter=isMonitoring) BOOL monitoring;

///---------------------
/// @name Initialization
///---------------------

/**
 Returns the shared network reachability manager.
 */
+ (instancetype)sharedManager;

/**
 Creates and returns a network reachability manager for the specified domain.
 @param domain The domain used to evaluate network reachability.
 @return An initialized network reachability manager, actively monitoring the specified domain.
 */
+ (instancetype)managerForDomain:(nonnull NSString *)domain;

/**
 Creates and returns a network reachability manager for the socket address.
 @param address The socket address (`sockaddr_in`) used to evaluate network reachability.
 @return An initialized network reachability manager, actively monitoring the specified socket address.
 */
+ (instancetype)managerForAddress:(const void *)address;

+ (instancetype)managerForLocalAddress;

/**
 Initializes an instance of a network reachability manager from the specified reachability object.
 @param reachability The reachability object to monitor.
 @return An initialized network reachability manager, actively monitoring the specified reachability.
 */
- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability NS_DESIGNATED_INITIALIZER;

///--------------------------------------------------
/// @name Starting & Stopping Reachability Monitoring
///--------------------------------------------------

/**
 Starts monitoring for changes in network reachability status.
 */
- (void)startMonitoring;

/**
 Stops monitoring for changes in network reachability status.
 */
- (void)stopMonitoring;

///-------------------------------------------------
/// @name Getting Localized Reachability Description
///-------------------------------------------------

/**
 Returns a localized string representation of the current network reachability status.
 */
- (nonnull  NSString *)localizedNetworkReachabilityStatusString;

///---------------------------------------------------
/// @name Setting Network Reachability Change Callback
///---------------------------------------------------

/**
 Sets a callback to be executed when the network availability of the `baseURL` host changes.
 @param block A block object to be executed when the network availability of the `baseURL` host changes.. This block has no return value and takes a single argument which represents the various reachability states from the device to the `baseURL`.
 */
- (void)setReachabilityStatusChangeBlock:(nullable void (^)(INSReachabilityStatus status))block;
- (void)addSingleCallReachabilityStatusChangeBlock:(nonnull void (^)(INSReachabilityStatus status))block;
@end

///----------------
/// @name Constants
///----------------

/**
 ## Network Reachability
 The following constants are provided by `INSReachabilityManager` as possible network reachability statuses.
 enum {
 INSReachabilityStatusUnknown,
 INSReachabilityStatusNotReachable,
 INSReachabilityStatusReachableViaWWAN,
 INSReachabilityStatusReachableViaWiFi,
 }
 `INSReachabilityStatusUnknown`
 The `baseURL` host reachability is not known.
 `INSReachabilityStatusNotReachable`
 The `baseURL` host cannot be reached.
 `INSReachabilityStatusReachableViaWWAN`
 The `baseURL` host can be reached via a cellular connection, such as EDGE or GPRS.
 `INSReachabilityStatusReachableViaWiFi`
 The `baseURL` host can be reached via a Wi-Fi connection.
 ### Keys for Notification UserInfo Dictionary
 Strings that are used as keys in a `userInfo` dictionary in a network reachability status change notification.
 `INSingReachabilityNotificationStatusItem`
 A key in the userInfo dictionary in a `INSingReachabilityDidChangeNotification` notification.
 The corresponding value is an `NSNumber` object representing the `INSReachabilityStatus` value for the current reachability status.
 */

///--------------------
/// @name Notifications
///--------------------

/**
 Posted when network reachability changes.
 This notification assigns no notification object. The `userInfo` dictionary contains an `NSNumber` object under the `INSingReachabilityNotificationStatusItem` key, representing the `INSReachabilityStatus` value for the current network reachability.
 @warning In order for network reachability to be monitored, include the `SystemConfiguration` framework in the active target's "Link Binary With Library" build phase, and add `#import <SystemConfiguration/SystemConfiguration.h>` to the header prefix of the project (`Prefix.pch`).
 */
extern NSString * const _Nonnull INSReachabilityDidChangeNotification;
extern NSString * const _Nonnull INSReachabilityNotificationStatusItem;

///--------------------
/// @name Functions
///--------------------

/**
 Returns a localized string representation of an `INSReachabilityStatus` value.
 */
extern NSString * _Nonnull INSStringFromNetworkReachabilityStatus(INSReachabilityStatus status);

NS_ASSUME_NONNULL_END
#endif

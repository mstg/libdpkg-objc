//
//  libdpkg_objc.h
//  libdpkg-objc
//
//  Created by Mustafa Gezen on 20.06.2015.
//  Copyright (c) 2015 Mustafa Gezen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface libdpkg_objc : NSObject
struct dpkg_result {
	char *error;
	int result;
	char *output;
};
typedef void (^comp)(NSError *error, NSString *output, NSString *errorOutput);
typedef void(^completed)(struct dpkg_result result);
- (void)dpkg_install:(NSString *)file completion:(completed)completion;
- (void)dpkg_remove:(NSString *)name completion:(completed)completion;
- (void)dpkg_package_installed:(NSString *)name completion:(completed)completion;
@end

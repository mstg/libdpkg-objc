//
//  libdpkg_objc.h
//  libdpkg-objc
//
//  Created by Mustafa Gezen on 20.06.2015.
//  Copyright (c) 2015 Mustafa Gezen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface libdpkg_objc : NSObject {
	char *_error;
	int _result;
	char *_output;
}
struct dpkg_result {
	char *error;
	int result;
	char *output;
};
typedef void (^comp)(NSError *error, NSString *output, NSString *errorOutput);
- (struct dpkg_result)dpkg_install:(NSString *)file;
@end

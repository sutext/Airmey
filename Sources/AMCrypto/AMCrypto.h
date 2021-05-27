//
//  AMCrypto.h
//  Airmey
//
//  Created by supertext on 2020/8/8.
//  Copyright © 2020年 airmey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMEncryptor.h"
#import "AMDecryptor.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,AMHashAlgorithm) {
    AMHashAlgorithmMD2,
    AMHashAlgorithmMD4,
    AMHashAlgorithmMD5,
    AMHashAlgorithmSHA1,
    AMHashAlgorithmSHA224,
    AMHashAlgorithmSHA256,
    AMHashAlgorithmSHA384,
    AMHashAlgorithmSHA512,
};
FOUNDATION_EXPORT NSData* AMHashData(NSData* data,AMHashAlgorithm algorithm);
FOUNDATION_EXPORT NSString * MD5String(NSString * source);

NS_ASSUME_NONNULL_END

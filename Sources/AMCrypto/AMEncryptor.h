//
//  AMEncryptor.h
//  Airmey
//
//  Created by supertext on 2020/8/8.
//  Copyright © 2020年 airmey. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface AMEncryptor : NSObject
+(nullable instancetype)encryptorWithPath:(NSString *)pubkeyPath;
-(instancetype)initWithKey:(SecKeyRef)key;
-(nullable NSData *)encrypt:(NSString *)message;
@end
NS_ASSUME_NONNULL_END

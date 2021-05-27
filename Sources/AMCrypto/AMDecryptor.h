//
//  AMDecryptor.h
//  Airmey
//
//  Created by supertext on 2020/8/8.
//  Copyright © 2020年 airmey. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface AMDecryptor : NSObject
+(nullable instancetype)decryptorWithPath:(NSString *)privateKeyPath passwd:(NSString *)passwd;
-(instancetype)initWithKey:(SecKeyRef )key passwd:(NSString *)passwd;
-(nullable NSData *)decrypt:(NSString *)message;
-(nullable NSData *)signature:(NSString *)message;//use SHA1 sign
@end
NS_ASSUME_NONNULL_END

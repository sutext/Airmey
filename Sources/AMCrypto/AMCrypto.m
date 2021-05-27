//
//  AMCrypto.m
//  Airmey
//
//  Created by supertext on 2020/8/8.
//  Copyright © 2020年 airmey. All rights reserved.
//

#import "AMCrypto.h"
#import <CommonCrypto/CommonCrypto.h>
NSString * MD5String(NSString * source){
    const char *str = [source UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    return  [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
   
}
NSData* AMHashData(NSData* data,AMHashAlgorithm algorithm){
    switch (algorithm) {
        case AMHashAlgorithmMD2: {
            unsigned char hashByte[CC_MD2_DIGEST_LENGTH];
            CC_MD2(data.bytes, (CC_LONG)data.length, hashByte);
            return [NSData dataWithBytes:hashByte length:CC_MD2_DIGEST_LENGTH];
            break;
        }
        case AMHashAlgorithmMD4: {
            unsigned char hashByte[CC_MD4_DIGEST_LENGTH];
            CC_MD4(data.bytes, (CC_LONG)data.length, hashByte);
            return [NSData dataWithBytes:hashByte length:CC_MD4_DIGEST_LENGTH];
            break;
        }
        case AMHashAlgorithmMD5: {
            unsigned char hashByte[CC_MD5_DIGEST_LENGTH];
            CC_MD5(data.bytes, (CC_LONG)data.length, hashByte);
            return [NSData dataWithBytes:hashByte length:CC_MD5_DIGEST_LENGTH];
            break;
        }
        case AMHashAlgorithmSHA1: {
            unsigned char hashByte[CC_SHA1_DIGEST_LENGTH];
            CC_SHA1(data.bytes, (CC_LONG)data.length, hashByte);
            return [NSData dataWithBytes:hashByte length:CC_SHA1_DIGEST_LENGTH];
            break;
        }
        case AMHashAlgorithmSHA224: {
            unsigned char hashByte[CC_SHA224_DIGEST_LENGTH];
            CC_SHA224(data.bytes, (CC_LONG)data.length, hashByte);
            return [NSData dataWithBytes:hashByte length:CC_SHA224_DIGEST_LENGTH];
            break;
        }
        case AMHashAlgorithmSHA256: {
            unsigned char hashByte[CC_SHA256_DIGEST_LENGTH];
            CC_SHA256(data.bytes, (CC_LONG)data.length, hashByte);
            return [NSData dataWithBytes:hashByte length:CC_SHA256_DIGEST_LENGTH];
            break;
        }
        case AMHashAlgorithmSHA384: {
            unsigned char hashByte[CC_SHA384_DIGEST_LENGTH];
            CC_SHA384(data.bytes, (CC_LONG)data.length, hashByte);
            return [NSData dataWithBytes:hashByte length:CC_SHA384_DIGEST_LENGTH];
            break;
        }
        case AMHashAlgorithmSHA512: {
            unsigned char hashByte[CC_SHA512_DIGEST_LENGTH];
            CC_SHA512(data.bytes, (CC_LONG)data.length, hashByte);
            return [NSData dataWithBytes:hashByte length:CC_SHA512_DIGEST_LENGTH];
            break;
        }
        default: {
            break;
        }
    }
    return nil;
}

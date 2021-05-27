//
//  AMEncryptor.m
//  Airmey
//
//  Created by supertext on 2020/8/8.
//  Copyright © 2020年 airmey. All rights reserved.
//

#import "AMEncryptor.h"
#import <CommonCrypto/CommonCrypto.h>
#import <Security/Security.h>
@interface AMEncryptor()
@property(nonatomic)SecKeyRef publicKey;
@end
@implementation AMEncryptor
+(nullable instancetype)encryptorWithPath:(NSString *)pubkeyPath
{
    SecKeyRef key = [self getPublickKey:pubkeyPath];
    if (key!=NULL) {
        return [[self alloc] initWithKey:key];
    }
    return nil;
}
- (instancetype)initWithKey:(SecKeyRef)key
{
    self = [super init];
    if (self) {
        self.publicKey = key;
        
    }
    return self;
}
+(nullable SecKeyRef)getPublickKey:(NSString *)certPath {
    
    NSData *derData = [NSData dataWithContentsOfFile:certPath];
    if (derData) {
        SecTrustRef trust;
        SecKeyRef publicKey = NULL;
        SecCertificateRef cert = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)derData);
        SecPolicyRef policy = SecPolicyCreateBasicX509();
        OSStatus status = SecTrustCreateWithCertificates(cert, policy, &trust);
        if (status == errSecSuccess && trust) {
            NSArray *certs = [NSArray arrayWithObject:(__bridge id)cert];
            status = SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef)certs);
            if (status == errSecSuccess) {
                SecTrustResultType trustResult;
                status = SecTrustEvaluate(trust, &trustResult);
                // 自签名证书可信
                if (status == errSecSuccess && (trustResult == kSecTrustResultUnspecified || trustResult == kSecTrustResultProceed)) {
                    publicKey = SecTrustCopyPublicKey(trust);
                }
            }
        }
        if (trust) {
            CFRelease(trust);
        }
        if (cert) {
            CFRelease(cert);
        }
        if (policy) {
            CFRelease(policy);
        }
        if (publicKey){
            CFAutorelease(publicKey);
        }
        return publicKey;
    }
    return NULL;
}
-(NSData *)encrypt:(NSString *)message{
    // 分配内存块，用于存放加密后的数据段
    NSData *plainData = [message dataUsingEncoding:NSUTF8StringEncoding];
    size_t cipherBufferSize = SecKeyGetBlockSize(self.publicKey);
    uint8_t *cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    /*
     为什么这里要减12而不是减11?
     苹果官方文档给出的说明是，加密时，如果sec padding使用的是kSecPaddingPKCS1，
     那么支持的最长加密长度为SecKeyGetBlockSize()-11，
     这里说的最长加密长度，我估计是包含了字符串最后的空字符'\0'，
     因为在实际应用中我们是不考虑'\0'的，所以，支持的真正最长加密长度应为SecKeyGetBlockSize()-12
     */
    double totalLength = [plainData length];
    size_t blockSize = cipherBufferSize - 12;// 使用cipherBufferSize - 11是错误的!
    size_t blockCount = (size_t)ceil(totalLength / blockSize);
    NSMutableData *encryptedData = [NSMutableData data];
    // 分段加密
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        // 数据段的实际大小。最后一段可能比blockSize小。
        size_t dataSegmentRealSize = MIN(blockSize,[plainData length] - loc);
        // 截取需要加密的数据段
        NSData *dataSegment = [plainData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        OSStatus status = SecKeyEncrypt(_publicKey, kSecPaddingPKCS1, (const uint8_t *)[dataSegment bytes], dataSegmentRealSize, cipherBuffer, &cipherBufferSize);
        if (status == errSecSuccess) {
            NSData *encryptedDataSegment = [[NSData alloc] initWithBytes:(const void *)cipherBuffer length:cipherBufferSize];
            // 追加加密后的数据段
            [encryptedData appendData:encryptedDataSegment];
        } else {
            if (cipherBuffer) {
                free(cipherBuffer);
            }
            return nil;
        }
    }
    if (cipherBuffer) {
        free(cipherBuffer);
    }
    return encryptedData;
}
@end

//
//  AMDecryptor.m
//  Airmey
//
//  Created by supertext on 2020/8/8.
//  Copyright © 2020年 airmey. All rights reserved.
//

#import "AMDecryptor.h"
#import "AMCrypto.h"
#import <CommonCrypto/CommonCrypto.h>
#import <Security/Security.h>
#import <UIKit/UIKit.h>
@interface AMDecryptor()
@property(nonatomic)SecKeyRef privateKey;
@end
@implementation AMDecryptor
+(nullable instancetype)decryptorWithPath:(NSString *)privateKeyPath passwd:(NSString *)passwd{
    SecKeyRef key = [self privateKeyWithPath:privateKeyPath passwd:passwd];
    if (key!=NULL) {
        return [[self alloc] initWithKey:key passwd:passwd];
    }
    return nil;
}
- (instancetype)initWithKey:(SecKeyRef )key passwd:(NSString *)passwd{
    self = [super init];
    if (self) {
        self.privateKey = key;
    }
    return self;
}
+(SecKeyRef)privateKeyWithPath:(NSString *)path passwd:(NSString *)passwd{
    NSData *p12Data = [NSData dataWithContentsOfFile:path];
    if (!p12Data) {
        return nil;
    }
    NSMutableDictionary * options = [[NSMutableDictionary alloc] init];
    SecKeyRef privateKeyRef = NULL;
    [options setObject:passwd forKey:(__bridge id)kSecImportExportPassphrase];
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus securityError = SecPKCS12Import((__bridge CFDataRef) p12Data,
                                             (__bridge CFDictionaryRef)options, &items);
    if (securityError == noErr && CFArrayGetCount(items) > 0) {
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
        SecIdentityRef identityApp =
        (SecIdentityRef)CFDictionaryGetValue(identityDict,
                                             kSecImportItemIdentity);
        securityError = SecIdentityCopyPrivateKey(identityApp, &privateKeyRef);
        if (securityError != noErr) {
            privateKeyRef = NULL;
        }
    }
    CFRelease(items);
    return privateKeyRef;
}
-(NSData *)decrypt:(NSString *)message{
    NSData *cipherData = [message dataUsingEncoding:NSUTF8StringEncoding];
    size_t plainBufferSize = SecKeyGetBlockSize(self.privateKey);
    uint8_t *plainBuffer = malloc(plainBufferSize * sizeof(uint8_t));
    double totalLength = [cipherData length];
    size_t blockSize = plainBufferSize;
    size_t blockCount = (size_t)ceil(totalLength / blockSize);
    NSMutableData *decryptedData = [NSMutableData data];
    for (int i = 0; i < blockCount; i++) {
        NSUInteger loc = i * blockSize;
        size_t dataSegmentRealSize = MIN(blockSize, totalLength - loc);
        NSData *dataSegment = [cipherData subdataWithRange:NSMakeRange(loc, dataSegmentRealSize)];
        OSStatus status = SecKeyDecrypt(_privateKey, kSecPaddingPKCS1, (const uint8_t *)[dataSegment bytes], dataSegmentRealSize, plainBuffer, &plainBufferSize);
        if (status == errSecSuccess) {
            NSData *decryptedDataSegment = [[NSData alloc] initWithBytes:(const void *)plainBuffer length:plainBufferSize];
            [decryptedData appendData:decryptedDataSegment];
        } else {
            if (plainBuffer) {
                free(plainBuffer);
            }
            return nil;
        }
    }
    if (plainBuffer) {
        free(plainBuffer);
    }
    return decryptedData;
}

-(NSData *)signature:(NSString *)message{
    size_t signedBytesSize = SecKeyGetBlockSize(self.privateKey);
    NSData *data = AMHashData([message dataUsingEncoding:NSUTF8StringEncoding], AMHashAlgorithmSHA1);
    const uint8_t * srcData = (const uint8_t *)data.bytes;
    uint8_t  signedBytes[signedBytesSize * sizeof(uint8_t)];
    OSStatus sanityCheck = SecKeyRawSign(self.privateKey,
                                         kSecPaddingPKCS1SHA1,
                                         srcData,
                                         CC_SHA1_DIGEST_LENGTH,
                                         (uint8_t *)signedBytes,
                                         &signedBytesSize);
    if (sanityCheck == noErr){
        return  [NSData dataWithBytes:(const void *)signedBytes length:(NSUInteger)signedBytesSize];
    }
    else{
        return nil;
    }
}
@end

#import "ProvisionningProfileHelper.h"

@implementation ProvisionningProfileHelper

+ (NSDictionary *)provisioningProfileAtPath:(NSURL *)path {
    CMSDecoderRef decoder = NULL;
    CFDataRef dataRef = NULL;
    NSString *plistString = nil;
    NSDictionary *plist = nil;
    
    @try {
        CMSDecoderCreate(&decoder);
        NSData *fileData = [NSData dataWithContentsOfURL:path];
        CMSDecoderUpdateMessage(decoder, fileData.bytes, fileData.length);
        CMSDecoderFinalizeMessage(decoder);
        CMSDecoderCopyContent(decoder, &dataRef);
        plistString = [[NSString alloc] initWithData:(__bridge NSData *)dataRef encoding:NSUTF8StringEncoding];
        NSData *plistData = [plistString dataUsingEncoding:NSUTF8StringEncoding];
        NSPropertyListFormat format;
        plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:&format error:NULL];
    }
    @catch (NSException *exception) {
        LoggerError(0,@"provisioningProfileAtPath Could not decode file.\n");
    }
    @finally {
        if (decoder) CFRelease(decoder);
        if (dataRef) CFRelease(dataRef);
    }
    
    return plist;
}


+ (NSDictionary *) provisioningProfileFromContent:(NSString*)embeddedProfilePlistContent {
    NSAssert(!IsEmpty(embeddedProfilePlistContent), @"parseEmbeddedProfile - embeddedProfilePlistContent is empty");
    
    NSData* plistData = [embeddedProfilePlistContent dataUsingEncoding:NSUTF8StringEncoding];
    NSPropertyListFormat format;
    NSError * error = nil;
    //NSDictionary* plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:nil];
    NSDictionary* dictionary = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:&format error:&error];
    if (error) {
        LoggerFile(0, @"Can't read content of plist in the ipa embeddedProfile file");
        return nil;
    }
    return dictionary;
}






@end

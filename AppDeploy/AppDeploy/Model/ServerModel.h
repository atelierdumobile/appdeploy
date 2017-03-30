#import <Foundation/Foundation.h>
#define kDefaultTemplateNoNetwork @"default"

@interface ServerModel : NSObject

typedef NS_ENUM(NSInteger,ServerModelType) {ServerModelSFTP=0, ServerModelSCP=1, ServerModelLocal=2,ServerModelDropbox=3} ;//only two first enabled


@property (nonatomic, strong) NSString * key;
@property (nonatomic, strong) NSString * label;
@property (nonatomic) ServerModelType type;
@property (nonatomic, strong) NSString * server;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSString * remotePath;
@property (nonatomic, strong) NSString * httpsUrl;
@property (nonatomic, strong) NSString * publicUrl;
@property (nonatomic) BOOL isDefaultConfig;
@property (nonatomic) BOOL configEnabled;

- (id)initWithDictionary:(NSDictionary *)dict;
- (id)initWithDefaultData;//Default configuration (one basic almost empty)
- (BOOL) isValid;
- (NSDictionary *) exportData;

@end

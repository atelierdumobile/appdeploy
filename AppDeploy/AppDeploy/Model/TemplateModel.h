#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,TemplateDateFormatType) {
	TemplateDateFormatDateOnly=0,
	TemplateDateFormatDateTime=1,
	TemplateDateFormatNoDate=2
} ;


@interface TemplateModel : NSObject
@property (nonatomic, strong) NSString * key;
@property (nonatomic, strong) NSString * label;
@property (nonatomic, strong) NSString * fileName;
@property (nonatomic, strong) NSString * logo;
@property (nonatomic) TemplateDateFormatType dateFormat;
@property (nonatomic) BOOL isDefaultConfig;

- (id)initWithDictionary:(NSDictionary *)dict;
- (id)initWithDefaultDataTemplateOne;
- (id) initWithDefaultDataTemplateTwo;

- (NSString*)fileNameWithoutExtension;
- (NSURL*) path;
- (BOOL) isExist;

- (BOOL) isValid;
- (NSDictionary *) exportData;
+ (NSArray*) findUserHtmlTemplate;

@end

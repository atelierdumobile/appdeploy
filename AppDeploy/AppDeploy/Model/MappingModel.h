#import <Foundation/Foundation.h>
#import "TemplateModel.h"

@interface MappingModel : NSObject
@property (nonatomic, strong) NSString * bundleId;
@property (nonatomic, strong) NSString * templateKey;
@property (nonatomic, strong) TemplateModel * model;


- (BOOL) isValid;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *) exportData;
	
@end

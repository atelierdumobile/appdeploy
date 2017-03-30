#import "ServerModel.h"
#import "ConstantsSecured.h"
@implementation ServerModel


#define kKey @"key"
#define kLabel @"label"
#define kServer @"server"
#define kUsername @"username"
#define kPassword @"password"
#define kRemotePath @"remotePath"
#define KHttpsUrl @"httpsUrl"
#define kPublicUrl @"publicUrl"
#define kType @"type"
#define kConfigEnabled @"configEnabled"

#define kTypeDropbox @"dropbox"
#define kTypeSFTP @"sftp"
#define kTypeSCP @"scp"
#define kTypeLocal @"local"


- (BOOL) isValid {
	switch(self.type) {
		case ServerModelLocal:
			if (IsEmpty(self.label)) return NO;
		case ServerModelSFTP:
			break;
		case ServerModelSCP:
			if (
				IsEmpty(self.server) ||
				IsEmpty(self.username) ||
				IsEmpty(self.remotePath) ||
				IsEmpty(self.httpsUrl) ||
				IsEmpty(self.publicUrl) ) {
				return NO;
			}
		case ServerModelDropbox:
			return YES; //TODO not implemented yet
			break;
	}
    
    if (IsEmpty(self.publicUrl)) return NO;
    
	return YES;
}

- (id)initWithDictionary:(NSDictionary *)dict {
	
	self = [super init];
	if (self != nil) {
		self.key = [dict objectForKey:kKey];
		self.label = [dict objectForKey:kLabel];
		self.server = [dict objectForKey:kServer];
		self.username = [dict objectForKey:kUsername];
		self.password = [dict objectForKey:kPassword];
		self.remotePath = [dict objectForKey:kRemotePath];
		self.httpsUrl = [dict objectForKey:KHttpsUrl];
		self.publicUrl = [dict objectForKey:kPublicUrl];
		self.isDefaultConfig = false;
		
		NSString * type = [dict objectForKey:kType];
		
		if ([type isEqualToString:kTypeDropbox]) {
			self.type = ServerModelDropbox;
		}
		else if ([type isEqualToString:kTypeSFTP]) {
			self.type = ServerModelSFTP;
		}
		else if ([type isEqualToString:kTypeLocal]) {
			self.type = ServerModelLocal;
		}
		else if ([type isEqualToString:kTypeSCP]) {
			self.type = ServerModelSCP;
		}
		else {
			LoggerData(0, @"No type for data !!! %d", (int) self.type);
		}
	}
	return self;
}


- (id)initWithDefaultData {
	self = [super init];
	if (self != nil) {
		self.label = @"🔒 No network";
		self.key = kDefaultTemplateNoNetwork;
		self.type = ServerModelLocal;
        self.isDefaultConfig = YES;
	}
	return self;

}


- (NSString*) description {
	return [NSString stringWithFormat:@"key=\"%@\" type=%ld \"%@\" %@ %@ %@ %@",
			self.key,
			self.type,
			self.label,
			self.username,
			self.remotePath,
			self.httpsUrl,
			self.publicUrl];
}


- (NSDictionary *) exportData {
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if (!IsEmpty(self.key)) { [dictionary setObject:self.key forKey:kKey];}
	if (!IsEmpty(self.label)) { [dictionary setObject:self.label forKey:kLabel]; }
	if (!IsEmpty(self.server)) { [dictionary setObject:self.server forKey:kServer]; }
	if (!IsEmpty(self.username)) { [dictionary setObject:self.username forKey:kUsername]; }
	if (!IsEmpty(self.password)) { [dictionary setObject:self.password forKey:kPassword]; }
	if (!IsEmpty(self.remotePath)) { [dictionary setObject:self.remotePath forKey:kRemotePath]; }
	if (!IsEmpty(self.httpsUrl)) { [dictionary setObject:self.httpsUrl forKey:KHttpsUrl]; }
	if (!IsEmpty(self.publicUrl)) { [dictionary setObject:self.publicUrl forKey:kPublicUrl]; }
	
	switch(self.type) {
		case ServerModelSFTP:
			[dictionary setObject:kTypeSFTP forKey:kType];
			break;
		case ServerModelLocal:
			[dictionary setObject:kTypeLocal forKey:kType];
			break;
		case ServerModelSCP:
			[dictionary setObject:kTypeSCP forKey:kType];
			break;
		case ServerModelDropbox:
			[dictionary setObject:kTypeDropbox forKey:kType];
			break;
	}
	
	return dictionary;
}

@end

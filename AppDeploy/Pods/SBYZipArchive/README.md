# SBYZipArchive
[![Build Status](https://travis-ci.org/shoby/SBYZipArchive.svg?branch=master)](https://travis-ci.org/shoby/SBYZipArchive)

SBYZipArchive is a simple unzip library to extract files from a large archive.
You can extract contents without expanding the whole archive.

# Usage
## Synchronous extraction for a small file
```objc
NSURL *url = [NSURL URLWithString:@"zip_file_path"];

SBYZipArchive *archive = [[SBYZipArchive alloc] initWithContentsOfURL:url error:nil];
[archive loadEntriesWithError:nil];

SBYZipEntry *entry = archive.entries[0];

NSData *data = [entry dataWithError:nil];
```

## Asynchronous extraction for a large file
```objc
NSURL *url = [NSURL URLWithString:@"zip_file_path"];

SBYZipArchive *archive = [[SBYZipArchive alloc] initWithContentsOfURL:url error:nil];
[archive loadEntriesWithError:nil];

SBYZipEntry *entry = archive.entries[0];

NSURL *destinationURL = [NSURL URLWithString:@"destination_directory_path"];

[entry unzipToURL:destinationURL success:^(NSURL *unzippedFileLocation) {
    NSData *data = [NSData dataWithContentsOfURL:unzippedFileLocation];
} failure:^(NSError *error) {
    NSLog(@"%@", error);
} progress:^(NSUInteger bytesUnzipped, NSUInteger totalBytes) {
    NSLog(@"progress:%f", (double)bytesUnzipped/totalBytes);
}];
```

# License
SBYZipArchive is licensed under the MIT license.
Included minizip is licensed under the zlib license.

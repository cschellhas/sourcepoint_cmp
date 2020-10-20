#import "SourcepointCmpPlugin.h"
#if __has_include(<sourcepoint_cmp/sourcepoint_cmp-Swift.h>)
#import <sourcepoint_cmp/sourcepoint_cmp-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "sourcepoint_cmp-Swift.h"
#endif

@implementation SourcepointCmpPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSourcepointCmpPlugin registerWithRegistrar:registrar];
}
@end

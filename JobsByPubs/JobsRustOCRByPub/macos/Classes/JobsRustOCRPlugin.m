//
//  JobsRustOCRPlugin.m
//  JobsRustOCRByPub
//
//  Created by Jobs on 2026年11月16日，星期一.
//

#import "JobsRustOCRPlugin.h"
#if __has_include(<JobsRustOCR/JobsRustOCR.h>)
#import <JobsRustOCR/JobsRustOCR.h>
#define JOBS_HAS_OCR 1
#else
#define JOBS_HAS_OCR 0
#endif

@implementation JobsRustOCRPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"jobs/rust_ocr"
                                                             binaryMessenger:registrar.messenger];
    [registrar addMethodCallDelegate:[self new] channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
#if JOBS_HAS_OCR
    if ([call.method isEqualToString:@"coreVersion"]) {
        result([JobsRustOCR coreVersion]);
        return;
    }
    if ([call.method isEqualToString:@"cancel"]) {
        [JobsRustOCR cancel];
        result(nil);
        return;
    }
    if ([call.method isEqualToString:@"sampleImage"]) {
        NSImage *image = [JobsRustOCR sampleImage];
        NSBitmapImageRep *bitmap = image ? [NSBitmapImageRep imageRepWithData:image.TIFFRepresentation] : nil;
        NSData *data = [bitmap representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
        if (!data) {
            result([FlutterError errorWithCode:@"sample_missing" message:@"Bundled OCR sample is unavailable" details:nil]);
            return;
        }
        result([FlutterStandardTypedData typedDataWithBytes:data]);
        return;
    }
    NSImage *image = nil;
    if ([call.method isEqualToString:@"recognizeSample"]) {
        image = [JobsRustOCR sampleImage];
    } else if ([call.method isEqualToString:@"recognizeImage"]) {
        NSDictionary *arguments = [call.arguments isKindOfClass:NSDictionary.class] ? call.arguments : @{};
        FlutterStandardTypedData *data = arguments[@"bytes"];
        if ([data isKindOfClass:FlutterStandardTypedData.class]) {
            image = [[NSImage alloc] initWithData:data.data];
        }
    } else {
        result(FlutterMethodNotImplemented);
        return;
    }
    if (!image) {
        result([FlutterError errorWithCode:@"invalid_image" message:@"The image cannot be decoded" details:nil]);
        return;
    }
    [JobsRustOCR recognizeImage:image completion:^(NSDictionary *value, NSError *error) {
        if (error) {
            result([FlutterError errorWithCode:@"ocr_failed" message:error.localizedDescription details:@(error.code)]);
            return;
        }
        result(value);
    }];
#else
    if ([call.method isEqualToString:@"cancel"]) {
        result(nil);
        return;
    }
    result([FlutterError errorWithCode:@"core_unavailable" message:@"The Rust OCR SDK has not been packaged in this build" details:nil]);
#endif
}

@end

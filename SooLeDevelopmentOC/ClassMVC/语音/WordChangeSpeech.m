//
//  WordChangeSpeech.m
//  SooLeDevelopmentOC
//
//  Created by songlei on 2016/11/19.
//  Copyright © 2016年 songlei. All rights reserved.
//

#import "WordChangeSpeech.h"
#import <AVFoundation/AVFoundation.h>


@interface WordChangeSpeech()<AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) AVSpeechSynthesizer *avSpeech;

@end


@implementation WordChangeSpeech

- (AVSpeechSynthesizer *)avSpeech{
    if (!_avSpeech) {
        _avSpeech = [[AVSpeechSynthesizer alloc]init];
    }
    
    return _avSpeech;
}


- (instancetype)init{
    
    if (self = [super init]) {
        _avSpeech.delegate = self;
    }
    
    return self;
    
}


- (void)read:(NSString *)str{
    
    AVSpeechUtterance * aVSpeechUtterance = [[AVSpeechUtterance alloc] initWithString:str];
    
    aVSpeechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate;
    
    aVSpeechUtterance.voice =[AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    
    [self.avSpeech speakUtterance:aVSpeechUtterance];
    
    
    
}

- (void)stopRead{
    
     [self.avSpeech stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    
    
    
}

#pragma mark- delegate
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    
    NSLog(@"阅读完毕");
    
}


@end

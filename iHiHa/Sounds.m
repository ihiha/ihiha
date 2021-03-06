//
//  Sounds.m
//  iHiHa
//
//  Created by Wouter Timmer on 29-09-12.
//  Copyright (c) 2012 Wouter Timmer. All rights reserved.
//  Copy lokaal -> Master
//

#import "Sounds.h"


@interface Sounds ()

@end

@implementation Sounds


-(void)Ib1 {
    
    [self prepairaudiofile:@"sound level 1.caf" alternative:@"HiHiHaHa Level 1" ];
   
    ib1Button.enabled = NO;
    ib2Button.enabled = YES;
    ib3Button.enabled = YES;
    
}
-(void)Ib2{
    
    [self prepairaudiofile:@"sound level 2.caf" alternative:@"HiHiHaHa Level 2" ];
   
    ib1Button.enabled = YES;
    ib2Button.enabled = NO;
    ib3Button.enabled = YES;
}
-(void)Ib3 {
    [self prepairaudiofile:@"sound level 3.caf" alternative:@"HiHiHaHa Level 3" ];
    ib1Button.enabled = YES;
    ib2Button.enabled = YES;
    ib3Button.enabled = NO;
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //voortgangs bank tonen
    [NSTimer scheduledTimerWithTimeInterval: (24/60)
                                     target: self
                                   selector: @selector(Voortgang)
                                   userInfo: nil
                                    repeats: YES];
    Progress.hidden = YES ;
    
    [self Ib2];
   
}
-(BOOL )isRecordFileactive {
    
    AVAudioPlayer *player =   [[AVAudioPlayer alloc]
                               initWithContentsOfURL:[self soundfileURL]
                               error:nil];
    return  player.duration > 0 ;
}
-(void)prepairaudiofile:(NSString *)_audiofile alternative:(NSString *)alternativefile  {
    
    
    // Eerkijken of er een geldig audio file is
    AudioFile = _audiofile;
    OrgAudioFile = alternativefile;
    [self SetResetButton];
    
}
-(void)SetResetButton {
    if ([self isRecordFileactive])  {
        resetButton.hidden = NO;
    } else {
        resetButton.hidden = YES;
        
    }
}
-(NSString *)Docsdir {
    NSArray *dirPaths;    
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    return [dirPaths objectAtIndex:0];
}
-(NSURL *)soundfileURL {
    NSString *soundFilePath = [[self Docsdir]
                               stringByAppendingPathComponent:AudioFile];
    
   return  [NSURL fileURLWithPath:soundFilePath];
}
-(NSURL *)OrgMP3SoundFile {
    NSString *path = [[NSBundle mainBundle] pathForResource:OrgAudioFile ofType:@"mp3"];
    return  [NSURL fileURLWithPath:path];
}
-(void) prepareaudio {

    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
    
    audioRecorder = [[AVAudioRecorder alloc]
                     initWithURL:[self soundfileURL]
                     settings:recordSettings
                     error:&error];
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
        
    } else {
        [audioRecorder prepareToRecord];
    }
    
    
}
-(void)viewDidAppear:(BOOL)animated {
    //Verplaats iAd banner naar boven
    [self adOverTop];
    [self Animatiebanner];
   // [self initRotate];

}
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)io {
    [self adOverTop];
    [self Animatiebanner];
}
#pragma buttons



-(void) Voortgang {
    
    if (audioRecorder.recording ) {
        Progress.hidden = NO ;
       Progress.progress = audioRecorder.currentTime / 5;
        
    } else if (audioPlayer.playing) {
        Progress.hidden = NO ;
        Progress.progress = audioPlayer.currentTime / audioPlayer.duration;
    } else {
        Progress.hidden = YES ;
    }

}
#pragma audio
-(void) recordAudio{
    if (!audioRecorder.recording)
    {
        [self prepareaudio];
        playButton.enabled = NO;
        stopButton.enabled = YES;
        recordButton.enabled = NO ;
        [audioRecorder record];
        
        //Stop audio naar paar seconden
        [NSTimer scheduledTimerWithTimeInterval: 5
                                         target: self
                                       selector: @selector(stop)
                                       userInfo: nil
                                        repeats: NO];
    }
}
-(void)stop{
    stopButton.enabled = NO;
    playButton.enabled = YES;
    recordButton.enabled = YES;
    
    if (audioRecorder.recording)
    {
        [audioRecorder stop];
    } else if (audioPlayer.playing) {
        [audioPlayer stop];
    }
    [self SetResetButton];

}
-(void) playAudio{
    if (!audioRecorder.recording)
    {
        stopButton.enabled = YES;
        recordButton.enabled = NO;
         playButton.enabled = NO;
       
        NSURL *FileToPlay;
        if ([self isRecordFileactive] ) {
            FileToPlay = [self soundfileURL];
        } else {
            FileToPlay = [self  OrgMP3SoundFile];
        }
        
        NSError *error;
        
        
        
        audioPlayer = [[AVAudioPlayer alloc]
                       initWithContentsOfURL:FileToPlay
                       error:&error];
        
        audioPlayer.delegate = self;

        if (error)
            NSLog(@"Error: %@",
                  [error localizedDescription]);
        else
        
            [audioPlayer play];
        
    }
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    recordButton.enabled = YES;
    stopButton.enabled = NO;
    playButton.enabled = YES;
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"Decode Error occurred");
}
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
   }
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"Encode Error occurred");
}
-(void)del {
    NSString *soundFilePath = [[self Docsdir]
                               stringByAppendingPathComponent:AudioFile];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:soundFilePath error:NULL];
    [self SetResetButton];
}

#pragma Banner
-(void)adOverTop {
   // NSLog(@"adOverTop");
    //adView.frame =  CGRectOffset(adView.frame, 0, -adView.frame.size.height);
    adView.frame = CGRectMake(0, -adView.frame.size.height, adView.frame.size.width, adView.frame.size.height);
    adView.hidden = NO;
}
-(void)Animatiebanner {
    //Als banner nog niet is getoond deze animeren
   // NSLog(@"%f %d",adView.frame.origin.y, [adView isBannerLoaded] );
    if ( [adView isBannerLoaded] && adView.frame.origin.y < 0  ) {
        
        [ADBannerView animateWithDuration: 2
                                    delay: 0
                                  options:UIViewAnimationCurveLinear
                               animations:^{
                                   adView.frame = CGRectOffset(adView.frame, 0, adView.frame.size.height);                     }
                               completion:^(BOOL finished){
                                   
                               }];
        
        
    }
    if ( ![adView isBannerLoaded] ) {
        [ADBannerView animateWithDuration: 0.5
                                    delay: 0
                                  options:UIViewAnimationCurveLinear
                               animations:^{
                                   adView.frame = CGRectMake(0, -adView.frame.size.height, adView.frame.size.width, adView.frame.size.height);
                               }
                               completion:^(BOOL finished){
                                   
                               }];
    }
}
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"Error [%@]",error);
    [self Animatiebanner];
}
-(void)bannerViewWillLoadAd:(ADBannerView *)banner {
    //iAd word getoont
    //adView.hidden = NO ;
   // NSLog(@"bannerViewWillLoadAd %d",[banner isBannerLoaded]);
    [self Animatiebanner];
    
    
}
-(void)bannerViewDidLoadAd:(ADBannerView *)banner {
    // adView.hidden = YES ;
    // NSLog(@"bannerViewDidLoadAd %d",[banner isBannerLoaded]);
    [self Animatiebanner];
      
}
-(void)bannerViewActionDidFinish:(ADBannerView *)banner {
    //iAd word weer verwijderd
   //NSLog(@"bannerViewActionDidFinish %d",[banner isBannerLoaded]);
    [self Animatiebanner];
}

@end

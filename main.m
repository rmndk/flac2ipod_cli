//
//  main.m
//  flac2ipod_cli
//
//  Created by Raymond Edwards on 12-06-15
//

#import <Foundation/Foundation.h>
#import "iTunes.h"

void parseArgs(){
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    NSLog(@"%@",arguments);
}

iTunesSource* getDevice(iTunesApplication *iTunes){
    
    SBElementArray *srcs = [iTunes sources];
    iTunesSource *dev = nil;
    
    for (iTunesSource *obj in srcs){
        //we're going to assume there's only one device connected... sorry
        if([obj kind] == iTunesESrcIPod) {
            dev = obj;
            return dev;
        }
    }
    return dev;
}

iTunesPlaylist* getDevicePlaylist(iTunesSource *dev){
    
    SBElementArray *pls = [dev playlists];
    iTunesPlaylist *devpl = nil;
    
    for(iTunesPlaylist *p in pls){
        //NSLog(@"name is: %@",[p name]);
        //NSLog(@"Is of type: %@", [p className]);
        if([[p name] isEqualToString:@"iPod touch"]){
            devpl = p;
            return devpl;
        }
    }
    return devpl;
}

void printDevicePlaylist(iTunesPlaylist *p){
    
    SBElementArray *tracks = [p tracks];
    
    for(iTunesTrack *t in tracks){
        NSLog(@"name: %@",[t name]);
    }
}

void findPaths(NSString *flacpath, NSString *metaflacpath, NSString *lamepath){
    
    NSTask *which = [[NSTask alloc] init];
    NSPipe *output = [NSPipe pipe];
    [which setLaunchPath:@"/usr/bin/which"];
    [which setArguments:[NSArray arrayWithObjects:@"flac",@"metaflac",@"lame",nil]];
    [which setStandardOutput:output];
    [which launch];
    [which waitUntilExit];
    NSData *outdata = [[output fileHandleForReading] readDataToEndOfFile];
    NSString *fps = [[[NSString alloc] initWithData:outdata encoding:NSUTF8StringEncoding] autorelease];
    [output release];
    [outdata release];
    [which release];
    NSArray *filepaths = [fps componentsSeparatedByString:@"\n"];
    
    if([filepaths count]!=3){
        printf("Didn't find all paths.  Please make sure they are installed.\n");
        exit(1);
    }
    
    flacpath = [filepaths objectAtIndex:0];
    metaflacpath = [filepaths objectAtIndex:1];
    lamepath = [filepaths objectAtIndex:2];
}

void convert(){
    
}

void pushToiPod(iTunesApplication *iTunes, iTunesPlaylist *devpl, NSString *filepath){
    //let's try adding something
    iTunesTrack *track = [iTunes add:[NSArray arrayWithObject:[NSURL fileURLWithPath:filepath]]
                                  to:devpl];
    NSLog(@"track is: %@", track);
}

int main(int argc, const char * argv[])
{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    if([iTunes isRunning]){
        printf("Please start iTunes and try again.\n");
        exit(1);
    }
    NSFileManager *filemgr;
    NSString *currentpath;
    iTunesSource *dev = nil;
    iTunesPlaylist *devpl = nil;
    NSString *userfilepath = nil;
    filemgr = [NSFileManager defaultManager];
    currentpath = [filemgr currentDirectoryPath];
    NSString *flacpath = nil, *metaflacpath = nil, *lamepath = nil;
    
    parseArgs();
    exit(0);
    
    if((dev = getDevice(iTunes)) == nil){
        printf("A usable device doesn't seem to be connected. Woops.\n");
        exit(1);
    }
    
    if((devpl = getDevicePlaylist(dev)) == nil){
        printf("Can't find the master playlist on the device. Woops.\n");
        exit(1);
    }
    
    findPaths(flacpath, metaflacpath, lamepath);
    //convert();
    pushToiPod(iTunes, devpl, userfilepath);
    
    printf("Please start iTunes and try again.\n");
    
    [pool drain];
    return 0;
}
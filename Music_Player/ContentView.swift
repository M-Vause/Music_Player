//
//  ContentView.swift
//  Music_Player
//
//  Created by Michael on 03/10/2020.
//

import SwiftUI
import StoreKit
import MediaPlayer

struct ContentView: View {
    @State private var musicPlayer = MPMusicPlayerController.systemMusicPlayer
    @State private var isPlaying = false
    let seconds = 0.01
    
    let center = NotificationCenter.default
    let mainQueue = OperationQueue.main
    
    var body: some View {
        var pb = Image(systemName: self.isPlaying ? "pause.fill" : "play.fill")
        TabView(selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
            ZStack() {
                Color.black
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 15) {
                    GeometryReader { geometry in
                        VStack(spacing: 24) {
                            Text(" ")
                                .font(.system(size: 1))
                                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                                        if self.musicPlayer.playbackState == .playing {
                                            self.isPlaying = false
                                            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                                self.isPlaying = true
                                            }
                                        } else {
                                            self.isPlaying = true
                                            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                                self.isPlaying = false
                                            }
                                        }
                                        
                                        pb = Image(systemName: self.isPlaying ? "pause.fill" : "play.fill")
                                    }
                                
                            let currItem : MPMediaItem? = musicPlayer.nowPlayingItem;
                            let art : UIImage? = currItem?.artwork?.image(at: CGSize(width: geometry.size.width - 90, height: geometry.size.width - 90));
                            
                            let empty = UIImage(ciImage: .white)
                            
                            let stock = Image(systemName: "a.square")
                            let image = Image(uiImage: art ?? empty)
                            
                            if UIDevice.current.userInterfaceIdiom == .phone{
                                ZStack() {
                                    stock
                                        .resizable()
                                        .frame(width: geometry.size.width - 90, height: geometry.size.width - 90)
                                        .shadow(radius: 10)
                                        .foregroundColor(.white)
                                    
                                    image
                                        .resizable()
                                        .frame(width: geometry.size.width - 90, height: geometry.size.width - 90)
                                        .cornerRadius(20)
                                        .shadow(radius: 10)
                                }
                            } else if UIDevice.current.userInterfaceIdiom == .pad {
                                Text(" ")
                                    .font(.system(size: 1))
                                
                                ZStack() {
                                    stock
                                        .resizable()
                                        .frame(width: geometry.size.width - 190, height: geometry.size.width - 190)
                                        .shadow(radius: 10)
                                        .foregroundColor(.white)
                                    
                                    image
                                        .resizable()
                                        .frame(width: geometry.size.width - 190, height: geometry.size.width - 190)
                                        .cornerRadius(40)
                                        .shadow(radius: 10)
                                }
                            }
                             
                            VStack(spacing: 8) {
                                Text(self.musicPlayer.nowPlayingItem?.title ?? "Not Playing")
                                    .font(Font.system(.title).bold())
                                    .foregroundColor(.white)
                                
                                Text(self.musicPlayer.nowPlayingItem?.artist ?? "")
                                    .font(.system(.headline))
                                    .foregroundColor(.white)
                            }
                            .frame(width: geometry.size.width, alignment: .center)
                        }
                    }
                    
                    VStack (spacing: 15) {
                        HStack(spacing: 40) {
                            Button(action: {
                                let playTime = self.musicPlayer.currentPlaybackTime
                                
                                if playTime <= 3 {
                                    self.musicPlayer.skipToPreviousItem()
                                } else {
                                    self.musicPlayer.skipToBeginning()
                                }
                                
                                if self.musicPlayer.playbackState == .paused || self.musicPlayer.playbackState == .stopped {
                                    self.isPlaying = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                        self.isPlaying = false
                                    }
                                } else if self.musicPlayer.playbackState == .playing {
                                    self.isPlaying = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                        self.isPlaying = true
                                    }
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .frame(width: 80, height: 80)
                                        .accentColor(.pink)
                                        .shadow(radius: 10)
                                    Image(systemName: "backward.fill")
                                        .foregroundColor(.white)
                                        .font(.system(.title))
                                }
                            }
                         
                            Button(action: {
                                if self.musicPlayer.playbackState == .paused || self.musicPlayer.playbackState == .stopped {
                                    self.musicPlayer.play()
                                    self.isPlaying = true
                                } else if self.musicPlayer.playbackState == .playing {
                                    self.musicPlayer.pause()
                                    self.isPlaying = false
                                } else {
                                    print("play state error")
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .frame(width: 80, height: 80)
                                        .accentColor(.pink)
                                        .shadow(radius: 10)
                                    
                                    pb
                                        .foregroundColor(.white)
                                        .font(.system(.title))
                                }
                            }
                         
                            Button(action: {
                                self.musicPlayer.skipToNextItem()
                                
                                if self.musicPlayer.playbackState == .paused || self.musicPlayer.playbackState == .stopped {
                                    self.isPlaying = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                        self.isPlaying = false
                                    }
                                } else if self.musicPlayer.playbackState == .playing {
                                    self.isPlaying = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                        self.isPlaying = true
                                    }
                                }
                                
                            }) {
                                ZStack {
                                    Circle()
                                        .frame(width: 80, height: 80)
                                        .accentColor(.pink)
                                        .shadow(radius: 10)
                                    Image(systemName: "forward.fill")
                                        .foregroundColor(.white)
                                        .font(.system(.title))
                                }
                            }
                        }
                     
                        Button(action: {
                            if self.musicPlayer.playbackState == .playing {
                                self.musicPlayer.pause()
                                self.isPlaying = false
                            }
                            
                            let mediaItems = MPMediaQuery.songs().items
                            let size = mediaItems?.count
                            
                            if size == 0 {
                                return
                            }
                            
                            var ints = [Int]()
                            var tracks = [MPMediaItem]()
                            var counter = 0
                            
                            while tracks.count < 15 {
                                let number = Int.random(in: 0..<size!)
                                let track = mediaItems![number]
                                
                                if !ints.contains(number) && !track.isCloudItem {
                                    ints.append(number)
                                    tracks.append(track)
                                }
                                
                                counter += 1
                                
                                if counter > 100{
                                    break
                                }
                            }
                            
                            if tracks.count == 0 {
                                if !mediaItems![0].isCloudItem {
                                    tracks.append(mediaItems![0])
                                } else {
                                    tracks.append(mediaItems![1])
                                }
                            }
                            
                            let mediaCollection = MPMediaItemCollection(items: tracks)
                            musicPlayer.setQueue(with: mediaCollection)

                            musicPlayer.play()
                            self.isPlaying = true
                            
                            if self.musicPlayer.playbackState == .playing {
                                self.isPlaying = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                    self.isPlaying = true
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .frame(width: 80, height: 80)
                                    .accentColor(.pink)
                                    .shadow(radius: 10)
                                Image(systemName: "shuffle")
                                    .foregroundColor(.white)
                                    .font(.system(.title))
                            }
                        }
                        
                        Text(" ")
                            .font(.system(size: 1))
                    }
                }
            }
                .tag(0)
                .tabItem {
                    VStack {
                        Image(systemName: "music.note")
                        Text("Player")
                    }
                }
        }
        .accentColor(.pink)
        .onAppear() {
            if self.musicPlayer.playbackState == .playing {
                self.isPlaying = true
            } else {
                self.isPlaying = false
            }
            self.musicPlayer.beginGeneratingPlaybackNotifications()
            
            self.center.addObserver(forName: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil, queue: mainQueue) { (note) in
                if self.musicPlayer.playbackState == .playing {
                    self.isPlaying = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        self.isPlaying = true
                    }
                } else {
                    self.isPlaying = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        self.isPlaying = false
                    }
                }
                
                pb = Image(systemName: self.isPlaying ? "pause.fill" : "play.fill")
            }
            
            self.center.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil, queue: mainQueue) { (note) in
                if self.musicPlayer.playbackState == .playing {
                    self.isPlaying = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        self.isPlaying = true
                    }
                } else {
                    self.isPlaying = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                        self.isPlaying = false
                    }
                }
            }
        }
        .onDisappear(){
            self.musicPlayer.endGeneratingPlaybackNotifications()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
        }
    }
}

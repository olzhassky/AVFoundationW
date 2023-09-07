//
//  ViewController.swift
//  AVFoundationW
//
//  Created by Olzhas Zhakan on 06.09.2023.
//



import UIKit
import AVFoundation
import SnapKit

class ViewController: UIViewController {
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var audioURL: URL?
    var player: AVAudioPlayer?
    let recordButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.layer.cornerRadius = 50
        button.backgroundColor = .red
        button.setTitle("Запись", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.addTarget(self, action: #selector(startStopRecording), for: .touchUpInside)
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    let playButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.layer.cornerRadius = 50
        button.backgroundColor = .blue
        button.setTitle("Play", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.addTarget(self, action: #selector(playSound), for: .touchUpInside)
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .yellow
        progress.trackTintColor = .gray
        return progress
    }()
    let backImage: UIImageView = {
        let image = UIImageView(frame: UIScreen.main.bounds)
        image.image = UIImage(named: "backimage")
        image.contentMode = .scaleToFill
        return image
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(recordButton)
        view.addSubview(playButton)
        view.addSubview(progressView)
        self.view.insertSubview(backImage, at: 0)
        makeConstraints()
        let audioSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: getDocumentsDirectory().appendingPathComponent("audio.m4a"), settings: audioSettings)
            audioRecorder?.prepareToRecord()
        } catch {
            print("Ошибка при настройке аудиозаписи: \(error.localizedDescription)")
        }
    }
    func makeConstraints() {
        recordButton.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(100)
            $0.top.equalToSuperview().offset(300)
            $0.centerX.equalToSuperview()
        }
        playButton.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(100)
            $0.top.equalToSuperview().offset(450)
            $0.centerX.equalToSuperview()
        }
        progressView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.right.equalToSuperview().inset(25)
        }
    }
    func updateProgress() {
        guard let player = player else { return }
        let progress = Float(player.currentTime / player.duration)
        progressView.progress = progress
    }
    
    
    @objc func startStopRecording() {
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
            recordButton.setTitle("Запись", for: .normal)
        } else {
            audioURL = getDocumentsDirectory().appendingPathComponent("audio.m4a")
            try? FileManager.default.removeItem(at: audioURL!)
            audioRecorder?.record()
            recordButton.setTitle("Остановить", for: .normal)
        }
    }
    @objc func playSound() {
        let url = getDocumentsDirectory().appendingPathComponent("audio.m4a")
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            guard let player = player else { return }
            player.delegate = self
            player.prepareToPlay()
            player.play()
            let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.updateProgress()
            }
            RunLoop.main.add(timer, forMode: .common)
        } catch let error {
            print(error.localizedDescription)
        }
        print(url)
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first!
    }
}

extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        progressView.progress = 0
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
}





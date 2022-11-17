//
//  MovieCollectionViewCell.swift
//  VideoFeedClient
//
//  Created by Chris on 16.11.2022.
//

import UIKit
import Kingfisher
import VersaPlayer

class VideoCollectionViewCell: BaseCollectionNibCell {
    // MARK: - IBOutlets
    @IBOutlet weak var videoPlayer: VersaPlayerView!
    @IBOutlet weak var uploaderNameLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    //    @IBOutlet weak var controls: VersaPlayerControls!

    public private(set) var videoUrl: URL?
    private var vm: MovieCellViewModel?
    private var control: VersaPlayerControls?

    // MARK: - LifeCycle
    override func prepareForReuse() {
        super.prepareForReuse()

    }

    // MARK: - Public Methods
    func setUp(vm: MovieCellViewModel) {
        self.vm = vm

        self.uploaderNameLabel.text = vm.user?.name ?? R.string.localizable.unknownOwner()
        if let urlString = vm.lowQualityVideo?.url, let url = URL(string: urlString) {
            videoUrl = url
            if self.control == nil {
                let controlView = VideoControlView()
                self.control = controlView.controls
                self.videoPlayer.use(controls: controlView.controls)
            }

            let item = VersaPlayerItem(url: url)
            videoPlayer.set(item: item)
            videoPlayer.layer.backgroundColor = UIColor.black.cgColor
            videoPlayer.controls?.behaviour.show()
            videoPlayer.controls?.behaviour.shouldHideControls = false
            videoPlayer.player.volume = 1
        }
        muteButton.setTitle(videoPlayer.player.isMuted ? R.string.localizable.unmute() : R.string.localizable.mute(), for: .normal)
    }

    @IBAction func soundToggle(_ sender: Any) {
        videoPlayer.player.isMuted = !videoPlayer.player.isMuted
        muteButton.setTitle(videoPlayer.player.isMuted ? R.string.localizable.unmute() : R.string.localizable.mute(), for: .normal)
    }

    func startVideo() {
        videoPlayer.player.play()
    }

    func pauseVideo() {
        videoPlayer.player.pause()
    }
}

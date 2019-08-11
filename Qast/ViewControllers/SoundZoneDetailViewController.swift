//
//  SoundZoneDetailViewController.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/22/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import UIKit

class SoundZoneDetailViewController: UIViewController {

    let soundZone: SoundZone?
    let soundZoneTitle = UILabel()
    let soundZoneDescription: UITextView = UITextView()
    let soundZoneMainImage: UIImageView = UIImageView()
    let trackListTableView: UITableView = UITableView()
    let dismissIcon = UIImageView(image: UIImage(named: "x-button"))
    
    let smt: UMGStreamMetadataAPIManager = UMGStreamMetadataAPIManager()
    
    init(_ soundZone: SoundZone) {
        self.soundZone = soundZone
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackListTableView.delegate = self
        trackListTableView.dataSource = self
        
        setupUI()
    }

}

// MARK: UI Setup

extension SoundZoneDetailViewController {
    func setupUI() {
        setupTitle()
        setupDismissIcon()
        setupImage()
        setupDescription()
        setupTracklistTableView()
    }
    
    func setupDismissIcon() {
        view.addSubview(dismissIcon)
        dismissIcon.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.left.top.equalToSuperview().offset(30)
        }
        let dismissIconTapped = UITapGestureRecognizer(target: self, action: #selector(self.dismiss(_:)))
        dismissIcon.addGestureRecognizer(dismissIconTapped)
        dismissIcon.isUserInteractionEnabled = true
    }
    
    func setupTitle() {
        view.addSubview(soundZoneTitle)
        soundZoneTitle.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(60)
        }
        soundZoneTitle.textColor = .black
        soundZoneTitle.text =  soundZone?.id
        soundZoneTitle.textAlignment = .center
    }
    
    func setupImage() {
        view.addSubview(soundZoneMainImage)
        
        guard let url = URL(string: soundZone!.imageURL) else { return }
        
        soundZoneMainImage.sd_setImage(with: url) { (image, error, cache, url) in
            self.soundZoneMainImage.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
        }
    }
    
    func setupDescription() {
        view.addSubview(soundZoneTitle)
        soundZoneTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(60)
        }
        soundZoneTitle.textColor = .black
        soundZoneTitle.text =  soundZone?.description
        soundZoneTitle.textAlignment = .center
    }
    
    func setupTracklistTableView() {
        trackListTableView.separatorStyle = .none
        trackListTableView.showsVerticalScrollIndicator = false
        trackListTableView.backgroundColor = .clear
        
        view.addSubview(trackListTableView)
        
        trackListTableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(100)
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: Gesture Recognizer Actions
extension SoundZoneDetailViewController {
    @objc func dismiss(_ sender: UIImageView) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SoundZoneDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soundZone!.tracks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.textLabel?.text = soundZone!.tracks[indexPath.row]
        return cell
    }
}

extension SoundZoneDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        trackListTableView.deselectRow(at: indexPath, animated: false)
    }
}



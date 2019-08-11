//
//  SoundZoneDetailViewController.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/22/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import UIKit

class SoundZoneDetailViewController: UIViewController {

    let soundZone: SoundZone!
    let soundZoneTitle: UILabel = UILabel()
    let soundZoneDescription: UITextView = UITextView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    let soundZoneMainImage: UIImageView = UIImageView(image: UIImage(named: "placeholder"))
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
        setupDismissIcon()
        setupTitle()
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
        soundZoneTitle.textColor = .black
        soundZoneTitle.text =  soundZone?.name
        soundZoneTitle.textAlignment = .center
        soundZoneTitle.numberOfLines = 0
        
        view.addSubview(soundZoneTitle)
        
        soundZoneTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40)
            make.width.equalToSuperview().inset(20)
        }
    }
    
    func setupImage() {
        view.addSubview(soundZoneMainImage)
        
        self.soundZoneMainImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
            make.top.equalTo(soundZoneTitle.snp.bottom).offset(10)
        }
        
//        guard let url = URL(string: soundZone!.imageURL) else { return }
//
//        soundZoneMainImage.sd_setImage(with: url) { (image, error, _, url) in
//            print("ERROR: \(error)")
//            print("IMAGE: \(image)")
//        }
    }
    
    func setupDescription() {
        soundZoneDescription.textColor = .black
        soundZoneDescription.text =  soundZone?.description
        soundZoneDescription.textAlignment = .center
        soundZoneDescription.isScrollEnabled = false
        
        view.addSubview(soundZoneDescription)
        
        soundZoneDescription.snp.makeConstraints { (make) in
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(soundZoneDescription.contentSize.height)
            make.centerX.equalToSuperview()
            make.top.equalTo(soundZoneMainImage.snp.bottom).offset(10)
        }

    }
    
    func setupTracklistTableView() {
        trackListTableView.separatorStyle = .none
        trackListTableView.showsVerticalScrollIndicator = false
        trackListTableView.backgroundColor = .clear
        
        view.addSubview(trackListTableView)
        
        trackListTableView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(200)
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Track List for \(soundZone.name)"
    }
}

extension SoundZoneDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        trackListTableView.deselectRow(at: indexPath, animated: false)
    }
}



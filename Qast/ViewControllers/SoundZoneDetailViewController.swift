//
//  SoundZoneDetailViewController.swift
//  Qast
//
//  Created by Andrew O'Brien on 7/22/19.
//  Copyright © 2019 Qast. All rights reserved.
//

import UIKit

class SoundZoneDetailViewController: NiblessViewController {

    let soundZone: SoundZone!
    let soundZoneTitle: UILabel = UILabel()
    let soundZoneDescription: UITextView = UITextView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    let soundZoneMainImage: UIImageView = UIImageView(image: UIImage(named: "placeholder"))
    let trackListTableView: UITableView = UITableView()
    let dismissIcon = UIImageView(image: UIImage(named: "x-button"))

    let smt: UMGStreamMetadataAPIManager = UMGStreamMetadataAPIManager()
    
    init(_ soundZone: SoundZone) {
        self.soundZone = soundZone
        super.init()
        view.backgroundColor = UIColor.init(hexString: "F96170")
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
            make.width.height.equalTo(20)
            make.left.top.equalToSuperview().offset(20)
        }
        let dismissIconTapped = UITapGestureRecognizer(target: self, action: #selector(self.dismiss(_:)))
        dismissIcon.addGestureRecognizer(dismissIconTapped)
        dismissIcon.isUserInteractionEnabled = true
    }
    
    func setupTitle() {
        soundZoneTitle.textColor = .white
        soundZoneTitle.text =  soundZone?.name
        soundZoneTitle.textAlignment = .center
        soundZoneTitle.numberOfLines = 0
        
        soundZoneTitle.font = UIFont(name: "AvenirNext-Bold", size: 23.0)!
        
        view.addSubview(soundZoneTitle)
        
        soundZoneTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(50)
            make.width.equalToSuperview().inset(20)
        }
    }
    
    func setupImage() {
        view.addSubview(soundZoneMainImage)
        
        switch soundZone.name {
        case "Diana Ross":
            soundZoneMainImage.image = UIImage(named: "diana_ross")
        case "Michael Jackson":
            soundZoneMainImage.image = UIImage(named: "michael_jackson")
        case "The Temptations":
            soundZoneMainImage.image = UIImage(named: "temptations")
        default:
            soundZoneMainImage.image = UIImage(named: "temptations")
        }
        
        soundZoneMainImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
            make.top.equalTo(soundZoneTitle.snp.bottom).offset(10)
        }
        soundZoneMainImage.layoutIfNeeded()
        
        soundZoneMainImage.layer.borderWidth = 1
        soundZoneMainImage.layer.masksToBounds = false
        soundZoneMainImage.layer.borderColor = UIColor.gray.cgColor
        soundZoneMainImage.layer.cornerRadius = soundZoneMainImage.frame.width/2
        soundZoneMainImage.clipsToBounds = true
        
//        guard let url = URL(string: soundZone!.imageURL) else { return }
//
//        soundZoneMainImage.sd_setImage(with: url) { (image, error, _, url) in
//            print("ERROR: \(error)")
//            print("IMAGE: \(image)")
//        }
    }
    
    func setupDescription() {
        soundZoneDescription.textColor = .white
        soundZoneDescription.backgroundColor = .clear
        soundZoneDescription.text =  soundZone?.description
        soundZoneDescription.textAlignment = .center
        soundZoneDescription.isScrollEnabled = false
        soundZoneDescription.isUserInteractionEnabled = false
        
        soundZoneDescription.font = UIFont(name: "AvenirNext-Regular", size: 16.0)!
        
        view.addSubview(soundZoneDescription)
        
        soundZoneDescription.snp.makeConstraints { (make) in
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(250)
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
            make.height.equalTo(150)
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
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tracks for \(soundZone.name) SoundZone"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soundZone!.tracks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = soundZone!.tracks[indexPath.row]
        return cell
    }
}

extension SoundZoneDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        trackListTableView.deselectRow(at: indexPath, animated: false)
    }
}



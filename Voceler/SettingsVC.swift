//
//  SettingsVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/26/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SDAutoLayout

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let settingArr = ["Anonymous mode"]
    
    @IBOutlet weak var table: UITableView!
    let switcher = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupProfile()
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        edgesForExtendedLayout = []
        navigationBar.setColor(color: themeColor)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let text = settingArr[indexPath.row]
        cell.textLabel?.text = text
        if text == "Anonymous mode"{
            cell.addSubview(switcher)
            _ = switcher.sd_layout().topSpaceToView(cell, 8)?.rightSpaceToView(cell, 8)?.bottomSpaceToView(cell, 8)?.widthIs(52)
            switcher.addTarget(self, action: #selector(switcherTapped), for: .allEvents)
        }
        return cell
    }
    
    func switcherTapped(){
        appSetting.isAnonymous = switcher.isOn
    }
}

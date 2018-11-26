//
//  ViewController.swift
//  SwiftCalendar
//
//  Created by Sameer Poudel on 6/11/18.
//  Copyright © 2018 Sameer Poudel. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CalendarCallBack {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var selectedDate = Date()
    
    @IBAction func showCalendar(_ sender: UIButton){
        let CalendarViewController = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
        CalendarViewController.modalPresentationStyle = .overCurrentContext
        CalendarViewController.delegate = self
        CalendarViewController.selectedDate = selectedDate
        self.present(CalendarViewController, animated: false, completion: nil)
    }
    
    func didSelectDate(date: Date) {
        selectedDate = date
        dateLabel.isHidden = false
        
        dateLabel.text = date.getTitleDateFC()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

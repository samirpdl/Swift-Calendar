//
//  CalendarViewController
//  SwiftCalendar
//
//  Created by Sameer Poudel on 6/11/18.
//  Copyright © 2018 Sameer Poudel. All rights reserved.
//

import UIKit


extension Date {
    
    func getDaysInMonthFC() -> Int{
        let calendar = Calendar.current
        
        let dateComponents = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        
        return numDays
    }
    
    func addMonthFC(month: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: month, to: self)!
    }
    
    func startOfMonthFC() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonthFC() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonthFC())!
    }
    
    func getDayOfWeekFC() -> Int? {
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: self)
        return weekDay
    }
    
    func getHeaderTitleFC() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM, YYYY"
        return dateFormatter.string(from: self)
    }
    
    func getDayFC(day: Int) -> Date {
        let day = Calendar.current.date(byAdding: .day, value: day, to: self)!
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: day)!
    }
    
    func getYearOnlyFC() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        return dateFormatter.string(from: self)
    }
    
    func getTitleDateFC() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM dd"
        return dateFormatter.string(from: self)
    }
}

extension UIView {
    func callRecursively(level: Int = 0, _ body: (_ subview: UIView, _ level: Int) -> Void) {
        body(self, level)
        subviews.forEach { $0.callRecursively(level: level + 1, body) }
    }
}

protocol CalendarCallBack {
    func didSelectDate(date: Date)
}

class CalendarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var calendar: UICollectionView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var wrapper: UIView!
    
    var delegate: CalendarCallBack? = nil
    
    @IBAction func close(_ sender: UIButton){
        UIView.animate(withDuration: 0.25, animations: {
            self.view.removeConstraint(self.heightConstraint!)
            self.verticalConstraint!.constant = self.view.frame.size.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.view.layoutIfNeeded()
        }) { (done) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func selectDate(_ sender: UIButton){
        UIView.animate(withDuration: 0.25, animations: {
            self.view.removeConstraint(self.heightConstraint!)
            self.verticalConstraint!.constant = self.view.frame.size.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.view.layoutIfNeeded()
        }) { (done) in
            self.dismiss(animated: false, completion: nil)
            self.delegate?.didSelectDate(date: self.selectedDate)
        }
    
    }
    
    var selectedIndex: IndexPath? = nil
    var selectedDate = Date()
    
    var verticalConstraint: NSLayoutConstraint? = nil
    var heightConstraint: NSLayoutConstraint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let numberOfCellsPerRow: CGFloat = 7
        
        
        if let flowLayout = calendar.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
            let cellWidth = (view.frame.width - 16 - max(0, numberOfCellsPerRow - 1)*horizontalSpacing)/numberOfCellsPerRow
            flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        }

        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.view.layoutIfNeeded()
        
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.size.width)
        
        verticalConstraint = NSLayoutConstraint(item: wrapper, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: self.view.frame.size.height)
        
        view.addConstraints([horizontalConstraint, widthConstraint, verticalConstraint!])
        
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
            UIView.animate(withDuration: 0.25, animations: {
                self.verticalConstraint!.constant = 60
                self.heightConstraint = NSLayoutConstraint(item: self.wrapper, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant:  0)
                self.view.addConstraints([self.heightConstraint!])
                self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                self.view.layoutIfNeeded()
            })
        }
        
        year.text = selectedDate.getYearOnlyFC()
        date.text = selectedDate.getTitleDateFC()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calendar.reloadData()
    }
    
    func scrollToIndex() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
            if self.selectedIndex != nil {
                self.calendar.scrollToItem(at: self.selectedIndex!, at: .centeredVertically, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat((collectionView.frame.size.width / 3) - 20), height: CGFloat(100))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 12
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        let title = headerView.viewWithTag(1) as! UILabel
        title.text = Date().addMonthFC(month: indexPath.section).getHeaderTitleFC()
        return headerView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Date().addMonthFC(month: section).getDaysInMonthFC()+Date().addMonthFC(month: section).startOfMonthFC().getDayOfWeekFC()!+6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let calendarDay = cell.viewWithTag(1) as! UILabel
        calendarDay.textColor = UIColor.darkGray
        if indexPath.row+1 >= Date().addMonthFC(month: indexPath.section).startOfMonthFC().getDayOfWeekFC()!+7{
            calendarDay.text = "\((indexPath.row+1)-(Date().addMonthFC(month: indexPath.section).startOfMonthFC().getDayOfWeekFC()!+6))"
        }else{
            if(indexPath.row < 7){
                var dayname = ""
                switch (indexPath.row){
                case 0:
                    dayname = "S"
                    break
                    
                case 1:
                    dayname = "M"
                    break
                    
                case 2:
                    dayname = "T"
                    break
                    
                case 3:
                    dayname = "W"
                    break
                    
                case 4:
                    dayname = "T"
                    break
                    
                case 5:
                    dayname = "F"
                    break
                    
                case 6:
                    dayname = "S"
                    break
                    
                default:
                    break
                }
                calendarDay.text = dayname
                calendarDay.textColor = UIColor.lightGray
            }else{
                calendarDay.text = ""
            }
        }
        cell.viewWithTag(2)?.isHidden = true
        cell.viewWithTag(2)?.layer.cornerRadius = (cell.viewWithTag(2)?.frame.size.width)!/2
        if(selectedIndex != nil){
            if(selectedIndex == indexPath){
                cell.viewWithTag(2)?.isHidden = false
                calendarDay.textColor = UIColor.white
                self.scrollToIndex()
            }
        }else if Int(calendarDay.text!) != nil{
            if(Date().addMonthFC(month: indexPath.section).startOfMonthFC().getDayFC(day: Int(calendarDay.text!)!-1) == selectedDate.getDayFC(day: 0)){
                cell.viewWithTag(2)?.isHidden = false
                calendarDay.textColor = UIColor.white
                year.text = selectedDate.getYearOnlyFC()
                date.text = selectedDate.getTitleDateFC()
                selectedDate = Date()
                selectedIndex = indexPath
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        let calendarDay = cell?.viewWithTag(1) as! UILabel
        if Int(calendarDay.text!) != nil{
            cell?.viewWithTag(2)?.isHidden = false
            calendarDay.textColor = UIColor.white
            let sDate =  Date().addMonthFC(month: indexPath.section).startOfMonthFC().getDayFC(day: Int(calendarDay.text!)!-1)
            year.text = sDate.getYearOnlyFC()
            date.text = sDate.getTitleDateFC()
            selectedDate = sDate
            selectedIndex = indexPath
            collectionView.reloadData()
        }
    }
    
}


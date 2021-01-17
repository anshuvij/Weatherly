//
//  WeatherViewController.swift
//  Weatherly
//
//  Created by Anshu Vij on 1/15/21.
//

import UIKit
import Firebase
import CoreLocation
import Charts

var vSpinner : UIView?
class WeatherViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var lineChartView: LineChartView!
    
    var weatherManager = WeatherManager()
    var locationManager = CLLocationManager()
    weak var axisFormatDelegate: IAxisValueFormatter?
    var days = ["Today"]
    var userServiceData = UserServiceData()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        checkifUserIsLoggedIn()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: true)
        
    }
    
    //MARK: - Helpers
    func configureUI() {
        
        self.navigationController?.title = "Weatherly"
        axisFormatDelegate = self
        //  setUpChartData()
        // Do any additional setup after loading the view.
        self.title = "Weatherly"
        self.showSpinner(onView: self.view)
        
        
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        userServiceData.delegate = self
        //locationManager.requestLocation()
        fetchUsersData()
        
        days.append(contentsOf: Date.getDates(forLastNDays: 5))
        searchTextField.delegate = self
        weatherManager.delegate = self
        
    }
    
    func getWeatherData(coordinate : Coordinate)
    {
        weatherManager.fetchWeather(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    func fetchUsersData()
       {
        userServiceData.fetchUser()
        }
    
    func setUpChartData(weatherModel : [WeatherModel]) {
        
        let data = LineChartData()
        var lineChartEntry1 = [ChartDataEntry]()
        
        for i in 0..<weatherModel.count {
            lineChartEntry1.append(ChartDataEntry(x: Double(i), y: weatherModel[i].max_temp ,data: days as AnyObject?))
        }
        let chartDataSet = LineChartDataSet(entries: lineChartEntry1, label: "max_temp")
        data.addDataSet(chartDataSet)
        chartDataSet.setColor(ChartColorTemplates.colorFromString("#1E4349"))
        chartDataSet.setCircleColor(ChartColorTemplates.colorFromString("#EBFAFE"))
        chartDataSet.valueTextColor = ChartColorTemplates.colorFromString("#1E4349")
        chartDataSet.lineWidth = 1.0
        chartDataSet.circleRadius = 7.0
        chartDataSet.drawCircleHoleEnabled = true
        chartDataSet.drawFilledEnabled = true
        chartDataSet.valueFont = .systemFont(ofSize: 9)
        chartDataSet.formLineDashLengths = [5, 2.5]
        chartDataSet.formLineWidth = 1
        chartDataSet.drawHorizontalHighlightIndicatorEnabled = true
        chartDataSet.drawVerticalHighlightIndicatorEnabled = true
        chartDataSet.highlightColor = UIColor.white
        
        let gradientColors = [ChartColorTemplates.colorFromString("#00FFFFFF").cgColor,
                              ChartColorTemplates.colorFromString("#1E4349").cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        chartDataSet.fillAlpha = 0.3
        chartDataSet.fill = Fill(linearGradient: gradient, angle: 90)
        chartDataSet.drawFilledEnabled = true
        
        
        
        var lineChartEntry2 = [ChartDataEntry]()
        
        for i in 0..<weatherModel.count {
            lineChartEntry2.append(ChartDataEntry(x: Double(i), y: weatherModel[i].min_temp , data: days as AnyObject?))
        }
        let chartDataSetGoal = LineChartDataSet(entries: lineChartEntry2, label: "min_temp")
        data.addDataSet(chartDataSetGoal)
        chartDataSetGoal.setColor(ChartColorTemplates.colorFromString("#EBFAFE"))
        chartDataSetGoal.setCircleColor(ChartColorTemplates.colorFromString("#1E4349"))
        chartDataSetGoal.valueTextColor = ChartColorTemplates.colorFromString("#EBFAFE")
        chartDataSetGoal.lineWidth = 1.0
        chartDataSetGoal.circleRadius = 7.0
        chartDataSetGoal.drawCircleHoleEnabled = true
        chartDataSetGoal.drawFilledEnabled = true
        chartDataSetGoal.valueFont = .systemFont(ofSize: 8)
        chartDataSetGoal.drawHorizontalHighlightIndicatorEnabled = true
        chartDataSetGoal.drawVerticalHighlightIndicatorEnabled = true
        chartDataSetGoal.highlightColor = UIColor.white
        chartDataSetGoal.fillAlpha = 0.3
        chartDataSetGoal.formLineWidth = 1.0
        chartDataSetGoal.fill = Fill(linearGradient: gradient, angle: 90)
        chartDataSetGoal.drawFilledEnabled = true
        
        
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelCount = days.count - 1
        
        
        self.lineChartView.data = data
        let xAxisValue = lineChartView.xAxis
        xAxisValue.drawLabelsEnabled = true
        xAxisValue.valueFormatter = axisFormatDelegate
        xAxisValue.gridLineWidth = 0.0
        xAxisValue.xOffset = 0.5
        self.lineChartView.rightAxis.enabled = false
        self.lineChartView.leftAxis.enabled = false
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0 , easingOption: .easeInBack)
        lineChartView.extraLeftOffset = 10.0
        lineChartView.extraRightOffset = 10.0
        lineChartView.legend.horizontalAlignment = .right
        lineChartView.legend.verticalAlignment = .top
        
    }
    
    
    func checkifUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            print("#Debug:User not logged in")
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginNavController = storyboard.instantiateViewController(identifier: Constants.viewControllerName)
                
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
            }
            
        }
        else
        {
            configureUI()
        }
        
    }
    
    
    //MARK: - Actions
    @IBAction func logout(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavController = storyboard.instantiateViewController(identifier: Constants.viewControllerName)
            
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
       
    @IBAction func currentLocation(_ sender: Any) {
        self.showSpinner(onView: self.view)
        locationManager.requestLocation()
    }
    
    
    @IBAction func textFieldTapped(_ sender: Any) {
        searchTextField.resignFirstResponder()
        searchTextField.endEditing(true)
        let acController = PlaceHelperVC()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
        
    }
    

}

//MARK:- UITextFieldDelegate
extension WeatherViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        searchTextField.endEditing(true)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchTextField.resignFirstResponder()
        searchTextField.text = ""
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField.text != ""
        {
            return true
        }
        else
        {
            textField.placeholder = "Type Something"
            return false
        }
        
    }
}

//MARK:- WeatherManagerDelegate

extension WeatherViewController : WeatherManagerDelegate
{
    func didUpdateWeather(_ weatherManager : WeatherManager, _ weather: [WeatherModel]) {
        self.removeSpinner()
        //print("5 day weather : \(weather)")
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather[0].tempratureString
            self.cityLabel.text = weather[0].cityName
            self.conditionImageView.image = UIImage(systemName: weather[0].conditionName)
            self.setUpChartData(weatherModel: weather)
        }
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
        self.removeSpinner()
    }
}

//MARK:- CoreLocation

extension WeatherViewController : CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let locations = locations.last{
            locationManager.stopUpdatingLocation()
            let lat = locations.coordinate.latitude
            let long = locations.coordinate.longitude
            weatherManager.saveLastData(latitude: lat, longitude: long)
            weatherManager.fetchWeather(latitude: lat, longitude: long)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
//MARK:- UIViewController

extension UIViewController {
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
         vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

//MARK:- IAxisValueFormatter
extension WeatherViewController: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    return days[Int(value)]
    }
}

//MARK:- PlaceHelperDelegate
extension WeatherViewController : PlaceHelperDelegate {
    
    func selectedLocation(lat: Double?, lon: Double?, name : String?) {
       
        guard let lat = lat else { return }
        guard let lon = lon else { return }
    
        self.showSpinner(onView: self.view)
        weatherManager.saveLastData(latitude: lat, longitude: lon)
        weatherManager.fetchWeather(latitude: lat, longitude: lon)
        
    }
    
    
}

extension Date {
    static func getDates(forLastNDays nDays: Int) -> [String] {
        let cal = NSCalendar.current
        // start with today
        var date = cal.startOfDay(for: Date())

        var arrDates = [String]()

        for _ in 1 ..< nDays {
            // move back in time by one day:
            date = cal.date(byAdding: Calendar.Component.day, value: 1, to: date)!

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EE"
            let dateString = dateFormatter.string(from: date)
            arrDates.append(dateString)
        }
       // print(arrDates)
        return arrDates
    }
}

//MARK:- UserServiceDataDelegate
extension WeatherViewController : UserServiceDataDelegate {
    
    func getUserCoordinate(dictonary: Coordinate) {
        
        weatherManager.fetchWeather(latitude: dictonary.latitude, longitude: dictonary.longitude)
        
    }
    
    func didFailToGetData() {
        locationManager.requestLocation()
    }
    
    
}


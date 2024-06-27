//
//  MainViewController.swift
//  1971102-FinalProject
//
//  Created by mac004 on 2024/06/04.
//

import UIKit
import MapKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            onLocationUpdate?(location.coordinate)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    let weatherSite = "https://api.openweathermap.org/data/2.5/weather"
    let weatherKey = "56515cbed30d47ed792c5e1363bc4bd5"
    let locationManager = LocationManager()
    
    @IBOutlet weak var weatherInfoImageView: UIImageView!
    @IBOutlet weak var weatherInfoLabel: UILabel!
    @IBOutlet weak var recommendCocktailImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.onLocationUpdate = { coordinate in
                print("위도: \(coordinate.latitude), 경도: \(coordinate.longitude)")
                self.getWeatherInfo(location: coordinate)
        }
        locationManager.startUpdatingLocation()
    }
}
extension WeatherViewController{
    func makeUpWeatherInfomation(jsonData: Data) -> (String,Data,Double){
        let jsonOjct = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        let weather = jsonOjct["weather"] as! [Any]
        let weather0 = weather[0] as! [String:Any]
        let icon = weather0["icon"] as! String
        
        let main = jsonOjct["main"] as! [String:Any]
        let feels_like = main["feels_like"] as! Double - 273.0
        let temp = main["temp"] as! Double - 273.0
        let temp_min = main["temp_min"] as! Double - 273.0
        let temp_max = main["temp_max"] as! Double - 273.0
        let pressure = main["pressure"] as! Double - 273.0
        let humidity = main["humidity"] as! Double - 273.0
        
        let wind = jsonOjct["wind"] as! [String:Any]
        let speed = wind["speed"] as! Double
        
        var infoStr = "온도: \(temp)\n"
        infoStr += "최저온도: \(temp_min)\n"+"최고온도: \(temp_max)\n"+"체감온도: \(feels_like)\n"
        infoStr += "기압: \(pressure)파스칼\n"+"습도: \(humidity)\n"+"풍속:\(speed)\n"
        
        let iconUrl = URL(string: "https://openweathermap.org/img/wn/"+icon+"@2x.png")
        let data = try! Data(contentsOf: iconUrl!)
        
        return(infoStr,data,temp)
    
    }
    func getWeatherInfo(location: CLLocationCoordinate2D){
        var urlStr = weatherSite
        urlStr += "?"+"lat="+String(location.latitude)+"&"+"lon="+String(location.longitude)
        urlStr += "&"+"appid="+weatherKey
        
        let request = URLRequest(url: URL(string: urlStr)!)
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request){
            (data,response,error) in
            guard let jsonData = data else {print(error!); return}
            if let jsonStr = String(data: jsonData, encoding: .utf8){
                print(jsonStr)
            }
            
            let (infoStr,iconData,temp) = self.makeUpWeatherInfomation(jsonData: jsonData)
            
            DispatchQueue.main.async {
                if(temp>30){
                    let cocktailInfo = """
                    무더운 날씨이군요! 갈증을 해결할 시원 달달한 칵테일을 추천할게요!
                    마가리타는 테킬라, 트리플 섹, 신선한 라임 주스로 만들어집니다. 셰이커에 얼음과 함께 이 재료들을 넣고 잘 흔든 후,소금으로 테두리를 코팅한 잔에 따라 냅니다. 라임 조각을 곁들여 상쾌함을 더합니다. 마가리타는 신맛과 단맛이 조화롭게 어우러진 칵테일로, 더운 날씨에 갈증을 해소해 줍니다.

                    다이키리는 화이트 럼, 신선한 라임 주스, 설탕 시럽으로 만듭니다. 셰이커에 얼음과 함께 모든 재료를 넣고 흔든 후, 칵테일 잔에 체로 걸러 붓습니다. 라임 조각을 장식으로 올려 상쾌한 맛을 강조합니다. 다이키리는 단맛과 신맛이 균형을 이루어, 여름철에 상쾌하게 즐기기 좋습니다.

                    모스크바 뮬은 보드카, 생강 맥주, 신선한 라임 주스로 간단하게 만들 수 있습니다. 구리잔에 얼음을 채우고 보드카와 라임 주스를 붓습니다. 그 위에 생강 맥주를 부어 상쾌한 생강 맛을 더합니다. 라임 조각을 장식으로 올려 완성합니다. 모스크바 뮬은 생강의 톡 쏘는 맛과 라임의 상큼함이 어우러져 더운 날씨에 시원하게 마시기 좋은 칵테일입니다.
                    """

                    self.weatherInfoLabel.text = cocktailInfo
                    
                    if let image = UIImage(named: "Margarita") {
                        self.recommendCocktailImageView.image = image
                    } else {
                        print("이미지를 로드할 수 없습니다.")
                    }
                }
                if(temp>19){
                    let cocktailInfo = """
                    날씨가 따뜻할 때에는 시원 상큼한 칵테일은 어떠신가요?
                    모히또 (Mojito): 민트와 라임이 상쾌한 맛을 줍니다. 럼을 베이스로 하고 설탕, 탄산수, 민트, 라임이 들어갑니다.
                    피나 콜라다 (Piña Colada): 코코넛 크림과 파인애플 주스가 함께 어우러져 달콤하고 상쾌한 맛을 낸다. 럼을 베이스로 하며 얼음을 넣어 블렌딩합니다.
                    카이프리냐 (Caipirinha): 브라질의 전통 칵테일로, 라임과 설탕, 캐시샤(브라질의 강력한 산과 매우 높은 알콜 도수를 가진 증류주)이 들어갑니다.
                    세인트제르맹 (Saint Germain): 세인트 제르맹 리큐어와 프로세코(이탈리아산 스파클링 와인)가 함께 들어가 달콤하면서도 가벼운 맛을 낸다.
                    에이퍼롤 스프리츠 (Aperol Spritz): 에이퍼롤, 스파클링 와인, 소다가 섞여 상큼하고 산뜻한 맛을 낸다.
                    """

                    self.weatherInfoLabel.text = cocktailInfo
                    if let image = UIImage(named: "Mojito") {
                        self.recommendCocktailImageView.image = image
                    } else {
                        print("이미지를 로드할 수 없습니다.")
                    }
                    
                }
                if(temp<19){
                    let cocktailInfo = """
                    선선하거나 추운 날씨의 칵테일에는 따뜻하거나 도수가 높은 술은 어떨까요?
                    올드 패션드 (Old Fashioned): 버번 위스키나 라이 위스키를 베이스로 하고, 설탕, 비터, 오렌지 필을 넣어 만든 클래식한 칵테일입니다. 부드럽고 풍부한 맛이 특징입니다.

                    맨하탄 (Manhattan): 라이 위스키, 스위트 베르무트, 앙고스트라 비터로 만든 칵테일로, 풍부한 향과 부드러운 맛을 가지고 있습니다.

                    호텔 네셔널 (Hotel Nacional): 화이트 럼, 애시드 스플래시, 앵거스트라 비터, 파인애플 주스로 만들어진 칵테일로, 과일향과 약간의 산미가 있습니다.

                    핫 토디 (Hot Toddy): 위스키나 버번, 레몬 주스, 꿀, 온도 낮은 물을 섞어 따뜻하게 마시는 칵테일입니다. 추운 날씨에 따뜻함을 더해줍니다.

                    아이리시 커피 (Irish Coffee): 아이리시 위스키, 설탕, 뜨거운 커피, 생크림을 넣어 만드는 커피 베이스의 칵테일로, 부드럽고 따뜻한 맛이 있습니다.
                    """

                    self.weatherInfoLabel.text = cocktailInfo
                    
                    if let image = UIImage(named: "hotToddy") {
                        self.recommendCocktailImageView.image = image
                    } else {
                        print("이미지를 로드할 수 없습니다.")
                    }
                }
                self.weatherInfoImageView.image = UIImage(data: iconData)
            }
        }
        dataTask.resume()
        
    }
}

extension WeatherViewController{
    func makeUpOpenAiInformation(jsonData: Data) -> String{
        let jsonObjct = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        return String(data:jsonData, encoding: .utf8)!
    }
}

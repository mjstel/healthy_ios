import Flutter
import UIKit
import HealthKit

public class SwiftHealthyIosPlugin: NSObject, FlutterPlugin {
    
    let store = HKHealthStore()
    
    //Statistics components
    let NO_RESULTS = "NO_RESULTS"
    let WRONG_TYPE = "WRONG_TYPE"
    let INCOMPATIBLE_UNIT = "INCOMPATIBLE_UNIT"
    let QUERY_ERROR = "QUERY_ERROR"
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "healthy_ios", binaryMessenger: registrar.messenger())
        let instance = SwiftHealthyIosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if (call.method.elementsEqual("requestTypes")) {
            requestTypes(call: call, result: result)
        }
        else if (call.method.elementsEqual("requestQuantitativeData")) {
            handleQuantitativeSamples(call: call, result: result)
        }
        else if (call.method.elementsEqual("requestCategoricalData")) {
            handleCategoricSamples(call: call, result: result)
        }
        else if (call.method.elementsEqual("requestStatisticsData")) {
            handleStatistics(call: call, result: result)
        }
    }
    
    func requestTypes(call: FlutterMethodCall, result: @escaping FlutterResult){
        let args = call.arguments as? NSDictionary
        let types = (args?["types"] as? Array<String>)  ?? []
        
        let reads : [HKSampleType] = types.map{rawType in
           return getSampleType(identifier: rawType)
        }
    
        if #available(iOS 11.0, *) {
            store.requestAuthorization(toShare: nil, read: Set(reads)) { (success, error) in
                result(success)
            }
        }
        else {
            result(false)// Handle the error here.
        }
        
    }
    
    func handleQuantitativeSamples(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String:Any]
        let dataTypeKey = (arguments?["type"] as? String) ?? ""
        let unitValue = (arguments?["unit"] as? String) ?? ""
        let start = (arguments?["start"] as? Double) ?? 0
        let end = (arguments?["end"] as? Double) ?? 0
        
        let startDate = Date(timeIntervalSince1970: start / 1000)
        let endDate = Date(timeIntervalSince1970: end / 1000)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        guard let dataType = getSampleType(identifier:dataTypeKey) as? HKQuantityType else {
            result(FlutterError(code: WRONG_TYPE, message: "Type is not a HKQuantityType", details: "\(dataTypeKey)"))
            return
        }
        guard let unit = getUnit(sampleType: dataType, unit: unitValue) else {
            result(FlutterError(code: INCOMPATIBLE_UNIT, message: "Unit is incompatible with this HKQuantityType", details: "\(dataTypeKey) - \(unitValue)"))
            return
        }
        
        let query = HKSampleQuery(sampleType: dataType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {
            _, samplesOrNil, error in
            
            if let error = error {
                result(FlutterError(code: self.QUERY_ERROR, message: "An error occured during the query.", details: "\(error)"))
                return
            }
            
            guard let samples = samplesOrNil as? [HKQuantitySample] else {
                result([])
                return
            }
            result(samples.map{sample -> NSDictionary in
                return [
                    "value": sample.quantity.doubleValue(for: unit),
                    "from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                    "to": Int(sample.endDate.timeIntervalSince1970 * 1000)
                ]
            })
            return
        }
        store.execute(query)
    }
    
    func handleCategoricSamples(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String:Any]
        let dataTypeKey = (arguments?["type"] as? String) ?? ""
        let start = (arguments?["start"] as? Double) ?? 0
        let end = (arguments?["end"] as? Double) ?? 0
        
        let startDate = Date(timeIntervalSince1970: start / 1000)
        let endDate = Date(timeIntervalSince1970: end / 1000)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        guard let dataType = getSampleType(identifier:dataTypeKey) as? HKCategoryType else {
            result(FlutterError(code: "Healthy", message: "Type is not a HKCategoryType", details: "\(dataTypeKey)"))
            return
        }

        let query = HKSampleQuery(sampleType: dataType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) {
            _, samplesOrNil, error in
            
            if let error = error {
                result(FlutterError(code: self.QUERY_ERROR, message: "An error occured during the query.", details: "\(error)"))
                return
            }
            
            guard let samples = samplesOrNil as? [HKCategorySample] else {
                result([])
                return
            }
            
            result(samples.map{sample -> NSDictionary in
                return [
                    "value": sample.value,
                    "from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                    "to": Int(sample.endDate.timeIntervalSince1970 * 1000)
                ]
            })
            return
        }
        store.execute(query)
    }
    
    func handleStatistics(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String:Any]
        let dataTypeKey = (arguments?["type"] as? String) ?? "DEFAULT"
        let unitValue = (arguments?["unit"] as? String) ?? ""
        let start = (arguments?["start"] as? Double) ?? 0
        let end = (arguments?["end"] as? Double) ?? 0
        let anchor = (arguments?["anchor"] as? Double) ?? 0
        let intervalValue = arguments?["dateComponents"] as? [String:Int] ?? [:]

        let startDate = Date(timeIntervalSince1970: start / 1000)
        let endDate = Date(timeIntervalSince1970: end / 1000)
        let anchorDate = Date(timeIntervalSince1970: anchor / 1000)
        let statisticsInterval = getDateComponent(d: intervalValue)
        guard let dataType = getSampleType(identifier:dataTypeKey) as? HKQuantityType else {
            result(FlutterError(code: "Healthy", message: "Type is not a HKQuantityType", details: "\(dataTypeKey)"))
            return
        }
        guard let unit = getUnit(sampleType: dataType, unit: unitValue) else {
            result(FlutterError(code: "Healthy", message: "Unit is incompatible with this HKQuantityType", details: "\(dataTypeKey) - \(unitValue)"))
            return
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let opts: HKStatisticsOptions = dataType.aggregationStyle == .cumulative ? .cumulativeSum : [.discreteAverage,.discreteMax,.discreteMin]
        let query = HKStatisticsCollectionQuery(quantityType:dataType , quantitySamplePredicate: predicate, options: opts , anchorDate: anchorDate, intervalComponents: statisticsInterval)
            
        query.initialResultsHandler = {
                        _ ,statisticsOrNil, error in
         
            if let error = error {
                result(FlutterError(code: self.QUERY_ERROR, message: "An error occured during the query.", details: "\(error)"))
                return
            }
            
            guard let stats = statisticsOrNil else {
                    result([])
                    return
                }

            result(stats.statistics().map{ sample -> NSDictionary in
                return [
                    "sum": sample.sumQuantity()?.doubleValue(for: unit) as Any,
                    "avg": sample.averageQuantity()?.doubleValue(for: unit) as Any,
                    "min": sample.minimumQuantity()?.doubleValue(for: unit) as Any,
                    "max": sample.maximumQuantity()?.doubleValue(for: unit) as Any,
                    "from": Int(sample.startDate.timeIntervalSince1970 * 1000),
                    "to": Int(sample.endDate.timeIntervalSince1970 * 1000),
                ]
            })
            return
        }
        HKHealthStore().execute(query)
    }
    
    func mondayMorning() -> Date {
        return Calendar.current.date(from: DateComponents(year:2021,month: 2,day: 1,hour: 0,minute: 0))!
    }
    
    func getDateComponent(d: [String:Int]) -> DateComponents {
        return DateComponents(day:d["day"], hour: d["hour"], minute: d["minute"])
    }
    
    func getUnit(sampleType:HKQuantityType, unit :String) -> HKUnit? {
        let hkUnit = HKUnit.init(from: unit)
        return sampleType.is(compatibleWith: hkUnit) ? hkUnit : nil
    }
    
    func getSampleType(identifier: String) -> HKSampleType {
        return isCategoricType(type: identifier)
            ? HKSampleType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: identifier))!
            : HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: identifier))!
    }
    
    func isCategoricType(type : String) -> Bool {
        if type.starts(with: "HKCategoryTypeIdentifier") {
            return true
        }
        else {
            return false
        }
        
    }
}

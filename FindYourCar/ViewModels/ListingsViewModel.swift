
import Foundation
import SwiftUI

class ListingsViewModel: ObservableObject {
    @Published var textFullyDisplayed = false
    @Published var displayedText = ""
    let selectedDisplayText = "Listings"
    var currentIndex = 0
    var timer: Timer?
    let ListingItems: [[String]]
    @Published var higherToLower = false
    @Published var theChanging = "–"
    @Published var rotationDegree: Double = 0
    @Published var sortClicked = false
    @Published var filterClicked = false
    @Published var KMmaximumValue = ""
    @Published var KMminimumValue = ""
    @Published var priceMaximumValue = ""
    @Published var priceMinimumValue = ""
    @Published var yearMaximumValue = ""
    @Published var yearMinimumValue = ""
    @Published var listingSample: [[String]] = []
    @Published var clickedArray = [false, false, false]
    @Published var previousClickedArray = [false, false, false]
    @Published var fuelFilter = "Any"
    @Published var gearFilter = "Any"
    @Published var accidentFilter = "Any"
    @Published var backgroundColor = Color(red: 200/255, green: 200/255, blue: 200/255)
    @Published var filterResultNumber = "55"
    @Published var filterResult: [[String]] = []
    @Published var loaded = false
    init(ListingItems: [[String]]){
        self.ListingItems = ListingItems
    }
    
    
    func updateFilterResult() {
        filterResult = applyAllFilter(filterTarget: ListingItems)
        
        withAnimation(.easeIn(duration: 0.2)) {
            filterResultNumber = String(filterResult.count)
        }
    }
    
    func startWritingEffect() {
        let charDelay = Double.random(in: 0.05...0.18)
        
        timer = Timer.scheduledTimer(withTimeInterval: charDelay, repeats: false) { _ in
            if self.currentIndex < self.selectedDisplayText.count {
                let currentCharacter = self.selectedDisplayText[self.selectedDisplayText.index(self.selectedDisplayText.startIndex, offsetBy: self.currentIndex)]
                
                self.displayedText.append(currentCharacter)
                self.currentIndex += 1
                self.startWritingEffect()
            } else {
                self.timer?.invalidate()
                self.timer = nil
                    withAnimation(.bouncy(duration: 1)) {
                    self.textFullyDisplayed = true
                }
            }
        }
    }
    
    func applyAllFilter(filterTarget: [[String]]) -> [[String]] {
        var filterStorage: [[String]] = []
        
        filterStorage = filterKM(filterTarget: filterTarget, lowest: KMminimumValue, highest: KMmaximumValue)
        filterStorage = filterPrice(filterTarget: filterStorage, lowest: priceMinimumValue, highest: priceMaximumValue)
        filterStorage = filterYear(filterTarget: filterStorage, lowest: yearMinimumValue, highest: yearMaximumValue)
        filterStorage = filterFuel(filterTarget: filterStorage, fuelType: fuelFilter)
        filterStorage = filterGear(filterTarget: filterStorage, gearType: gearFilter)
        filterStorage = filterAccident(filterTarget: filterStorage, accidentType: accidentFilter)
        
        return filterStorage
    }
    
    func filterKM(filterTarget: [[String]], lowest: String, highest: String) -> [[String]] {
        var lowestValue = 0
        var highestValue = 99999999999
        
        if lowest != "" {
            lowestValue = Int(lowest)!
        }
        
        if highest != "" {
            highestValue = Int(highest)!
        }
        
        let filteredItems = filterTarget.filter { listingItem in
            if let selectedKM = Int(listingItem[6]) {
                return selectedKM >= lowestValue && selectedKM <= highestValue
            }
            return false
        }
        
        return filteredItems
    }
    
    func filterPrice(filterTarget: [[String]], lowest: String, highest: String) -> [[String]] {
        var lowestValue = 0
        var highestValue = 99999999999
        
        if lowest != "" {
            lowestValue = Int(lowest)!
        }
        
        if highest != "" {
            highestValue = Int(highest)!
        }
        
        let filteredItems = filterTarget.filter { listingItem in
            if let selectedPrice = Int(listingItem[7]) {
                return selectedPrice >= lowestValue && selectedPrice <= highestValue
            }
            
            return false
        }
        
        return filteredItems
    }

    func filterYear(filterTarget: [[String]], lowest: String, highest: String) -> [[String]] {
        var lowestValue = 0
        var highestValue = 99999999999
        
        if lowest != "" {
            lowestValue = Int(lowest)!
        }
        
        if highest != "" {
            highestValue = Int(highest)!
        }
        
        let filteredItems = filterTarget.filter { listingItem in
            if let selectedYear = Int(listingItem[2]) {
                return selectedYear >= lowestValue && selectedYear <= highestValue
            }
            return false
        }
        
        return filteredItems
    }
    
    func filterGear(filterTarget: [[String]], gearType: String) -> [[String]] {
        if gearType == "Any" {
            return filterTarget
        }
        
        let filteredItems = filterTarget.filter { listingItem in
            return listingItem[3] == gearType
        }
        
        return filteredItems
    }
    
    func filterFuel(filterTarget: [[String]], fuelType: String) -> [[String]] {
        if fuelType == "Any" {
            return filterTarget
        }
        
        let filteredItems = filterTarget.filter { listingItem in
            return listingItem[4] == fuelType
        }
        
        return filteredItems
    }
    
    func filterAccident(filterTarget: [[String]], accidentType: String) -> [[String]] {
        if accidentType == "Any" {
            return filterTarget
        }
        
        let filteredItems = filterTarget.filter { listingItem in
            return listingItem[5] == accidentType
        }
        
        return filteredItems
    }
    
    func sortByPrice() {
        var listingItems = listingSample
        
        let sortedArrays = listingItems.sorted { (arr1, arr2) -> Bool in
            if let num1 = Int(arr1[7]), let num2 = Int(arr2[7]) {
                if higherToLower {
                    return num1 > num2
                } else {
                    return num1 < num2
                }
            }
            return false
        }
        withAnimation(.smooth(duration: 0.25)) {
            listingSample = sortedArrays
        }
    }
    
    func sortByYear() {
        var listingItems = listingSample
        
        let sortedArrays = listingItems.sorted { (arr1, arr2) -> Bool in
            if let num1 = Int(arr1[2]), let num2 = Int(arr2[2]) {
                if higherToLower {
                    return num1 > num2
                } else {
                    return num1 < num2
                }
            }
            return false
        }
        withAnimation(.smooth(duration: 0.25)) {
            listingSample = sortedArrays
        }
    }
    
    func sortByKM() {
        var listingItems = listingSample
        
        let sortedArrays = listingItems.sorted { (arr1, arr2) -> Bool in
            if let num1 = Int(arr1[6]), let num2 = Int(arr2[6]) {
                if higherToLower {
                    return num1 > num2
                } else {
                    return num1 < num2
                }
            }
            return false
        }
        withAnimation(.smooth(duration: 0.25)) {
            listingSample = sortedArrays
        }
    }
}


import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

struct CreateListingView: View {
    @ObservedObject private var vM: CreateListingViewModel
    @FocusState var focusedField: Field?
    
    enum Field: Hashable {
            case kilometer
            case price
    }
    
    var readyToSubmit: Bool {
        return !vM.clickedArray.contains(true) &&
                !vM.kilometerValue.isEmpty &&
                !vM.price.isEmpty &&
                focusedField == nil &&
                vM.selectedMake != "All makes" &&
                vM.selectedModel != "All models" &&
                vM.imageURLs.count != 0
    }
    
    init(vM: CreateListingViewModel) {
            self._vM = ObservedObject(wrappedValue: vM)
        }
    
    var body: some View {
        VStack {
            ZStack {
                Color(.purple)
                VStack {
                    Text(vM.displayedText)
                        .font(.system(size: 38, design: .monospaced))
                        .offset(y: 55)
                        .fixedSize(horizontal: false, vertical: true)
                        .onAppear {
                            vM.startWritingEffect()
                            if vM.makeOptions.isEmpty {
                                vM.getMakeDatas()
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(width: UIScreen.main.bounds.width, height: 140, alignment: .leading)
                        .padding(.leading, 20)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: 200, alignment: .top)
            .cornerRadius(10)
            .position(x: UIScreen.main.bounds.width / 2, y: 0)

            VStack {
                
                UploadPhotoButtonView(vM: vM)
                ListOfCreateView(vM: vM)
                ButtonView(vM: vM)
                
            }
            .onChange(of: readyToSubmit) { newValue in
                withAnimation(.snappy(duration: 0.4)) {
                    vM.showButton = newValue
                }
            }
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.width * 0.22)
            .onChange(of: vM.clickedArray) { newValue in
                if newValue.filter({ $0 }).count == 2 {
                    var oldTrueIndex = 0

                    for (index, (value1, value2)) in zip(vM.previousClickedArray, newValue).enumerated() {
                        if value1 == value2 && value2 {
                            oldTrueIndex = index
                        }
                    }

                    for index in vM.previousClickedArray.indices {
                        if index == oldTrueIndex {
                            withAnimation(.snappy(duration: 0.4)) {
                                vM.clickedArray[index] = false
                            }
                        }
                    }
                }
                vM.previousClickedArray = newValue
            }
            .background(vM.backgroundColor)
            .opacity(vM.textFullyDisplayed ? 1 : 0)
        }
        .background(vM.backgroundColor)
    }
    
    
    
    struct ListOfCreateView: View {
        @ObservedObject var vM: CreateListingViewModel
        @FocusState private var focusedField: CreateListingViewModel.Field?

        var body: some View {
            VStack {
                VStack {
                    HStack {
                        SelectMenuView(vM: SelectMenuViewModel(displayingText: vM.selectedMake, options: vM.makeOptions, title: "Makes"), isClicked: $vM.clickedArray[0], lastSelected: $vM.selectedMake)
                        
                        SelectMenuView(vM: SelectMenuViewModel(displayingText: vM.selectedModel, options: vM.modelOptions, title: "Models"), isClicked: $vM.clickedArray[1], lastSelected: $vM.selectedModel)
                    }
                    .onChange(of: vM.selectedMake) {
                        if vM.textFullyDisplayed {
                            vM.selectedModel = "All models"
                            vM.getModelDatas()
                        }
                        
                    }
                }
                .frame(height: vM.heightValue * 4)
                VStack {
                    HStack {
                        SelectMenuView(vM: SelectMenuViewModel(displayingText: vM.selectedYear, options: vM.yearOptions, lastSelected: vM.selectedYear, title: "Year"), isClicked: $vM.clickedArray[2], lastSelected: $vM.selectedYear)
                        
                        SelectMenuView(vM: SelectMenuViewModel(displayingText: vM.selectedGear, options: vM.gearOptions, lastSelected: vM.selectedGear, title: "Gear"), isClicked: $vM.clickedArray[3], lastSelected: $vM.selectedGear)
                    }
                }
                .frame(height: vM.heightValue * 4)
                VStack {
                    HStack {
                        SelectMenuView(vM: SelectMenuViewModel(displayingText: vM.selectedFuelType, options: vM.fuelTypeOptions, lastSelected: vM.selectedFuelType, title: "Fuel type"), isClicked: $vM.clickedArray[4], lastSelected: $vM.selectedFuelType)
                        
                        SelectMenuView(vM: SelectMenuViewModel(displayingText: vM.selectedCarCondition, options: vM.conditionOptions, lastSelected: vM.selectedCarCondition, title: "Car condition"), isClicked: $vM.clickedArray[5], lastSelected: $vM.selectedCarCondition)
                    }
                }
                .frame(height: vM.heightValue * 4)
                VStack {
                    HStack(alignment: .bottom) {
                        TextField("kilometer", text: $vM.kilometerValue)
                            .foregroundColor(.black)
                            .font(.system(size: 15, design: .monospaced))
                            .focused($focusedField, equals: .kilometer)
                            .shadow(radius: 1)
                            .frame(width: UIScreen.main.bounds.width / 2.45, height: vM.heightValue)
                            .padding(.horizontal)
                            .background(.gray)
                            .cornerRadius(10)
                            .onChange(of: vM.kilometerValue) { newValue in
                                vM.kilometerValue = newValue.trimmingCharacters(in: .whitespaces)
                                vM.kilometerValue = vM.kilometerValue.filter { $0.isNumber }
                                if vM.kilometerValue.first == "0" {
                                    vM.kilometerValue.removeFirst()
                                }
                                if vM.kilometerValue.count > 7 {
                                    vM.kilometerValue.removeLast()
                                }
                            }
                        
                        TextField("price", text: $vM.price)
                            .foregroundColor(.black)
                            .font(.system(size: 15, design: .monospaced))
                            .focused($focusedField, equals: .price)
                            .shadow(radius: 1)
                            .frame(width: UIScreen.main.bounds.width / 2.45, height: vM.heightValue)
                            .padding(.horizontal)
                            .background(.gray)
                            .cornerRadius(10)
                            .onChange(of: vM.price) { newValue in
                                vM.price = newValue.trimmingCharacters(in: .whitespaces)
                                vM.price = vM.price.filter { $0.isNumber }
                                if vM.price.first == "0" {
                                    vM.price.removeFirst()
                                }
                                if vM.price.count > 10 {
                                    vM.price.removeLast()
                                }
                            }
                    }
                    .offset(y: -30)
                }
                .frame(width: UIScreen.main.bounds.width, height: 170)
            }
            .position(x: UIScreen.main.bounds.width / 2, y: vM.showButton ? 140 : 200)
            .opacity(vM.showButton ? 0.60 : 1)
        }
    }

    struct ButtonView: View {
        @ObservedObject var vM: CreateListingViewModel
        
        var body: some View {
            VStack {
                Spacer()
                Button {
                    vM.findListingNumber(makeSelection: vM.selectedMake, modelSelection: vM.selectedModel)
                } label: {
                    ZStack {
                        if vM.loading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(vM.unableToCreate ? "Max listing number is 5" : (vM.createdListing ? "✔" : "Create listing"))
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - 10, height: 50)
                    .background(vM.unableToCreate ? .red : (vM.createdListing ? .green : .purple))
                    .foregroundColor(.white)
                    .font(.system(size: vM.createdListing ? 40 : 23, design: .monospaced))
                }
                .disabled(vM.createdListing || vM.unableToCreate)
                .opacity(vM.showButton ? 1 : 0)
                .cornerRadius(10)
            }
            .frame(height: 450)
        }
    }
}

#Preview {
    CreateListingView(vM: CreateListingViewModel())
}



struct ImagePicker: View {
    @Binding var selectedImages: [PhotosPickerItem]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        PhotosPicker(selection: $selectedImages, maxSelectionCount: 10, matching: .images) {
            Text("Select Images")
        }
        .onChange(of: selectedImages) { newSelection in

            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct UploadPhotoButtonView: View {
    @ObservedObject var vM: CreateListingViewModel
    
    var body: some View {
        Button {
            for (index, value) in vM.clickedArray.enumerated() {
                withAnimation(.snappy(duration: 0.4)) {
                    vM.clickedArray[index] = false
                }
            }
            vM.isPickerPresented = true
        } label: {
            Text(vM.uploadText)
                .foregroundStyle(vM.uploadText == "Upload photos" ? .blue : .black)
                .font(.system(size: 20, design: .monospaced))
        }
        .photosPicker(isPresented: $vM.isPickerPresented, selection: $vM.selectedItems, maxSelectionCount: 10, matching: .images)
        .onChange(of: vM.selectedItems) { newItems in
            vM.loadImageUrls(from: newItems)
        }
        .onChange(of: vM.imageURLs.count) { count in
            if count == 0 {
                vM.uploadText = "Upload photos"
            } else {
                vM.uploadText = "\(count) photos uploaded"
            }
        }
        .position(x: UIScreen.main.bounds.width / 2, y: vM.showButton ? UIScreen.main.bounds.width * 0.83 - 60 : UIScreen.main.bounds.width * 0.83)
        .opacity(vM.showButton ? 0.60 : 1)
    }
}

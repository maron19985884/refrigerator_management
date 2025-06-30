import SwiftUI
import Vision
import UIKit

struct ReceiptOCRView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedImage: UIImage? = nil
    @State private var showingPicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var recognizedItems: [FoodItem] = []
    @State private var showReadAlert = false
    @State private var showCountAlert = false
    var onComplete: ([FoodItem]) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("手順").font(.headline)
                    Text("1. \"カメラ起動\"または\"写真を選択\"をタップ")
                    Text("2. 画像を確認して\"読み取る\"をタップ")
                    Text("3. 完了するとポップアップが表示されます")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                } else {
                    Text("レシートを撮影してください")
                        .foregroundColor(.gray)
                }

                HStack {
                    Button(action: {
                        pickerSource = .camera
                        showingPicker = true
                    }) {
                        Text("カメラ起動")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        pickerSource = .photoLibrary
                        showingPicker = true
                    }) {
                        Text("写真を選択")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)

                Button("読み取る") {
                    if let image = selectedImage {
                        let items = recognize(from: image)
                        recognizedItems = items
                        onComplete(items)
                        showReadAlert = true
                    }
                }
                .disabled(selectedImage == nil)
                .padding()
            }
            .navigationTitle("AI-OCR")
            .sheet(isPresented: $showingPicker) {
                ImagePicker(image: $selectedImage, sourceType: pickerSource)
            }
            .alert("読み取り完了", isPresented: $showReadAlert) {
                Button("OK") { showCountAlert = true }
            } message: {
                Text("レシートの読み取りが完了しました")
            }
            .alert("\(recognizedItems.count)件の食材を登録しました", isPresented: $showCountAlert) {
                Button("OK") { presentationMode.wrappedValue.dismiss() }
            }
        }
    }

    private func recognize(from image: UIImage) -> [FoodItem] {
        var results: [FoodItem] = []
        guard let cgImage = image.cgImage else { return results }
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ja-JP", "en-US"]
        request.usesLanguageCorrection = true
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return results }
        let lines = observations.compactMap { $0.topCandidates(1).first?.string }
        for line in lines {
            // 数量は行末の数値として抽出
            let pattern = "(.+)\\s(\\d+)$"
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..<line.endIndex, in: line)),
               let nameRange = Range(match.range(at: 1), in: line),
               let qtyRange = Range(match.range(at: 2), in: line) {
                let name = String(line[nameRange])
                let qtyString = String(line[qtyRange])
                if let qty = Int(qtyString) {
                    let item = FoodItem(name: name,
                                        quantity: qty,
                                        expirationDate: Date(),
                                        storageType: .fridge)
                    results.append(item)
                }
            }
        }
        return results
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.image = img
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}


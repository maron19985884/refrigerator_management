import SwiftUI
import Vision
import UIKit

struct ReceiptOCRView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedImage: UIImage? = nil
    @State private var showingPicker = false
    var onComplete: ([FoodItem]) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                } else {
                    Text("レシートを選択してください")
                        .foregroundColor(.gray)
                }

                Button(action: { showingPicker = true }) {
                    Text("写真を選択")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                Button("完了") {
                    if let image = selectedImage {
                        let items = recognize(from: image)
                        onComplete(items)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(selectedImage == nil)
                .padding()
            }
            .navigationTitle("AI-OCR")
            .sheet(isPresented: $showingPicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }

    private func recognize(from image: UIImage) -> [FoodItem] {
        var results: [FoodItem] = []
        guard let cgImage = image.cgImage else { return results }
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return results }
        let lines = observations.compactMap { $0.topCandidates(1).first?.string }
        for line in lines {
            let tokens = line.components(separatedBy: CharacterSet.whitespaces)
            if tokens.count >= 2, let qty = Int(tokens.last!) {
                let name = tokens.dropLast().joined(separator: " ")
                let item = FoodItem(name: name,
                                    quantity: qty,
                                    expirationDate: Date(),
                                    storageType: .fridge)
                results.append(item)
            }
        }
        return results
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
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


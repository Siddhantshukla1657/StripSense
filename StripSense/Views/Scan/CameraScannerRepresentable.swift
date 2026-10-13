//
//  CameraScannerRepresentable.swift
//  StripSense
//

import SwiftUI
import VisionKit
import Vision
import AVFoundation

#if canImport(VisionKit)
public struct CameraScannerRepresentable: UIViewControllerRepresentable {
    public var onScanResult: (ScanResult) -> Void
    public var onError: (String) -> Void
    
    public init(onScanResult: @escaping (ScanResult) -> Void, onError: @escaping (String) -> Void) {
        self.onScanResult = onScanResult
        self.onError = onError
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
            let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> = [
                .text(),
                .barcode()
            ]
            let scanner = DataScannerViewController(
                recognizedDataTypes: recognizedDataTypes,
                qualityLevel: .balanced,
                recognizesMultipleItems: true,
                isHighFrameRateTrackingEnabled: true,
                isHighlightingEnabled: true
            )
            scanner.delegate = context.coordinator
            try? scanner.startScanning()
            return scanner
        } else {
            // Simulator or device without VisionKit hardware scanner support
            let fallbackVC = UIViewController()
            let label = UILabel()
            label.text = "Camera Live Scanner requires physical camera.\nUse Photo Import or Test Samples below."
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = .secondaryLabel
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            fallbackVC.view.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: fallbackVC.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: fallbackVC.view.centerYAnchor),
                label.leadingAnchor.constraint(greaterThanOrEqualTo: fallbackVC.view.leadingAnchor, constant: 20)
            ])
            return fallbackVC
        }
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    public class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let parent: CameraScannerRepresentable
        private var multiFrameBuffer: [String] = []
        private var lastDetectedBarcode: String?
        private var scanThrottleTimer: Date = Date()
        
        init(parent: CameraScannerRepresentable) {
            self.parent = parent
        }
        
        public func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            processItems(allItems)
        }
        
        public func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            processItems(allItems)
        }
        
        private func processItems(_ items: [RecognizedItem]) {
            guard Date().timeIntervalSince(scanThrottleTimer) > 0.5 else { return }
            scanThrottleTimer = Date()
            
            var textLines: [String] = []
            var foundBarcode: String? = nil
            
            for item in items {
                switch item {
                case .text(let text):
                    textLines.append(text.transcript)
                case .barcode(let barcode):
                    if let val = barcode.payloadStringValue {
                        foundBarcode = val
                    }
                @unknown default:
                    break
                }
            }
            
            if !textLines.isEmpty || foundBarcode != nil {
                let joinedText = textLines.joined(separator: "\n")
                let result = ScanResult(
                    rawText: joinedText,
                    recognizedLines: textLines,
                    detectedBarcode: foundBarcode,
                    confidence: 0.92
                )
                DispatchQueue.main.async {
                    self.parent.onScanResult(result)
                }
            }
        }
    }
}
#endif

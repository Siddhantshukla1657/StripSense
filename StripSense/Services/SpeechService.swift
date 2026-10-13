//
//  SpeechService.swift
//  StripSense
//

import Foundation
import AVFoundation

public class SpeechService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    public static let shared = SpeechService()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    @Published public var isSpeaking: Bool = false
    
    public override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    /// Reads aloud confirmed drug details and expiry status
    public func speak(drug: Drug, expiryStatus: ExpiryStatus? = nil, expiryString: String? = nil) {
        stop()
        
        var script = "Medicine: \(drug.brand). "
        script += "Composition: \(drug.saltsSummary). "
        script += "Dosage form: \(drug.dosageForm). "
        
        if drug.mrp > 0 {
            script += "Maximum retail price: \(AppFormatters.formatINR(drug.mrp)). "
        }
        
        if let status = expiryStatus {
            switch status {
            case .ok:
                script += "Expiry status: Valid until \(expiryString ?? "recorded date"). "
            case .expiringSoon:
                script += "Warning: This strip is expiring soon in \(expiryString ?? "upcoming weeks"). "
            case .expired:
                script += "Danger: This medicine is expired. Do not consume. "
            case .unknown:
                break
            }
        }
        
        if let safety = drug.safetyFlag {
            script += "Important Medical Alert: \(safety.reason). "
        }
        
        let utterance = AVSpeechUtterance(string: script)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-IN") ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = Float(AppSettings.shared.speechRate)
        utterance.pitchMultiplier = 1.0
        
        synthesizer.speak(utterance)
        isSpeaking = true
    }
    
    public func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}

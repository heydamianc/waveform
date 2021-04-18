//
//  Waveform.swift
//  Waveform
//
//  Created by Damian Carrillo on 4/17/21.
//  Copyright © 2021 Damian Carrillo. All rights reserved.
//

import Foundation
import AVFoundation

public enum WaveformAnalysisError: Error {
    case missingProgress
    case bufferInitializationError
    case pcmDataUnavailableError
    case readError(cause: Error)
}

struct Waveform {

    let audioFile: AVAudioFile
    let audioBuffer: AVAudioPCMBuffer
    let levels: ClosedRange<Float>
    var maxLevel: Float {
        return max(abs(levels.upperBound), abs(levels.lowerBound))
    }

    init(audioFile: AVAudioFile, audioBuffer: AVAudioPCMBuffer, levels: ClosedRange<Float>) {
        self.audioFile = audioFile
        self.audioBuffer = audioBuffer
        self.levels = levels
    }
    
    static func analyze(
        _ audioFileURL: URL,
        analysisQueue: DispatchQueue = DispatchQueue.global(qos: .userInitiated),
        completionQueue: DispatchQueue = DispatchQueue.main,
        completion: @escaping (Result<Waveform, WaveformAnalysisError>) -> Void
    ) -> Progress {
        let progress = Progress()
        let analyzeWaveform = DispatchWorkItem { [weak progress] in
            guard let progress = progress else {
                completionQueue.async {
                    completion(.failure(.missingProgress))
                }
                return
            }
            do {
                let audioFile = try AVAudioFile(forReading: audioFileURL)
                let frameCount = AVAudioFrameCount(audioFile.length)

                guard let audioBuffer = AVAudioPCMBuffer(
                    pcmFormat: audioFile.processingFormat,
                    frameCapacity: frameCount
                ) else {
                    completionQueue.async {
                        completion(.failure(.bufferInitializationError))
                    }
                    return
                }

                try audioFile.read(into: audioBuffer, frameCount: frameCount)

                guard let audioData = audioBuffer.floatChannelData else {
                    completionQueue.async {
                        completion(.failure(.pcmDataUnavailableError))
                    }
                    return
                }

                let channelCount = audioBuffer.format.channelCount
                let frameLength = audioBuffer.frameLength
                let totalUnitCount = Int64(channelCount * frameLength)
                let completionSteps = totalUnitCount / 100

                progress.totalUnitCount = totalUnitCount
                progress.becomeCurrent(withPendingUnitCount: totalUnitCount)

                var maxLevel: Float = 0.0
                var minLevel: Float = 0.0
                var completedUnitCount = Int64(0)

                for channel in 0..<channelCount {
                    for frame in 0..<frameLength {
                        guard !progress.isCancelled else { break }

                        let channel = Int(channel)
                        let frame = Int(frame)
                        let level = audioData[channel][frame * audioBuffer.stride]

                        // Calculate the max and min levels so we can scale the view to look reasonable
                        
                        maxLevel = max(level, maxLevel)
                        minLevel = min(level, minLevel)

                        completedUnitCount += 1

                        if completedUnitCount % completionSteps == 0 || completedUnitCount >= totalUnitCount {
                            progress.completedUnitCount = completedUnitCount
                        }
                    }
                }

                let waveform = Waveform(audioFile: audioFile, audioBuffer: audioBuffer, levels: minLevel...maxLevel)

                completionQueue.async {
                    completion(.success(waveform))
                }

                progress.resignCurrent()
            } catch {
                completionQueue.async {
                    completion(.failure(.readError(cause: error)))
                }
                return
            }
        }

        progress.cancellationHandler = {
            analyzeWaveform.cancel()
        }

        analysisQueue.async(execute: analyzeWaveform)

        return progress
    }
}

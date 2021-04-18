//
//  WaveformView.swift
//  Waveform
//
//  Created by Damian Carrillo on 7/6/19.
//  Copyright © 2019 Damian Carrillo. All rights reserved.
//

import UIKit
import AVFoundation

final class WaveformView: UIView {

    private let waveform: Waveform

    init(waveform: Waveform) {
        self.waveform = waveform
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        UIColor.systemBackground.setFill()
        UIBezierPath(rect: rect).fill()

        let positivePath = UIBezierPath()
        let negativePath = UIBezierPath()
        let maxLevel = waveform.maxLevel
        let halfHeight = rect.height * 0.5

        negativePath.move(to: .zero)
        positivePath.move(to: .zero)

        if waveform.audioBuffer.format.channelCount > 0, let audioData = waveform.audioBuffer.floatChannelData {
            let framesPerPoint = waveform.audioBuffer.frameLength / AVAudioFrameCount(rect.width)
            var drawnLevel = Float(0)

            for frame in 0..<waveform.audioBuffer.frameLength {
                let level = audioData[0][Int(frame) * waveform.audioBuffer.stride]
                drawnLevel = max(abs(drawnLevel), abs(level))

                if frame % framesPerPoint == 0 || frame == waveform.audioBuffer.frameLength {
                    let x = rect.width * CGFloat(frame) / CGFloat(waveform.audioBuffer.frameLength)
                    let y = halfHeight * CGFloat(drawnLevel) / CGFloat(maxLevel)

                    negativePath.addLine(to: CGPoint(x: x, y: -y))
                    positivePath.addLine(to: CGPoint(x: x, y: y))

                    drawnLevel = 0
                }
            }
        }

        positivePath.addLine(to: CGPoint(x: rect.width, y: 0))
        negativePath.addLine(to: CGPoint(x: rect.width, y: 0))
        positivePath.append(negativePath)
        positivePath.close()

        UIColor.systemPink.setStroke()
        UIColor.systemPink.setFill()

        positivePath.apply(CGAffineTransform(translationX: 0, y: halfHeight))
        positivePath.lineWidth = 1
        positivePath.fill()
        positivePath.stroke()
    }

}

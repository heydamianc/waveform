//
//  ViewController.swift
//  Waveform
//
//  Created by Damian Carrillo on 7/5/19.
//  Copyright © 2019 Damian Carrillo. All rights reserved.
//

import UIKit
import AVFoundation

final class ViewController: UIViewController {

    var observer: NSKeyValueObservation?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        guard let audioFile = Bundle.main.url(forResource: "slum-beautiful-intro", withExtension: "aac") else {
            let alertController = UIAlertController(
                title: "Error Occurred",
                message: "The audio file could not be found.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }

        let progress = Waveform.analyze(audioFile) { [weak self] (result) in
            switch result {
            case let .success(waveform):
                self?.showWaveform(waveform)
            case let .failure(error):
                print("Error analyzing waveform: \(error)")
            }
        }

        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.observedProgress = progress

        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }

    func showWaveform(_ waveform: Waveform) {
        let waveformView = WaveformView(waveform: waveform)
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(waveformView)

        NSLayoutConstraint.activate([
            waveformView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waveformView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            waveformView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            waveformView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

}

import AVFoundation

public protocol SignalTrackerDelegate: class {

  func signalTracker(signalTracker: SignalTracker,
    didReceiveBuffer buffer: AVAudioPCMBuffer,
    atTime time: AVAudioTime)
  func signalTrackerDidFinishSong(signalTracker: SignalTracker)
}

public protocol SignalTracker: class {
  
  weak var delegate: SignalTrackerDelegate? { get set }

  func start() throws
  func playOrPause()
  func stop()
}

import AVFoundation

public class InputSignalTracker: SignalTracker {
  
  public enum Error: ErrorType {
    case InputNodeMissing
    case AudioSessionErrorInsufficientPriority
  }
  
  public let bufferSize: AVAudioFrameCount
  public weak var delegate: SignalTrackerDelegate?
  
  private var audioEngine: AVAudioEngine!
  private let session = AVAudioSession.sharedInstance()
  private let bus = 0
  
  // MARK: - Initialization
  
  public required init(bufferSize: AVAudioFrameCount = 2048, delegate: SignalTrackerDelegate? = nil) {
    self.bufferSize = bufferSize
    self.delegate = delegate
  }
  
  // MARK: - Tracking
  
  public func start() throws {
    try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
    try session.setPreferredSampleRate(44100.0)
    try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
    
    do {
      try session.setActive(true)
    } catch {
      throw Error.AudioSessionErrorInsufficientPriority
    }
    
    audioEngine = AVAudioEngine()
    
    guard let inputNode = audioEngine.inputNode else {
      throw Error.InputNodeMissing
    }
    
    let format = inputNode.inputFormatForBus(bus)
    
    inputNode.installTapOnBus(bus, bufferSize: bufferSize, format: format) { buffer, time in
      dispatch_async(dispatch_get_main_queue()) {
        self.delegate?.signalTracker(self, didReceiveBuffer: buffer, atTime: time)
      }
    }
    
    audioEngine.prepare()
    try audioEngine.start()
  }
  
  public func playOrPause() {
    
  }
  
  public func stop() {
    audioEngine.stop()
    audioEngine.reset()
    audioEngine = nil
  }
}

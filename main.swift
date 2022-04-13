import CoreBluetooth
import Foundation

class EmberDelegate: NSObject, CBCentralManagerDelegate {
  private var mgr: CBCentralManager!

  override init() {
    print("init EmberDelegate")
    super.init()
    mgr = CBCentralManager(delegate: self, queue: nil)
  }

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    print("didUpdateState")
    switch central.state {
    case .poweredOn:
      print("on")
      central.scanForPeripherals(withServices: nil)
    default:
      print(central.state.rawValue)
    //case .poweredOff:
    //case .resetting:
    //case .unauthorized:
    //case .unsupported:
    //case .unknown:
    }
  }

  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    print("didDiscover")
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print("didConnect")
    peripheral.discoverServices(nil)
  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    print("didDisconnect")
    central.scanForPeripherals(withServices: nil, options: nil)
  }
} // EmberDelegate

print("Hello, world!")
let ember = EmberDelegate()
while true {
  let US_TO_S: useconds_t = 1000000
  usleep(1 * US_TO_S)
}

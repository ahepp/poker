import CoreBluetooth
import Foundation

class EmberDelegate: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
  private var active = true;
  private var emberServiceId = CBUUID(string: "FC543622-236C-4C94-8FA9-944A3E5353FA")
  private var emberPeripheralId = UUID(uuidString: "3217D429-F44C-EF48-B66E-ADFBF44ECDAC")
  private var emberCharacteristicId = CBUUID(string: "FC540003-236C-4C94-8FA9-944A3E5353FA")
  private var mug: CBPeripheral!

  func isActive() -> Bool {
      return active;
  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
    case .poweredOn:
      // TODO why doesn't this work? UUID shows up in services later...
      //central.scanForPeripherals(withServices: [emberServiceId])
      central.scanForPeripherals(withServices: nil)
      print("started scan")
    default:
      print("centralManagerDidUpdateState: " + String(central.state.rawValue))
      central.stopScan()
      print("stopped scan")
    //case .poweredOff:
    //case .resetting:
    //case .unauthorized:
    //case .unsupported:
    //case .unknown:
    }
  }

  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
      guard peripheral.identifier == emberPeripheralId else {return}
      print("discovered " + peripheral.identifier.uuidString)

      central.stopScan()
      print("stopped scan")
      central.connect(peripheral, options: nil)
      mug = peripheral
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print("connected to " + peripheral.identifier.uuidString)
    peripheral.delegate = self
    peripheral.discoverServices(nil)
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if let ss = peripheral.services {
      for s in ss {
        print("discovered service " + s.uuid.uuidString)
        peripheral.discoverCharacteristics(nil, for: s)
      }
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    if let cs = service.characteristics {
      for c in cs {
        print("discovered service: " + service.uuid.uuidString + " characteristic " + c.uuid.uuidString)
        if c.uuid == emberCharacteristicId {
          let data = Data(_ : [0x59, 0x16])
          peripheral.writeValue(data, for: c, type: .withResponse)
          active = false
        }
      }
    }
  }
} // EmberDelegate

let emberDelegate = EmberDelegate()
let queue = DispatchQueue(label: "ConcurrentQueue", qos: .default, attributes: .concurrent)
let mgr = CBCentralManager(delegate: emberDelegate, queue: queue)
while emberDelegate.isActive() {
  let US_TO_S: useconds_t = 1000000
  usleep(1 * US_TO_S)
}

import Foundation

func opencodeStableHash(_ value: String) -> UInt64 {
    let data = Array(value.lowercased().utf8)
    var hash: UInt64 = 14_695_981_039_346_656_037

    for byte in data {
        hash ^= UInt64(byte)
        hash &*= 1_099_511_628_211
    }

    return hash
}

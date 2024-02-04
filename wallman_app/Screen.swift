import AppKit

extension NSScreen {
    var displayId: UInt32? {
        return self.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? UInt32
    }
}

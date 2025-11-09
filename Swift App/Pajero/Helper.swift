import SystemConfiguration
import CoreLocation
import NetworkExtension
import CoreFoundation
import Foundation
import Network

class Helper {
    static let shared = Helper() // Singleton pattern
    private init() {}
    
    func isVPNConnected() -> Bool {
        // Check for specific VPN interface patterns
        let vpnInterfaces = [
            "utun",   // Most common VPN interface
            "ppp",    // Point-to-Point Protocol
            "ipsec",  // IPSec VPN
            "tun",    // Tunneling interface
            "wg"      // WireGuard
        ]
        
        guard let settings = CFNetworkCopySystemProxySettings() else {
            return false
        }
        
        let dictionary = settings.takeRetainedValue() as NSDictionary
        
        // Convert dictionary to string representation for comprehensive checking
        let dictionaryString = dictionary.description.lowercased()
        
        // Check if any VPN interface is present in the dictionary
        let vpnInterfaceFound = vpnInterfaces.contains { interface in
            dictionaryString.contains(interface)
        }
        
        return vpnInterfaceFound
    }
    
    private func isInterfaceActive(_ interfaceName: String) -> Bool {
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &address, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) else {
            return false
        }
        
        return flags.contains(.isWWAN)
    }
    
    // Optional: More detailed VPN connection information
    func getVPNConnectionDetails() -> [String: Any]? {
        guard let settings = CFNetworkCopySystemProxySettings() else {
            return nil
        }
        
        let dictionary = settings.takeRetainedValue() as NSDictionary
        
        return [
            "VPNConnected": isVPNConnected(),
            "ProxySettings": dictionary
        ]
    }
    
    func checkVPNStatus() -> Bool {
        if isVPNConnected() {
            print("VPN is connected")
            let details = getVPNConnectionDetails()

            return true
        } else {
            print("VPN is not connected")
            return false
        }
    }
    
    func getWiFiSSID() -> String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return nil
        }
        
        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] else {
                continue
            }
            
            return interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
        }
        
        return nil
    }
    
    // Optional: Add error handling version
    func getWiFiSSIDWithError() -> Result<String, Error> {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return .failure(NSError(domain: "WiFiError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No network interfaces found"]))
        }
        
        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] else {
                continue
            }
            
            if let ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String {
                return .success(ssid)
            }
        }
        
        return .failure(NSError(domain: "WiFiError", code: 2, userInfo: [NSLocalizedDescriptionKey: "No WiFi SSID found"]))
    }
    
    // Usage examples
    func exampleUsage() {
        // Simple VPN check
        let vpnStatus = checkVPNStatus()
        print("VPN Connected: \(vpnStatus)")
        
        // Simple WiFi SSID usage
        if let ssid = getWiFiSSID() {
            print("Connected to WiFi: \(ssid)")
        }
        
        // Error handling WiFi SSID usage
        switch getWiFiSSIDWithError() {
        case .success(let ssid):
            print("WiFi SSID: \(ssid)")
        case .failure(let error):
            print("Failed to get SSID: \(error.localizedDescription)")
        }
    }
}

struct NetworkChecker {
    static func getNetworkInterfaces() -> [String]? {
        var interfaceList: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaceList) == 0 else {
            return nil
        }
        defer { freeifaddrs(interfaceList) }
        
        var interfaces = [String]()
        var pointer = interfaceList
        
        while pointer != nil {
            let interface = pointer?.pointee
            let name = String(cString: (interface?.ifa_name)!)
            interfaces.append(name)
            
            pointer = interface?.ifa_next
        }
        
        return interfaces
    }
}

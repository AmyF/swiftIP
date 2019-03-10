import Foundation

private let v4InV6Prefix: [UInt8] = [0, 0, 0, 0 ,0, 0,0,0,0,0,0xff,0xff]

public protocol IP {
    var bytes: [UInt8] { get }
    
    var isIPv4: Bool { get }
    var isIPv6: Bool { get }
    
    func toIPv4() -> IPv4?
    func toIPv6() -> IPv6?
    func string(formatter: IPFormatter) -> String
    
    var isGlobalUnicast: Bool { get }
    var isZero: Bool { get }
    var isUnspecified: Bool { get }
    var isLoopback: Bool { get }
    var isMulticast: Bool { get }
    var isInterfaceLocalMulticast: Bool { get }
    var isLinkLocalMulticast: Bool { get }
    var isLinkLocalUnicast: Bool { get }
}

public protocol IPFormatter {
    func string(from ip: IP) -> String
}

public struct IPFormatStyle: IPFormatter, Equatable {
    private enum Style {
        case dotDecimal, dotHexadecimal, dotOctal, decimal, hexadecimal, octal
    }
    public static let dotDecimal = IPFormatStyle(style: .dotDecimal)
    public static let dotHexadecimal = IPFormatStyle(style: .dotHexadecimal)
    public static let dotOctal = IPFormatStyle(style: .dotOctal)
    public static let decimal = IPFormatStyle(style: .decimal)
    public static let hexadecimal = IPFormatStyle(style: .hexadecimal)
    public static let octal = IPFormatStyle(style: .octal)
    
    private let style: Style
    
    public func string(from ip: IP) -> String {
        switch style {
        case .dotDecimal: return ip.bytes.map{String($0)}.joined(separator: ".")
        case .dotHexadecimal: return ip.bytes.map{String(format: "0x%02X", $0)}.joined(separator: ".")
        case .dotOctal: return ip.bytes.map{String(format: "%04O", $0)}.joined(separator: ".")
        case .decimal: return String(ip.bytes.reduce(0){($0 << 8) + Int($1)})
        case .hexadecimal: return "0x" + String(ip.bytes.reduce(0){($0 << 8) + Int($1)}, radix: 16, uppercase: true)
        case .octal: return "0" + String(ip.bytes.reduce(0){($0 << 8) + Int($1)}, radix: 8, uppercase: true)
        }
    }
}

public extension IP {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs.isIPv4, rhs.isIPv4) {
        case (true, true):
            return lhs.bytes == rhs.bytes
        case (true, false):
            return [UInt8](rhs.bytes[...12]) == v4InV6Prefix && lhs.bytes == [UInt8](rhs.bytes[12...])
        case (false, true):
            return [UInt8](lhs.bytes[...12]) == v4InV6Prefix && rhs.bytes == [UInt8](lhs.bytes[12...])
        case (false, false):
            return lhs.bytes == rhs.bytes
        }
    }
}

public struct IPv4: IP {
    static let zero = IPv4(from: [0,0,0,0])!
    static let bcast = IPv4(from: [255,255,255,255])!
    
    public let lenght = 4
    public let bytes: [UInt8]
    
    init?(from: String) {
        let segment = from.components(separatedBy: ".")
        if (segment.contains{$0.count == 0}) || (segment.compactMap{Int($0)}.contains{$0 > 255}) {
            return nil
        }
        
        bytes = segment.compactMap { UInt8($0) }
        if bytes.count != lenght {
            return nil
        }
    }
    
    init?(from: [UInt8]) {
        if from.count != 4 {
            return nil
        }
        bytes = from
    }
    
    public var isIPv4: Bool {
        return true
    }
    
    public var isIPv6: Bool {
        return false
    }
    
    public func toIPv4() -> IPv4? {
        return self
    }
    
    public func toIPv6() -> IPv6? {
        return IPv6()
    }
    
    public func string(formatter: IPFormatter = IPFormatStyle.dotDecimal) -> String {
        return formatter.string(from: self)
    }
    
    public func string(formatter: IPFormatStyle = .dotDecimal) -> String {
        return formatter.string(from: self)
    }
    
    public var isGlobalUnicast: Bool {
        return !(self == .bcast) &&
            !isUnspecified &&
            !isLoopback &&
            !isMulticast &&
            !isLinkLocalUnicast
    }
    
    public var isZero: Bool {
        return bytes.contains(where: {$0 == 0})
    }
    
    public var isUnspecified: Bool {
        return self == IPv4.zero
    }
    
    public var isLoopback: Bool {
        return bytes[0] == 127
    }
    
    public var isMulticast: Bool {
        return bytes[0] & 0xf0 == 0xe0
    }
    
    public var isInterfaceLocalMulticast: Bool {
        return false
    }
    
    public var isLinkLocalMulticast: Bool {
        return bytes[0] == 224 && bytes[1] == 0 && bytes[2] == 0
    }
    
    public var isLinkLocalUnicast: Bool {
        return bytes[0] == 169 && bytes[1] == 254
    }
}

public struct IPv6 {
    
}

import Foundation

private let _v4InV6Prefix: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xFF, 0xFF]
private let _v4BytesLength: Int = 4
private let _v6BytesLength: Int = 16

public protocol IPFormatter {
    func string(from ip: IP) -> String
}

public protocol IPFormattable {
    func string(formatter: IPFormatter) -> String
}

public protocol IP: IPFormattable {
    var bytes: [UInt8] { get }
    
    var isIPv4: Bool { get }
    var isIPv6: Bool { get }
    
    func toIPv4() -> IPv4?
    func toIPv6() -> IPv6?
    
    var isGlobalUnicast: Bool { get }
    var isZero: Bool { get }
    var isUnspecified: Bool { get }
    var isLoopback: Bool { get }
    var isMulticast: Bool { get }
    var isInterfaceLocalMulticast: Bool { get }
    var isLinkLocalMulticast: Bool { get }
    var isLinkLocalUnicast: Bool { get }
    
    func defaultMask() -> IPMask?
    func masking(with mask: IPMask) -> IPv4?
}

public extension IP {
    public func isEqual(to: IP) -> Bool {
        switch (isIPv4, to.isIPv4) {
        case (true, true):
            return bytes == to.bytes
        case (true, false):
            return [UInt8](to.bytes[...12]) == _v4InV6Prefix && bytes == [UInt8](to.bytes[12...])
        case (false, true):
            return [UInt8](bytes[...12]) == _v4InV6Prefix && to.bytes == [UInt8](bytes[12...])
        case (false, false):
            return bytes == to.bytes
        }
    }
    
    public var isGlobalUnicast: Bool {
        return (isIPv4 || isIPv6) &&
            !isEqual(to: IPv4.boardcast) &&
            !isUnspecified &&
            !isLoopback &&
            !isMulticast &&
            !isLinkLocalUnicast
    }
    
    public var isZero: Bool {
        return bytes.contains(where: { $0 == 0 })
    }
    
    public var isUnspecified: Bool {
        return (isIPv4 && isEqual(to: IPv4.zero)) || (isIPv6 && isEqual(to: IPv6.unspecified))
    }
    
    public var isLoopback: Bool {
        return (isIPv4 && bytes[0] == 127) || isEqual(to: IPv6.loopback)
    }
    
    public var isMulticast: Bool {
        return (isIPv4 && bytes[0] & 0xF0 == 0xE0) || (isIPv6 && bytes[0] == 0xFF)
    }
    
    public var isInterfaceLocalMulticast: Bool {
        return isIPv6 && (bytes[0] == 0xFF) && (bytes[1] & 0x0F == 0x01)
    }
    
    public var isLinkLocalMulticast: Bool {
        return (isIPv4 && bytes[0] == 224 && bytes[1] == 0 && bytes[2] == 0) ||
            (isIPv6 && bytes[0] == 0xFF && bytes[1] & 0x0F == 0x02)
    }
    
    public var isLinkLocalUnicast: Bool {
        return (isIPv4 && bytes[0] == 169 && bytes[1] == 254) ||
            (isIPv6 && bytes[0] == 0xFE && bytes[1] & 0xC0 == 0x80)
    }
    
    public func defaultMask() -> IPMask? {
        if let ip = toIPv4() {
            return IPMask(from: ip)
        }
        return nil
    }
    
    public func masking(with mask: IPMask) -> IPv4? {
        guard let ip = toIPv4() else {
            return nil
        }
        let bytes = zip(ip.bytes, mask.bytes).map { $0 & $1 }
        return IPv4(from: bytes)
    }
}

public struct IPv4: IP {
    public static let zero = IPv4(from: [0, 0, 0, 0])!
    public static let boardcast = IPv4(from: [255, 255, 255, 255])!
    
    public let bytes: [UInt8]
    
    init?(from: String) {
        self.init(from: from.components(separatedBy: ".").compactMap { UInt8($0) })
    }
    
    init?(from: [UInt8]) {
        if from.count != _v4BytesLength {
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
        return IPv6(from: _v4InV6Prefix + bytes)
    }
    
    public func string(formatter: IPFormatter = Formatter.dotDecimal) -> String {
        return formatter.string(from: self)
    }
    
    public func string(formatter: Formatter = .dotDecimal) -> String {
        return formatter.string(from: self)
    }
}

public extension IPv4 {
    public struct Formatter: IPFormatter, Equatable {
        private enum Style {
            case dotDecimal, dotHexadecimal, dotOctal, decimal, hexadecimal, octal
        }
        
        public static let dotDecimal = Formatter(style: .dotDecimal)
        public static let dotHexadecimal = Formatter(style: .dotHexadecimal)
        public static let dotOctal = Formatter(style: .dotOctal)
        public static let decimal = Formatter(style: .decimal)
        public static let hexadecimal = Formatter(style: .hexadecimal)
        public static let octal = Formatter(style: .octal)
        
        private let style: Style
        
        public func string(from ip: IP) -> String {
            switch style {
            case .dotDecimal: return ip.bytes.map { String($0) }.joined(separator: ".")
            case .dotHexadecimal: return ip.bytes.map { String(format: "0x%02X", $0) }.joined(separator: ".")
            case .dotOctal: return ip.bytes.map { String(format: "%04O", $0) }.joined(separator: ".")
            case .decimal: return String(ip.bytes.reduce(0) { ($0 << 8) + Int($1) })
            case .hexadecimal: return "0x" + String(ip.bytes.reduce(0) { ($0 << 8) + Int($1) }, radix: 16, uppercase: true)
            case .octal: return "0" + String(ip.bytes.reduce(0) { ($0 << 8) + Int($1) }, radix: 8, uppercase: true)
            }
        }
    }
}

public struct IPv6: IP {
    public static let zero = IPv6(from: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])!
    
    public static let unspecified = IPv6(from: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])!
    
    public static let loopback = IPv6(from: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])!
    
    public static let interfacelocalallnodes = IPv6(from: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])!
    
    public static let linklocalallnodes = IPv6(from: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])!
    
    public static let linklocalallrouters = IPv6(from: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])!
    
    public let bytes: [UInt8]
    
    init?(from: String) {
        if let ip = IPv6.build(normal: from) {
            self = ip
        } else if let ip = IPv6.build(doubleColon: from) {
            self = ip
        } else if let ip = IPv6.build(dot: from) {
            self = ip
        } else {
            return nil
        }
    }
    
    init?(from: [UInt8]) {
        if from.count != _v6BytesLength {
            return nil
        }
        self.bytes = from
    }
    
    private static func build(normal ip: String) -> IPv6? {
        let cmpt = ip.components(separatedBy: ":")
        guard cmpt.count == 8 else {
            return nil
        }
        return IPv6(from: cmpt.compactMap{UInt16($0, radix: 16)}.flatMap{toUInt8(from: $0)})
    }
    
    private static func build(doubleColon ip: String) -> IPv6? {
        let cmpt = ip.components(separatedBy: "::")
        guard cmpt.count == 2 else {
            return nil
        }
        let pre = cmpt[0].components(separatedBy: ":")
        let suf = cmpt[1].components(separatedBy: ":")
        let prebytes = pre.compactMap{UInt16($0, radix: 16)}.flatMap{toUInt8(from: $0)}
        let sufbytes = suf.compactMap{UInt16($0, radix: 16)}.flatMap{toUInt8(from: $0)}
        let diff = (0..<(_v6BytesLength - prebytes.count - sufbytes.count)).map{_ in UInt8(0)}
        return IPv6(from: prebytes + diff + sufbytes)
    }
    
    private static func build(dot ip: String) -> IPv6? {
        let cmpt = ip.components(separatedBy: ".")
        guard cmpt.count == 32 else {
            return nil
        }
        return IPv6(from: (0..<_v6BytesLength).compactMap{UInt8(cmpt[$0 * 2] + cmpt[$0 * 2 + 1], radix: 16)})
    }
    
    private static func toUInt8(from uint16: UInt16) -> [UInt8] {
        return [UInt8((uint16 & 0xFF00) >> 8),UInt8(uint16 & 0xFF)]
    }
    
    public var isIPv4: Bool {
        return false
    }
    
    public var isIPv6: Bool {
        return true
    }
    
    public func toIPv4() -> IPv4? {
        guard [UInt8](bytes[..<12]) == _v4InV6Prefix else {
            return nil
        }
        return IPv4(from: [UInt8](bytes[12...]))
    }
    
    public func toIPv6() -> IPv6? {
        return self
    }
    
    public func string(formatter: IPFormatter) -> String {
        return formatter.string(from: self)
    }
}

public extension IPv6 {
    public struct Formatter: IPFormatter, Equatable {
        public func string(from ip: IP) -> String {
            // TODO: TODO
            return "\(ip)"
        }
    }
}

public struct IPMask: IPFormattable {
    public static let classAMask = IPMask(from: [0xFF, 0, 0, 0])!
    public static let classBMask = IPMask(from: [0xFF, 0xFF, 0, 0])!
    public static let classCMask = IPMask(from: [0xFF, 0xFF, 0xFF, 0])!
    
    public let bytes: [UInt8]
    public let number: Number
    
    init?(from: [UInt8]) {
        guard from.count == _v4BytesLength else {
            return nil
        }
        guard let number = Number(bytes: from) else {
            return nil
        }
        
        self.bytes = from
        self.number = number
    }
    
    init(from ip: IPv4) {
        switch ip.bytes[0] {
        case ...0x80:
            self = .classAMask
        case ...0xC0:
            self = .classBMask
        default:
            self = .classCMask
        }
    }
    
    public func string(formatter: IPFormatter) -> String {
        return formatter.string(from: IPv4(from: bytes)!)
    }
    
    public func string(formatter: IPv4.Formatter = .dotDecimal) -> String {
        return formatter.string(from: IPv4(from: bytes)!)
    }
    
    public struct Number {
        let network: Int
        let host: Int
        
        init?(bytes: [UInt8]) {
            var network = 0
            for (index, value) in bytes.enumerated() {
                if value == 0xFF {
                    network += 8
                    continue
                }
                var check = value
                while check & 0x80 != 0 {
                    network += 1
                    check <<= 1
                }
                if check != 0 {
                    return nil
                }
                for byte in bytes[(index+1)...] {
                    if byte != 0 {
                        return nil
                    }
                }
            }
            self.network = network
            self.host = 32 - network
        }
    }
}

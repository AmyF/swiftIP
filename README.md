# swiftIP

IP object for swift version

# usage

```swift
let ipv4: IPv4 = IPv4(from: "192.0.2.235")! // IPv4(from: [192,0,2,235])!
let ipv6: IPv6 = ipv4.toIPv6()!

ip.string() // "192.0.2.235"
ip.string(formatter: .dotHexadecimal) // "0xC0.0x00.0x02.0xEB"

ip.isEqual(to: otherIP) // true

ip.isLoopback // false
ip.isGlobalUnicast //
ip.isUnspecified //

ip.defaultMask() // IPMask?

ip.masking(with: mask) // IP?

```
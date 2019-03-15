# unkoip

IP address for swift version

# usage

```swift
import unkoip

let ipv4: IPv4 = IPv4(string: "192.0.2.235")! // IPv4(bytes: [192,0,2,235])
ipv4.toIPv6() // IPv6?
let ipv6: IPv6 = IPv6(string: "::")! // IPv6.zero

// format string
ip.string() // "192.0.2.235"
ip.string(formatter: .dotHexadecimal) // "0xC0.0x00.0x02.0xEB"

ip.isEqual(to: otherIP) // true

ip.isLoopback // false
ip.isGlobalUnicast //
ip.isUnspecified //

// IP Mask
let mask = IPMask(ipv4: 24)! // [255,255,255,0]

ip.defaultMask() // IPMask? class a/b/c mask

ip.masking(with: mask) // IP?

```

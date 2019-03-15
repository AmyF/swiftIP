# unkoip

IP address for swift version

# installation

## Swift Package Manger

```swift
dependencies: [
	.package(url: "https://github.com/AmyF/swiftIP", from: "0.0.1"),
]

targets: [
  .target(
    name: "your project name",
    dependencies: ["unkoip"]),
]
```

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

ipv4.defaultMask() // IPMask class a/b/c mask

ip.masking(with: mask) // IP?

```

import AppKit

let outputPath = CommandLine.arguments.dropFirst().first ?? "WarrantyBox/Assets.xcassets/AppIcon.appiconset/icon_1024.png"
let outputURL = URL(fileURLWithPath: outputPath)

let size = CGSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()

let rect = CGRect(origin: .zero, size: size)
let cornerRadius: CGFloat = 224

let clipPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
clipPath.addClip()

let background = NSGradient(colors: [
    NSColor(calibratedRed: 0.96, green: 0.98, blue: 1.00, alpha: 1.0),
    NSColor(calibratedRed: 0.83, green: 0.92, blue: 0.99, alpha: 1.0)
])!
background.draw(in: rect, angle: -90)

NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.55).setFill()
NSBezierPath(ovalIn: CGRect(x: -80, y: 700, width: 500, height: 280)).fill()
NSBezierPath(ovalIn: CGRect(x: 610, y: 120, width: 340, height: 260)).fill()

let cardRect = CGRect(x: 168, y: 172, width: 688, height: 680)
let cardShadow = NSShadow()
cardShadow.shadowColor = NSColor(calibratedWhite: 0.1, alpha: 0.12)
cardShadow.shadowBlurRadius = 36
cardShadow.shadowOffset = CGSize(width: 0, height: -12)
cardShadow.set()
NSColor.white.setFill()
NSBezierPath(roundedRect: cardRect, xRadius: 140, yRadius: 140).fill()

NSGraphicsContext.current?.restoreGraphicsState()
image.lockFocus()
clipPath.addClip()

let accentOrange = NSColor(calibratedRed: 1.0, green: 0.62, blue: 0.26, alpha: 1.0)
let accentGreen = NSColor(calibratedRed: 0.18, green: 0.73, blue: 0.51, alpha: 1.0)
let stroke = NSColor(calibratedRed: 0.15, green: 0.23, blue: 0.33, alpha: 1.0)
let softBlue = NSColor(calibratedRed: 0.87, green: 0.94, blue: 1.0, alpha: 1.0)

softBlue.setFill()
NSBezierPath(roundedRect: CGRect(x: 222, y: 232, width: 580, height: 520), xRadius: 110, yRadius: 110).fill()

let boxFront = NSBezierPath()
boxFront.move(to: CGPoint(x: 344, y: 344))
boxFront.line(to: CGPoint(x: 344, y: 594))
boxFront.line(to: CGPoint(x: 512, y: 680))
boxFront.line(to: CGPoint(x: 680, y: 594))
boxFront.line(to: CGPoint(x: 680, y: 344))
boxFront.line(to: CGPoint(x: 512, y: 258))
boxFront.close()
NSColor.white.setFill()
boxFront.fill()
stroke.setStroke()
boxFront.lineWidth = 28
boxFront.lineJoinStyle = .round
boxFront.stroke()

let lidLeft = NSBezierPath()
lidLeft.move(to: CGPoint(x: 344, y: 594))
lidLeft.line(to: CGPoint(x: 512, y: 510))
lidLeft.line(to: CGPoint(x: 512, y: 258))
lidLeft
    .line(to: CGPoint(x: 344, y: 344))
lidLeft.close()
NSColor(calibratedRed: 0.95, green: 0.97, blue: 1.0, alpha: 1.0).setFill()
lidLeft.fill()
stroke.setStroke()
lidLeft.lineWidth = 24
lidLeft.lineJoinStyle = .round
lidLeft.stroke()

let receipt = NSBezierPath(roundedRect: CGRect(x: 410, y: 452, width: 228, height: 226), xRadius: 32, yRadius: 32)
NSColor.white.setFill()
receipt.fill()
stroke.setStroke()
receipt.lineWidth = 22
receipt.stroke()

accentOrange.setFill()
NSBezierPath(roundedRect: CGRect(x: 442, y: 600, width: 164, height: 28), xRadius: 14, yRadius: 14).fill()
NSBezierPath(roundedRect: CGRect(x: 442, y: 548, width: 136, height: 22), xRadius: 11, yRadius: 11).fill()

let shield = NSBezierPath()
shield.move(to: CGPoint(x: 630, y: 324))
shield.curve(to: CGPoint(x: 738, y: 358), controlPoint1: CGPoint(x: 674, y: 324), controlPoint2: CGPoint(x: 716, y: 334))
shield.curve(to: CGPoint(x: 702, y: 512), controlPoint1: CGPoint(x: 742, y: 418), controlPoint2: CGPoint(x: 728, y: 476))
shield.curve(to: CGPoint(x: 630, y: 566), controlPoint1: CGPoint(x: 686, y: 534), controlPoint2: CGPoint(x: 658, y: 556))
shield.curve(to: CGPoint(x: 558, y: 512), controlPoint1: CGPoint(x: 602, y: 556), controlPoint2: CGPoint(x: 574, y: 534))
shield.curve(to: CGPoint(x: 522, y: 358), controlPoint1: CGPoint(x: 532, y: 476), controlPoint2: CGPoint(x: 518, y: 418))
shield.curve(to: CGPoint(x: 630, y: 324), controlPoint1: CGPoint(x: 544, y: 334), controlPoint2: CGPoint(x: 586, y: 324))
shield.close()
accentGreen.setFill()
shield.fill()

let check = NSBezierPath()
check.move(to: CGPoint(x: 588, y: 448))
check.line(to: CGPoint(x: 620, y: 412))
check.line(to: CGPoint(x: 676, y: 470))
check.lineCapStyle = .round
check.lineJoinStyle = .round
NSColor.white.setStroke()
check.lineWidth = 24
check.stroke()

image.unlockFocus()

guard
    let tiff = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiff),
    let pngData = bitmap.representation(using: .png, properties: [:])
else {
    fputs("Failed to generate PNG data\n", stderr)
    exit(1)
}

try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
try pngData.write(to: outputURL)
print("Wrote \(outputURL.path)")

import JSON

// Base Size 1040, 700, 460, 300, 240

public enum ImagemapBaseSize: Int {
    case length1040 = 1040
    case length700  = 700
    case length460  = 460
    case length300  = 300
    case lenght240  = 240

    public var asJSON: JSON {
        return JSON.infer(rawValue)
    }
}

public enum ImagemapActionType: String{
    case uri = "uri"
    case message = "message"

    public var asJSON: JSON {
        return JSON.infer(rawValue)
    }
}

public struct Bounds {
    let x: Int
    let y: Int
    let width: Int
    let height: Int
    
    public init(x: Int = 0, y: Int = 0, width: Int = 1040, height: Int = 1040) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    private var array: [Int] {
        return [x, y, width, height]
    }
    
    public var asJSON: JSON {
        return JSON.infer([
            "x": x.asJSON,
            "y": y.asJSON,
            "width": width.asJSON,
            "height": height.asJSON
        ])
    }
}

public typealias ImagemapActionBuilder = (ImagemapMessageBuilder) -> Void

public struct ImagemapAction {
    private let type: ImagemapActionType
    private let text: String?
    private let linkUri: String?
    private let area: Bounds
    
    public init(type: ImagemapActionType = .message, text: String, area: Bounds) {
        self.type = type
        self.text = text
        self.linkUri = nil
        self.area = area
    }

    public init(type: ImagemapActionType = .uri, linkUri: String, area: Bounds) {
        self.type = type
        self.text = nil
        self.linkUri = linkUri
        self.area = area
    }

    public var asJSON: JSON {
        if let text = text {
            return JSON.infer([
                "type": type.asJSON,
                "text": text.asJSON,
                "area": area.asJSON
            ])
        } else if let linkUri = linkUri {
            return JSON.infer([
                "type": type.asJSON,
                "linkUri": linkUri.asJSON,
                "area": area.asJSON
            ])
        } else {
            return JSON.init(nilLiteral: ())
        }
    }
}

public class ImagemapMessageBuilder: Builder {
    private struct BaseSize {
        let width: ImagemapBaseSize
        let height: ImagemapBaseSize
        var asJSON: JSON {
            return JSON.infer([
                "width": width.asJSON,
                "height": height.asJSON
            ])
        }
    }
    private let baseUrl: String
    private let altText: String
    private let baseSize: BaseSize
    
    private var actions = [ImagemapAction]()
    
    public init(baseUrl: String,
                altText: String,
                width: ImagemapBaseSize = .length1040,
                height: ImagemapBaseSize = .length1040,
                actionBuilder: ImagemapActionBuilder) {
        self.baseUrl = baseUrl
        self.altText = altText
        self.baseSize = BaseSize(width: width, height: height)
        actionBuilder(self)
    }
    
    public func addAction(action: ImagemapAction) {
        actions.append(action)
    }

    public func build() -> JSON? {
        return JSON.infer([
            "type": MessageType.imagemap.asJSON,
            "baseUrl": baseUrl.asJSON,
            "altText": altText.asJSON,
            "baseSize": baseSize.asJSON,
            "actions": JSON.infer(actions.flatMap { $0.asJSON })
        ])
    }
}
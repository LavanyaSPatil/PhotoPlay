
import Foundation
struct Photos : Codable {
	let id : Int?
	let width : Int?
	let height : Int?
	let url : String?
	let photographer : String?
	let photographer_url : String?
	let photographer_id : Int?
	let avg_color : String?
	let src : Src?
    var liked : Bool?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case width = "width"
		case height = "height"
		case url = "url"
		case photographer = "photographer"
		case photographer_url = "photographer_url"
		case photographer_id = "photographer_id"
		case avg_color = "avg_color"
		case src = "src"
		case liked = "liked"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		width = try values.decodeIfPresent(Int.self, forKey: .width)
		height = try values.decodeIfPresent(Int.self, forKey: .height)
		url = try values.decodeIfPresent(String.self, forKey: .url)
		photographer = try values.decodeIfPresent(String.self, forKey: .photographer)
		photographer_url = try values.decodeIfPresent(String.self, forKey: .photographer_url)
		photographer_id = try values.decodeIfPresent(Int.self, forKey: .photographer_id)
		avg_color = try values.decodeIfPresent(String.self, forKey: .avg_color)
		src = try values.decodeIfPresent(Src.self, forKey: .src)
		liked = try values.decodeIfPresent(Bool.self, forKey: .liked)
	}

}

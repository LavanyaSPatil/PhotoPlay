

import Foundation
struct Video_files : Codable {
	let id : Int?
	let quality : String?
	let file_type : String?
	let width : Int?
	let height : Int?
	let link : String?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case quality = "quality"
		case file_type = "file_type"
		case width = "width"
		case height = "height"
		case link = "link"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		quality = try values.decodeIfPresent(String.self, forKey: .quality)
		file_type = try values.decodeIfPresent(String.self, forKey: .file_type)
		width = try values.decodeIfPresent(Int.self, forKey: .width)
		height = try values.decodeIfPresent(Int.self, forKey: .height)
		link = try values.decodeIfPresent(String.self, forKey: .link)
	}

}

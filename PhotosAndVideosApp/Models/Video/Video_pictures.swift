

import Foundation
struct Video_pictures : Codable {
	let id : Int?
	let picture : String?
	let nr : Int?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case picture = "picture"
		case nr = "nr"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		picture = try values.decodeIfPresent(String.self, forKey: .picture)
		nr = try values.decodeIfPresent(Int.self, forKey: .nr)
	}

}

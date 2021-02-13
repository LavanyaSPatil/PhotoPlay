

import Foundation
struct PhotosBaseJson : Codable {
	let page : Int?
	let per_page : Int?
	let photos : [Photos]?
	let total_results : Int?
	let next_page : String?

	enum CodingKeys: String, CodingKey {

		case page = "page"
		case per_page = "per_page"
		case photos = "photos"
		case total_results = "total_results"
		case next_page = "next_page"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		page = try values.decodeIfPresent(Int.self, forKey: .page)
		per_page = try values.decodeIfPresent(Int.self, forKey: .per_page)
		photos = try values.decodeIfPresent([Photos].self, forKey: .photos)
		total_results = try values.decodeIfPresent(Int.self, forKey: .total_results)
		next_page = try values.decodeIfPresent(String.self, forKey: .next_page)
	}

}

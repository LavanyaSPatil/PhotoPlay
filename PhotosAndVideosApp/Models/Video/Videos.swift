

import Foundation
struct Videos : Codable {
	let full_res : String?
	let tags : [String]?
	let id : Int?
	let width : Int?
	let height : Int?
	let url : String?
	let image : String?
	let duration : Int?
	let avg_color : String?
	let user : User?
	let video_files : [Video_files]?
	let video_pictures : [Video_pictures]?
    var liked : Bool? = false
	
    enum CodingKeys: String, CodingKey {

		case full_res = "full_res"
		case tags = "tags"
		case id = "id"
		case width = "width"
		case height = "height"
		case url = "url"
		case image = "image"
		case duration = "duration"
		case avg_color = "avg_color"
		case user = "user"
		case video_files = "video_files"
		case video_pictures = "video_pictures"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		full_res = try values.decodeIfPresent(String.self, forKey: .full_res)
		tags = try values.decodeIfPresent([String].self, forKey: .tags)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		width = try values.decodeIfPresent(Int.self, forKey: .width)
		height = try values.decodeIfPresent(Int.self, forKey: .height)
		url = try values.decodeIfPresent(String.self, forKey: .url)
		image = try values.decodeIfPresent(String.self, forKey: .image)
		duration = try values.decodeIfPresent(Int.self, forKey: .duration)
		avg_color = try values.decodeIfPresent(String.self, forKey: .avg_color)
		user = try values.decodeIfPresent(User.self, forKey: .user)
		video_files = try values.decodeIfPresent([Video_files].self, forKey: .video_files)
		video_pictures = try values.decodeIfPresent([Video_pictures].self, forKey: .video_pictures)
	}

}

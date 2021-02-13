
import Foundation

struct RootClassPOST: Codable {
    let data: DatumPOST?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case data
        case status
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decode(DatumPOST.self, forKey: .data)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }
}
struct DatumPOST: Codable {
    let age: String?
    let id: Int?
    let name: String?
    let salary: String?

    enum CodingKeys: String, CodingKey {
        case age
        case id
        case name
        case salary
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        age = try values.decodeIfPresent(String.self, forKey: .age)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        salary = try values.decodeIfPresent(String.self, forKey: .salary)
    }
}
struct RootClass: Codable {
    let data: [DatumGet]?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case data
        case status
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([DatumGet].self, forKey: .data)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }
}

struct DatumGet: Codable {
    let employeeAge: String?
    let employeeName: String?
    let employeeSalary: String?
    let id: String?
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case employeeAge = "employee_age"
        case employeeName = "employee_name"
        case employeeSalary = "employee_salary"
        case id = "id"
        case profileImage = "profile_image"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        employeeAge = try values.decodeIfPresent(String.self, forKey: .employeeAge)
        employeeName = try values.decodeIfPresent(String.self, forKey: .employeeName)
        employeeSalary = try values.decodeIfPresent(String.self, forKey: .employeeSalary)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        profileImage = try values.decodeIfPresent(String.self, forKey: .profileImage)
    }
}

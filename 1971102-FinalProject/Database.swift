//
//  Database.swift
//  ch11-1971102-JoungYoungUk-CityFirebase
//
//  Created by younguk on 2024/05/07.
//
enum DbAction{
    case add, detete, modify // 데이터베이스 변경의 유형
}
protocol Database{
    // 생성자, 데이터베이스에 변경이 생기면 parentNotification를 호출하여 부모에게 알림
    init(parentNotification: (([String: Any]?, DbAction?) -> Void)? )

    // from ~ toD 사이의 데이터을 읽어 parentNotification를 호출하여 부모에게 알림
    func setQuery(from: Any, to: Any)

    // 데이터베이스에 plan을 변경하고 parentNotification를 호출하여 부모에게 알림
    func saveChange(key: String, object: [String: Any], action: DbAction)
}


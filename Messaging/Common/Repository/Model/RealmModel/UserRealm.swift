import RealmSwift

class UserRealm: Object {
    // The database to designed to have only insert(override: true)
    @objc dynamic var id: String = "default-id"
    @objc dynamic var userId: String = ""
    @objc dynamic var userName: String = ""
    @objc dynamic var avaUrl: String = ""
    @objc dynamic var isLoggedIn: Bool = true
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func from(_ user: User, loggedIn: Bool) -> UserRealm {
        let res = UserRealm()
        res.userId = user.userId
        res.userName = user.userName
        res.isLoggedIn = loggedIn
        res.avaUrl = user.userAvatarUrl
            ?? UrlBuilder.buildUrl(forUserId: res.userId)
        return res
    }
    
    func convert() -> User {
        return User(userId: self.userId,
                    userName: userName,
                    userAvatarUrl: avaUrl)
    }
}

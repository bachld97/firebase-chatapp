import RxSwift

class UserLocalSourceImpl : UserLocalSource {
    var user: User?

    func persistUser(user: User) -> Observable<Bool> {
        self.user = user
        return Observable.just(true)
    }
    
    func getUser() -> Observable<User?> {
        if user != nil {
            return Observable.just(user!)
        }
        
        // TODO: Read database or whatever here 
        let sampleUrl = "https://3.img-dpreview.com/files/p/E~TS590x0~articles/8692662059/8283897908.jpeg"
        return Observable.just(User(userId: "bachld10832", userName: "Le Duy Bach", userAvatarUrl: sampleUrl))
    }
    
    func removeUser() -> Observable<Bool> {
        user = nil
        return Observable.just(true)
    }
}

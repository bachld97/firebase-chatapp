//
//  ProfileViewController.swift
//  Messaging
import RxSwift
import UIKit

class SeeProfileVC : BaseVC , ViewFor,
                UIImagePickerControllerDelegate,
                UINavigationControllerDelegate {
    private var imageTask: URLSessionTask?
    
    var viewModel: SeeProfileViewModel!
    private let disposeBag = DisposeBag()
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var avaImageView: UIImageView!
    
    @IBOutlet weak var goChangePassButton: UIButton!
    typealias ViewModelType = SeeProfileViewModel
    let tapGesture = UITapGestureRecognizer()
    
    
    class func instance() -> UIViewController {
        return SeeProfileVC()
    }
    
    init() {
        super.init(nibName: "SeeProfileVC", bundle: nil)
        self.viewModel = SeeProfileViewModel(displayLogic: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.viewModel = SeeProfileViewModel(displayLogic: self)
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Profile"
        
        
        let logOutImg = UIImage(named: "ic_logout")?.withRenderingMode(.alwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: logOutImg,
            style: .plain,
            target: nil,
            action: nil)
        
        super.viewDidLoad()
        avaImageView.isUserInteractionEnabled = true
        avaImageView.addGestureRecognizer(tapGesture)
    }
    
    override func bindViewModel() {
        let viewWillAppear = self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        
        let input = SeeProfileViewModel.Input(
            trigger: viewWillAppear,
            // reloadTrigger:,
            logoutTrigger: self.navigationItem.rightBarButtonItem!.rx.tap.asDriver(),
            changePassTrigger: goChangePassButton.rx.tap.asDriver(),
            showPickerTrigger: tapGesture.rx.event.asDriver())

        let output = viewModel.transform(input: input)
        
        output.error
            .do(onNext: { [unowned self] (error) in
                self.handleError(e: error)
            })
            .drive()
            .disposed(by: self.disposeBag)
    }
    
    @objc func startLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            handleError(e: SimpleError(message: "The image is corrupted"))
            dismiss(animated: true, completion: nil)
            return
        }
        
        avaImageView.image = selectedImage
        print("Hello")
        // TODO: PublishSubject<Image> --> Send to server
        dismiss(animated: true, completion: nil)
    }
    
    @objc func startCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.allowsEditing = true
            picker.delegate = self
            self.present(picker, animated: true)
        } else {
            handleError(e: SimpleError(message: "Camera not exists"))
        }
    }
}


extension SeeProfileVC : SeeProfileDisplayLogic {

    func goChangePass() {
        let vc = ChangePassVC.instance()
        self.present(vc, animated: true, completion: nil)
        // self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func display(user: User) {
        self.usernameLabel.text = user.userName
        self.userIdLabel.text = user.userId
        
        guard let avaUrl = user.userAvatarUrl else {
            return
        }
        
        if imageTask == nil {
            imageTask = ImageLoader.load(urlString: avaUrl, into: self.avaImageView)
        } else {
            imageTask?.cancel()
        }
    }
    
    func logout() {
        logoutNormally()
    }
    
    func showPicker() {
        let alert = UIAlertController(
            title: "Update profile picture",
            message: "Choose picture from gallery or capture with camera",
            preferredStyle: .actionSheet)
        
        alert.addAction(
            UIAlertAction(title: "Gallery", style: .default, handler: { [unowned self] (_) in
                self.startLibrary()
            }))
        
        alert.addAction(
            UIAlertAction(title: "Camera", style: .default, handler: { [unowned self] (_) in
                self.startCamera()
            }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true)
    }
}

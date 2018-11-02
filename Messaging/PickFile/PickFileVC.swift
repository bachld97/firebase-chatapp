import UIKit
import MobileCoreServices

protocol PickFileDelegate : class {
    func onFilePickFail()
    func onFilePick(url: URL)
}


class PickFileVC: UIViewController {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func instance(delegate: PickFileDelegate) -> UIViewController {
        return PickFileVC(delegate: delegate)
    }
    
    private var doShow = true
    private weak var delegate: PickFileDelegate?
    
    init(delegate: PickFileDelegate) {
        super.init(nibName: "PickFileVC", bundle: nil)
        self.delegate = delegate
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if doShow {
            let documentPicker = UIDocumentPickerViewController(
                documentTypes: [String(kUTTypeText),String(kUTTypeContent),
                                String(kUTTypeItem),String(kUTTypeData)],
                in: .import)
            documentPicker.delegate = self
            self.present(documentPicker, animated: true)
            doShow = false
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
}

extension PickFileVC : UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileUrl = urls.first else {
            self.delegate?.onFilePickFail()
            return
        }
        
        self.delegate?.onFilePick(url: fileUrl)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}

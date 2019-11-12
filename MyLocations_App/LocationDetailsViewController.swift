import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()


class LocationDetailsViewController : UITableViewController {
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark : CLPlacemark?
    var categoryName = "No Category"
    var managedObjectContext = appDelegate.persistentContainer.viewContext
    let context = appDelegate.managedObjectContext
    // do something with the context
    var date = Date()
    var locationToEdit: Location? {
        didSet{   //performed whenever you put a new value into that variable
            if let location = locationToEdit {
                descriptionText = location.locationDescription!
                categoryName = location.category!
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    var descriptionText = ""
    var image: UIImage?
    var observer: Any!
    
    
    
    @IBOutlet weak private var descriptionTextView: UITextView!
    @IBOutlet weak private var categoryLabel: UILabel!
    @IBOutlet weak private var latitudeLabel: UILabel!
    @IBOutlet weak private var longitudeLabel: UILabel!
    @IBOutlet weak private var addressLabel: UILabel!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    let geocoder = CLGeocoder()
    func findPlace(name: String,completion: @escaping(CLPlacemark?) -> Void) {
        geocoder.geocodeAddressString(name) { placemarks, error in
            
            completion(placemarks?.last)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let location = locationToEdit {
            title = "Edit Location"
        }
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f",
                                    coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f",
                                     coordinate.longitude)
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = format(date: date)
        // Hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        listenForBackgroundNotification()
    }
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        } else if indexPath.section == 1 && indexPath.row == 0 {
            choosePhotoFromLibrary()
            
        }
        tableView.deselectRow(at: indexPath, animated: true)
        pickPhoto()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    
    @IBAction func categoryPickerDidPickCategory(
        _ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    
    // MARK:- Actions
    @IBAction func done() {
        let hudView = HudView.hud(inView: navigationController!.view,
                                  animated: true)
        let location : Location
        if let temp = locationToEdit{
            hudView.text = "Updated"
            location = temp
        }
        else{
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
        }
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        findPlace(name: categoryName) { (placemark) in
            location.placemark = placemark
            
            // 3
            do {
                try location.managedObjectContext?.save()
                //            try managedObjectContext.save()
                afterDelay(0.6) {
                    hudView.hide()
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                // 4
                //fatalError("Error: \(error)")
                fatalCoreDataError(error)
            }
            
            
        }
        
    }
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        print("*** deinit \(self)")
        NotificationCenter.default.removeObserver(observer)
    }
    
    
}

extension LocationDetailsViewController {
    // MARK:- Helper Methods
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let s = placemark.subThoroughfare {
            text += s + " "
        }
        if let s = placemark.thoroughfare {
            text += s + ", "
        }
        if let s = placemark.locality {
            text += s + ", "
        }
        if let s = placemark.administrativeArea {
            text += s + " "
        }
        if let s = placemark.postalCode {
            text += s + ", "
        }
        if let s = placemark.country {
            text += s
        }
        return text
    }
    
    
    // MARK comment, for organizational purposes
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    @objc func hideKeyboard(_ gestureRecognizer:
        UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 0
            && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto() {
        if true || UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil,
                                      preferredStyle: .actionSheet)
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel,
                                      handler: nil)
        alert.addAction(actCancel)
        let actPhoto = UIAlertAction(title: "Take Photo",
                                     style: .default, handler: { _ in
                                        self.takePhotoWithCamera()
        })
        alert.addAction(actPhoto)
        let actLibrary = UIAlertAction(title: "Choose From Library",
                                       style: .default, handler: { _ in
                                        self.choosePhotoFromLibrary()
        })
        alert.addAction(actLibrary)
        present(alert, animated: true, completion: nil)
    }
    
    func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        addPhotoLabel.text = ""
        // Add the following lines
        imageHeight.constant = 260
        tableView.reloadData()
    }
    
    
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil, queue: OperationQueue.main) { [weak self] _ in
                
                if let weakSelf = self {
                    if weakSelf.presentedViewController != nil {
                        weakSelf.dismiss(animated: false, completion: nil)
                    }
                    weakSelf.descriptionTextView.resignFirstResponder()
                }
        }
    }
    
    
}

extension LocationDetailsViewController:
    UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    // MARK:- Image Helper Methods
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK:- Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info:
        [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.editedImage]
            as? UIImage
        if let theImage = image {
            show(image: theImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker:
        UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

/**
 This file is part of the SFFocusViewLayout package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import UIKit

//protocol CollectionViewCellRender {
//
//    func setTitle(title: String)
//    func setDescription(description: String)
//    func setBackgroundImage(image: UIImage)
//}

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var offererBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    var parent:QuestionVC!
    var offerer:UserModel?
    
    @IBAction func showAsker(_ sender: AnyObject) {
        offerer?.loadWallImg()
        parent.showUser(user: offerer)
    }
    
    @IBAction func likeAction(_ sender: AnyObject) {
        likeBtn.setImage(img: #imageLiteral(resourceName: "like_filled"), color: pinkColor)
        parent.collectionView.isUserInteractionEnabled = false
        let optRef = parent.currQuestion?.qRef.child("options").child(option.oDescription)
        optRef?.child("val").observeSingleEvent(of: .value, with: { (snapshot) in
            let val = (snapshot.value as! Int) + 1
            optRef?.child("val").setValue(val)
        })
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                self.parent.nextQuestion()
            }
        } else {
            _ = Timer(timeInterval: 1, target: self, selector: #selector(self.parent.nextQuestion), userInfo: nil, repeats: false)
        }
    }
    
    func setProfile(){
        offererBtn.tintColor = .clear
        if let img = offerer?.profileImg{
            offererBtn.setBackgroundImage(img, for: [])
        }
        else if let uid = offerer?.uid{
            NotificationCenter.default.addObserver(self, selector: #selector(setProfile), name: NSNotification.Name(uid + "profile"), object: nil)
        }
        offererBtn.imageView?.contentMode = .scaleAspectFill
    }
    
    var option:OptionModel!{
        didSet{
            descriptionTextView.text = option.oDescription
            titleLabel.text = "Like: \(option.oVal)"
            backgroundImageView.backgroundColor = getRandomColor()
            if let uid = option.oOfferBy{
                offerer = UserModel.getUser(uid: uid, getProfile: true)
                setProfile()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        offererBtn.board(radius: 18, width: 1, color: .white)
        board(radius: 3, width: 1, color: themeColor)
        likeBtn.setImage(img: #imageLiteral(resourceName: "like"), color: pinkColor)
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

//        let featuredHeight: CGFloat = Constant.featuredHeight
//        let standardHeight: CGFloat = Constant.standardHegiht
//
//        let delta = 1 - (featuredHeight - frame.height) / (featuredHeight - standardHeight)
//
//        let minAlpha: CGFloat = Constant.minAlpha
//        let maxAlpha: CGFloat = Constant.maxAlpha
//
//        let alpha = maxAlpha - (delta * (maxAlpha - minAlpha))
//        overlayView.alpha = alpha
//
//        let scale = max(delta, 0.5)
//        titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
//
//        descriptionTextView.alpha = delta
        
    }
}

//extension CollectionViewCell: CollectionViewCellRender {
//
//    func setTitle(title: String) {
//        self.titleLabel.text = title
//    }
//
//    func setDescription(description: String) {
//        self.descriptionTextView.text = description
//    }
//
//    func setBackgroundImage(image: UIImage) {
//        self.backgroundImageView.image = image
//    }
//
//}

extension CollectionViewCell {
    struct Constant {
        static let featuredHeight: CGFloat = 172
        static let standardHegiht: CGFloat = 52

        static let minAlpha: CGFloat = 0.3
        static let maxAlpha: CGFloat = 0.75
    }
}

extension CollectionViewCell : NibLoadableView { }

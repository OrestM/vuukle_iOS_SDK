

import UIKit

protocol EmoticonCellDelegate {
  
  func firstEmoticonButtonPressed(_ tableCell : EmoticonCell ,firstEmoticonButtonPressed firstEmoticonButton : AnyObject )
  func secondEmoticonButtonPressed(_ tableCell : EmoticonCell ,secondEmoticonButtonPressed secondEmoticonButton : AnyObject )
  func thirdEmoticonButtonPressed(_ tableCell : EmoticonCell ,thirdEmoticonButtonPressed thirdEmoticonButton : AnyObject )
  func fourthEmoticonButtonPressed(_ tableCell : EmoticonCell ,fourthEmoticonButtonPressed fourthEmoticonButton : AnyObject )
  func fifthEmoticonButtonPressed(_ tableCell : EmoticonCell ,fifthEmoticonButtonPressed fifthEmoticonButton : AnyObject )
  func sixthEmoticonButtonPressed(_ tableCell : EmoticonCell ,sixthEmoticonButtonPressed sixthEmoticonButton : AnyObject )
}

class EmoticonCell: UITableViewCell ,UIWebViewDelegate {
  
  var delegate : EmoticonCellDelegate?
  let defaults : UserDefaults = UserDefaults.standard
  
  @IBOutlet weak var firstEmoticonImage: UIImageView!
  @IBOutlet weak var secondEmoticonImage: UIImageView!
  @IBOutlet weak var thirdEmoticonImage: UIImageView!
  @IBOutlet weak var fourthEmoticonImage: UIImageView!
  @IBOutlet weak var fifthEmoticonImage: UIImageView!
  @IBOutlet weak var sixthEmoticonImage: UIImageView!
  
  @IBOutlet weak var firstEmoticonLabel: UILabel!
  @IBOutlet weak var secondEmoticonLabel: UILabel!
  @IBOutlet weak var thirdEmoticonLabel: UILabel!
  @IBOutlet weak var fourthEmoticonLabel: UILabel!
  @IBOutlet weak var fifthEmoticonLabel: UILabel!
  @IBOutlet weak var sixthEmoticonLabel: UILabel!
  
  
  @IBOutlet weak var countFirstEmoticonLabel: UILabel!
  @IBOutlet weak var countSecondEmoticonLabel: UILabel!
  @IBOutlet weak var countThirdEmoticonLabel: UILabel!
  @IBOutlet weak var countFourthEmoticonLabel: UILabel!
  @IBOutlet weak var countFifthEmoticonLabel: UILabel!
  @IBOutlet weak var countSixthEmoticonLabel: UILabel!
  
  @IBAction func firstEmoticonButton(_ sender: AnyObject) {
    
    self.delegate?.firstEmoticonButtonPressed(self, firstEmoticonButtonPressed: sender)
  }
  @IBAction func secondEmoticonButton(_ sender: AnyObject) {
    self.delegate?.secondEmoticonButtonPressed(self, secondEmoticonButtonPressed: sender)
  }
  @IBAction func thirdEmoticonButton(_ sender: AnyObject) {
    self.delegate?.thirdEmoticonButtonPressed(self, thirdEmoticonButtonPressed: sender)
  }
  @IBAction func fourthEmoticonButton(_ sender: AnyObject) {
    self.delegate?.fourthEmoticonButtonPressed(self, fourthEmoticonButtonPressed: sender)
  }
  @IBAction func fifthEmoticonButton(_ sender: AnyObject) {
    self.delegate?.fifthEmoticonButtonPressed(self, fifthEmoticonButtonPressed: sender)
  }
  @IBAction func sixthEmoticonButton(_ sender: AnyObject) {
    self.delegate?.sixthEmoticonButtonPressed(self, sixthEmoticonButtonPressed: sender)
  }
  
  
  @IBOutlet weak var thanksText: UILabel!
  @IBOutlet weak var viewHeight: NSLayoutConstraint!
  @IBOutlet weak var titleHeight: NSLayoutConstraint!
  @IBOutlet weak var firstEmoticonImageHeight: NSLayoutConstraint!
  @IBOutlet weak var secondEmoticonImageHeight: NSLayoutConstraint!
  @IBOutlet weak var thirdEmoticonImageHeight: NSLayoutConstraint!
  @IBOutlet weak var fourthEmoticonImageHeight: NSLayoutConstraint!
  @IBOutlet weak var fifthEmoticonImageHeight: NSLayoutConstraint!
  @IBOutlet weak var sixthEmoticonImageHeight: NSLayoutConstraint!
  
  @IBOutlet weak var firstCountVotesLabelHeight: NSLayoutConstraint!
  @IBOutlet weak var secondCountVotesLabelHeight: NSLayoutConstraint!
  @IBOutlet weak var thirdCountVotesLabelHeight: NSLayoutConstraint!
  @IBOutlet weak var fourthCountVotesLabelHeight: NSLayoutConstraint!
  @IBOutlet weak var fifthCountVotesLabelHeight: NSLayoutConstraint!
  @IBOutlet weak var sixtCountVotesLabelHeight: NSLayoutConstraint!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    let lKey = "\(Global.article_id)votedEmotion"
    let value = UserDefaults.standard.integer(forKey: lKey)
    
    switch value {
    case 1:
      firstEmoticonLabel.textColor = UIColor.red
      countFirstEmoticonLabel.textColor = UIColor.red
    case 2:
      secondEmoticonLabel.textColor = UIColor.red
      countSecondEmoticonLabel.textColor = UIColor.red
    case 3:
      thirdEmoticonLabel.textColor = UIColor.red
      countThirdEmoticonLabel.textColor = UIColor.red
    case 4:
      fourthEmoticonLabel.textColor = UIColor.red
      countFourthEmoticonLabel.textColor = UIColor.red
    case 5:
      fifthEmoticonLabel.textColor = UIColor.red
      countFifthEmoticonLabel.textColor = UIColor.red
    case 6:
      sixthEmoticonLabel.textColor = UIColor.red
      countSixthEmoticonLabel.textColor = UIColor.red
    default:
      break
    }
    
  }
  
  override func prepareForReuse() {
    
    let lKey = "\(Global.article_id)votedEmotion"
    let value = UserDefaults.standard.integer(forKey: lKey)
    
    switch value {
    case 1:
      firstEmoticonLabel.textColor = UIColor.red
      countFirstEmoticonLabel.textColor = UIColor.red
    case 2:
      secondEmoticonLabel.textColor = UIColor.red
      countSecondEmoticonLabel.textColor = UIColor.red
    case 3:
      thirdEmoticonLabel.textColor = UIColor.red
      countThirdEmoticonLabel.textColor = UIColor.red
    case 4:
      fourthEmoticonLabel.textColor = UIColor.red
      countFourthEmoticonLabel.textColor = UIColor.red
    case 5:
      fifthEmoticonLabel.textColor = UIColor.red
      countFifthEmoticonLabel.textColor = UIColor.red
    case 6:
      sixthEmoticonLabel.textColor = UIColor.red
      countSixthEmoticonLabel.textColor = UIColor.red
    default:
      break
    }
    
  }
  
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func recountPercentage() {
    let sum = Global.firstEmoticonVotesCount + Global.secondEmoticonVotesCount + Global.thirdEmoticonVotesCount + Global.fourthEmoticonVotesCount + Global.fifthEmoticonVotesCount + Global.sixthEmoticonVotesCount
    if sum != 0 {
      firstEmoticonLabel.text = "\(getPercents(arg: Global.firstEmoticonVotesCount, sum: sum))%"
      secondEmoticonLabel.text = "\(getPercents(arg: Global.secondEmoticonVotesCount, sum: sum))%"
      thirdEmoticonLabel.text = "\(getPercents(arg: Global.thirdEmoticonVotesCount, sum: sum))%"
      fourthEmoticonLabel.text = "\(getPercents(arg: Global.fourthEmoticonVotesCount, sum: sum))%"
      fifthEmoticonLabel.text = "\(getPercents(arg: Global.fifthEmoticonVotesCount, sum: sum))%"
      sixthEmoticonLabel.text = "\(getPercents(arg: Global.sixthEmoticonVotesCount, sum: sum))%"
    }
  }
  
  func getPercents(arg: Int, sum: Int) -> Int{
    return Int((arg * 100) / sum)
  }
}




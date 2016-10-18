

import UIKit
import Alamofire
import Social

class CommentViewController: UIViewController , UITableViewDelegate , UITableViewDataSource ,  UITextFieldDelegate , AddCommentCellDelegate , CommentCellDelegate ,AddLoadMoreCellDelegate , EmoticonCellDelegate , UITextViewDelegate{
    
    static let sharedInstance = Global()
    var arrayObjectsForCell = [AnyObject]()
    var rating = EmoteRating()
    var showRepleiCell = -1
    let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var savedMail = ""
    var savedName = ""
    var inserReplieindex = -1
    var refreshControl:UIRefreshControl!
    var from_count = 0
    var to_count = Global.countLoadCommentsInPagination
    var canLoadmore = true
    var canGetCommentsFeed = true
    var totalComentsCount = 0
    var morePost = true
    var loadReply = true
    var countOthetCell = 3
    var indexOfLastObject = -1
    //Needed to check if reply field is opened
    var lastReplyID = 0
    var replyOpened = false
    
    @IBOutlet public weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Global.sharedInstance.checkAllParameters() == true {
            let bundleCommentCell = NSBundle(forClass: CommentCell.self)
            let bundleAddCommentCell = NSBundle(forClass: CommentCell.self)
            let bundleEmoticonCell = NSBundle(forClass: CommentCell.self)
            let bundleLoadMoreCell = NSBundle(forClass: CommentCell.self)
            
            let nibComment = UINib(nibName: "CommentCell", bundle: bundleCommentCell)
            self.tableView.registerNib(nibComment, forCellReuseIdentifier: "CommentCell")
            
            let nibAdd = UINib(nibName: "AddCommentCell", bundle: bundleAddCommentCell)
            self.tableView.registerNib(nibAdd, forCellReuseIdentifier: "AddCommentCell")
            
            let nibEmoticon = UINib(nibName: "EmoticonCell", bundle: bundleEmoticonCell)
            self.tableView.registerNib(nibEmoticon, forCellReuseIdentifier: "EmoticonCell")
            
            let nibLoadMoreCell = UINib(nibName: "LoadMoreCell", bundle: bundleLoadMoreCell)
            self.tableView.registerNib(nibLoadMoreCell, forCellReuseIdentifier: "LoadMoreCell")
            
            let nibWebViewCell = UINib(nibName: "WebViewCell", bundle: bundleLoadMoreCell)
            self.tableView.registerNib(nibWebViewCell, forCellReuseIdentifier: "WebViewCell")
            
            let nibContentWebViewCell = UINib(nibName: "ContentWebViewCell", bundle: bundleLoadMoreCell)
            self.tableView.registerNib(nibContentWebViewCell, forCellReuseIdentifier: "ContentWebViewCell")
            
            self.tableView.estimatedRowHeight = 180
            
            self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CommentViewController.dismissKeyboard)))
            
            if Global.showRefreshControl == true {
                refreshControl = UIRefreshControl()
                refreshControl!.addTarget(self, action: #selector(refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
                tableView.addSubview(refreshControl)
                refresh(refreshControl!)
            }
            getComments()
            
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                             selector: #selector(CommentViewController.keyboardWillShow(_:)),
                                                             name: UIKeyboardWillShowNotification,
                                                             object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                             selector: #selector(CommentViewController.keyboardWillHide(_:)),
                                                             name: UIKeyboardWillHideNotification,
                                                             object: nil)
            NetworkManager.sharedInstance.getTotalCommentsCount { (totalCount) in
                CellConstructor.sharedInstance.totalComentsCount = totalCount.comments!
                VuukleInfo.totalCommentsCount = totalCount.comments!
                self.tableView.reloadData()
                NetworkManager.sharedInstance.getEmoticonRating { (data) in
                    ParametersConstructor.sharedInstance.setEmoticonCountVotes(data)
                    self.tableView.reloadData()
                }
                if Global.scrolingTableView == false {
                self.tableView.scrollEnabled = false
                self.tableView.alwaysBounceVertical = false
                } else {
                    self.tableView.scrollEnabled = true
                    self.tableView.alwaysBounceVertical = true
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Global.sharedInstance.checkAllParameters() == true {
            return arrayObjectsForCell.count
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let  cell = CellConstructor.sharedInstance.returnCellForRow(arrayObjectsForCell[indexPath.row], tableView: tableView)
        
        switch arrayObjectsForCell[indexPath.row] {
        case is CommentsFeed:
            let  cell : CommentCell = CellConstructor.sharedInstance.returnCellForRow(arrayObjectsForCell[indexPath.row], tableView: tableView) as! CommentCell
            cell.delegate = self
            cell.tag = indexPath.row
            return cell
        case is Emoticon:
            let  cell : EmoticonCell = CellConstructor.sharedInstance.returnCellForRow(arrayObjectsForCell[indexPath.row], tableView: tableView) as! EmoticonCell
            cell.delegate = self
            cell.tag = indexPath.row
            return cell
        case is CommentForm:
            let  cell : AddCommentCell = CellConstructor.sharedInstance.returnCellForRow(arrayObjectsForCell[indexPath.row], tableView: tableView) as! AddCommentCell
            cell.delegate = self
            cell.tag = indexPath.row
            return cell
        case is LoadMore:
            let  cell : LoadMoreCell = CellConstructor.sharedInstance.returnCellForRow(arrayObjectsForCell[indexPath.row], tableView: tableView) as! LoadMoreCell
            cell.delegate = self
            cell.tag = indexPath.row
            return cell
        case is ReplyForm:
            let  cell : AddCommentCell = CellConstructor.sharedInstance.returnCellForRow(arrayObjectsForCell[indexPath.row], tableView: tableView) as! AddCommentCell
            cell.delegate = self
            cell.tag = indexPath.row
            return cell
        default:
            break
        }
        cell.tag = indexPath.row
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //MARK: CommentCellDelegate
    
    func secondShareButtonPressed(tableCell: CommentCell, shareButtonPressed shareButton: AnyObject) {
        shareComment(tableCell.tag, shareTo: "Facebook")
    }
    
    func firstShareButtonPressed(tableCell: CommentCell, shareButtonPressed shareButton: AnyObject) {
        shareComment(tableCell.tag, shareTo: "Twitter")
    }
    
    func showReplyButtonPressed(tableCell: CommentCell, showReplyButtonPressed showReplyButton: AnyObject) {
        var firstLevel = 0
        var secondLevel = 0
        
        if arrayObjectsForCell[tableCell.tag] is CommentsFeed {
            let firstObject = arrayObjectsForCell[tableCell.tag] as! CommentsFeed
            firstLevel = firstObject.level!
        }
        if arrayObjectsForCell[tableCell.tag + 1] is CommentsFeed {
            let secondObject = arrayObjectsForCell[tableCell.tag + 1] as! CommentsFeed
            secondLevel = secondObject.level!
        } else {
            secondLevel = 0
        }
        
        if firstLevel == secondLevel && loadReply == true || firstLevel > secondLevel{
            loadReply = false
            getReplies(tableCell.tag , comment: self.arrayObjectsForCell[tableCell.tag] as! CommentsFeed)
            
        } else if firstLevel < secondLevel {
            removeObjectFromSortedArray(tableCell.tag)
        }
    }
    
    func upvoteButtonPressed(tableCell: CommentCell, upvoteButtonPressed upvoteButton: AnyObject) {
        let commen = arrayObjectsForCell[tableCell.tag] as! CommentsFeed
        
        if  self.defaults.objectForKey("\(commen.comment_id)") as? String == nil || self.defaults.objectForKey("\(commen.comment_id)") as? String == "" {
            
            var mail = ""
            if self.defaults.objectForKey("email") as? String != nil {
                mail = ParametersConstructor.sharedInstance.encodingString(self.defaults.objectForKey("email") as! String)
                let name = ParametersConstructor.sharedInstance.encodingString(commen.name!)
                self.defaults.setObject("\(commen.comment_id)", forKey: "\(commen.comment_id)")
                self.defaults.synchronize()
                NetworkManager.sharedInstance.setCommentVote(name, email: mail, comment_id: commen.comment_id!, up_down: "1", completion: { (string , error) in
                    if error == nil {
                        print(string)
                        commen.up_votes! += 1
                        self.tableView.reloadData()
                    } else {
                        NetworkManager.sharedInstance.setCommentVote(name, email: mail, comment_id: commen.comment_id!, up_down: "1", completion: { (string , error) in
                            if string == "error" {
                                commen.up_votes! += 1
                                self.tableView.reloadData()
                            }
                        })
                    }
                })
            } else {
                ParametersConstructor.sharedInstance.showAlert("You can not vote !You are not logged in!", message: "")
            }
            
        } else {
            ParametersConstructor.sharedInstance.showAlert("You have already voted!", message: "")
        }
    }
    
    func downvoteButtonPressed(tableCell: CommentCell, downvoteButtonPressed downvoteButton: AnyObject) {
        let commen = arrayObjectsForCell[tableCell.tag] as! CommentsFeed
        
        if  self.defaults.objectForKey("\(commen.comment_id)") as? String == nil || self.defaults.objectForKey("\(commen.comment_id)") as? String == "" {
            
            var mail = ""
            if self.defaults.objectForKey("email") as? String != nil  {
                mail = ParametersConstructor.sharedInstance.encodingString(self.defaults.objectForKey("email") as! String)
                let name = ParametersConstructor.sharedInstance.encodingString(commen.name!)
                self.defaults.setObject("\(commen.comment_id)", forKey: "\(commen.comment_id)")
                self.defaults.synchronize()
                NetworkManager.sharedInstance.setCommentVote(name, email: mail, comment_id: commen.comment_id!, up_down: "-1", completion: { (string , error) in
                    if error == nil {
                        print(string)
                        commen.up_votes! += 1
                        self.tableView.reloadData()
                    } else {
                        NetworkManager.sharedInstance.setCommentVote(name, email: mail, comment_id: commen.comment_id!, up_down: "1", completion: { (string , error) in
                            if string == "error" {
                                commen.up_votes! += 1
                                self.tableView.reloadData()
                            }
                        })
                    }
                })
            } else {
                ParametersConstructor.sharedInstance.showAlert("You can not vote !You are not logged in!", message: "")
            }
            
        } else {
            ParametersConstructor.sharedInstance.showAlert("You have already voted!", message: "")
        }
    }
    
    func moreButtonPressed(tableCell: CommentCell, moreButtonPressed moreButton: AnyObject) {
        // moreView()
        print("\(tableCell.tag)")
        
    }
    
    func replyButtonPressed(tableCell: CommentCell, replyButtonPressed replyButton: AnyObject) {
        
        
        if arrayObjectsForCell[tableCell.tag] is CommentsFeed {
            if !replyOpened {
                replyOpened = true
                lastReplyID = Int(tableCell.tag + 1)
                arrayObjectsForCell.insert(ReplyForm(), atIndex: tableCell.tag + 1)
                tableView.reloadData()
            } else if lastReplyID == Int(tableCell.tag + 1) {
                replyOpened = false
                arrayObjectsForCell.removeAtIndex(lastReplyID)
                }
                tableView.reloadData()
            } else {
            arrayObjectsForCell.removeAtIndex(lastReplyID)
            if lastReplyID < tableCell.tag {
                lastReplyID = tableCell.tag
                arrayObjectsForCell.insert(ReplyForm(), atIndex: tableCell.tag)
                tableView.reloadData()
            } else {
                lastReplyID = tableCell.tag + 1
                arrayObjectsForCell.insert(ReplyForm(), atIndex: tableCell.tag + 1)
                tableView.reloadData()
            }
        }
    }
    
    //MARK: Load data
    func refresh(sender: AnyObject) {
        getComments()
    }
    func getComments() {
        if canGetCommentsFeed == true {
            canGetCommentsFeed = false
            if Global.setYourWebContent == true && Global.articleUrl != ""{
                var webView = WebView()
                webView.advertisingBanner = false
                self.arrayObjectsForCell.removeAll()
                self.arrayObjectsForCell.append(webView)
            }
            tableView.reloadData()
            NetworkManager.sharedInstance.getCommentsFeed { (array, error) in
                if error == nil {
                    self.refreshControl?.endRefreshing()
                    self.saveCommentData(array!)
                } else {
                    NetworkManager.sharedInstance.getCommentsFeed { (array, error) in
                        self.refreshControl?.endRefreshing()
                        self.saveCommentData(array!)
                    }
                }
            }
        }
    }
    
    func getReplies(index : Int ,comment : CommentsFeed ) {
        NetworkManager.sharedInstance.getRepliesForComment(comment.comment_id!, parent_id: comment.parent_id! , completion: { (arrayReplies , error) in
            if error == nil {
                let repliesArray = arrayReplies
                self.loadReply = true
                for r in repliesArray! {
                    r.level = comment.level! + 1
                    self.arrayObjectsForCell.insert(r, atIndex: index + 1)
                }
                self.tableView.reloadData()
            } else {
                self.getReplies(index, comment: comment)
            }
        })
    }
    
    func removeObjectFromSortedArray (indexObject : Int) {
        var firstLevel = 0
        var secondLevel = 0
        
        if arrayObjectsForCell[indexObject] is CommentsFeed {
            let firstObject = arrayObjectsForCell[indexObject] as! CommentsFeed
            firstLevel = firstObject.level!
        }
        if arrayObjectsForCell[indexObject + 1] is CommentsFeed {
            let secondObject = arrayObjectsForCell[indexObject + 1] as! CommentsFeed
            secondLevel = secondObject.level!
        } else {
            secondLevel = 0
        }
        
        if firstLevel < secondLevel {
            arrayObjectsForCell.removeAtIndex(indexObject + 1)
            tableView.reloadData()
            removeObjectFromSortedArray(indexObject)
        } else if firstLevel == secondLevel {
            tableView.reloadData()
        }
    }
    
    //MARK: AddCommentCellDelegate
    
    func postButtonPressed(tableCell: AddCommentCell, postButtonPressed postButton: AnyObject) {
        
        if arrayObjectsForCell[tableCell.tag] is CommentForm {
            let comment = arrayObjectsForCell[tableCell.tag] as! CommentForm
            if comment.addComment == true {
               
            if morePost == true {
                
                let indexPath = NSIndexPath.init(forRow: tableCell.tag , inSection: 0)
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! AddCommentCell
                
                if ParametersConstructor.sharedInstance.checkFields(cell.nameTextField.text!, email: cell.emailTextField.text!, comment: cell.commentTextView.text) == true {
                    morePost = false
                    
                    let name = ParametersConstructor.sharedInstance.encodingString(cell.nameTextField.text!)
                    let email = ParametersConstructor.sharedInstance.encodingString(cell.emailTextField.text!)
                    let comment = ParametersConstructor.sharedInstance.encodingString(cell.commentTextView.text!)
                    NetworkManager.sharedInstance.posComment(name, email: email, comment: comment) { (respon , error) in
                        if (error == nil) {
                            self.morePost = true
                            self.addLocalCommentObjectToTableView(cell, commentText: comment, nameText: name, emailText: email,commentID: (respon?.comment_id)! , index : tableCell.tag)
                        } else {
                            NetworkManager.sharedInstance.posComment(name, email: email, comment: comment) { (respon , error) in
                                if (error == nil) {
                                    self.addLocalCommentObjectToTableView(cell, commentText: comment, nameText: name, emailText: email,commentID: (respon?.comment_id)! , index : tableCell.tag)
                                } else {
                                    self.morePost = true
                                }
                            }
                        }
                    }
                }
              }
            }
        } else if arrayObjectsForCell[tableCell.tag] is ReplyForm {
            if morePost == true {
                let indexPath = NSIndexPath.init(forRow: tableCell.tag, inSection: 0)
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! AddCommentCell
                
                if ParametersConstructor.sharedInstance.checkFields(cell.nameTextField.text!, email: cell.emailTextField.text!, comment: cell.commentTextView.text) == true {
                    let nameText = ParametersConstructor.sharedInstance.encodingString(cell.nameTextField.text!)
                    let emailText = ParametersConstructor.sharedInstance.encodingString(cell.emailTextField.text!)
                    let commentText = ParametersConstructor.sharedInstance.encodingString(cell.commentTextView.text!)
                    morePost = false
                    self.arrayObjectsForCell.removeAtIndex(tableCell.tag)
                    let commen = arrayObjectsForCell[tableCell.tag - 1] as! CommentsFeed
                    NetworkManager.sharedInstance.postReplyForComment(nameText, email: emailText, comment: commentText, comment_id: commen.comment_id!) { (responce ,error) in
                        if error == nil && responce?.result != "repeat_comment" {
                            self.addLocalPeplyObjectToTableView(cell, commentText: commentText, nameText: nameText, emailText: emailText, index: tableCell.tag, forObject: commen, commentID: (responce?.result)!)
                            
                        } else {
                            NetworkManager.sharedInstance.postReplyForComment(nameText, email: emailText, comment: commentText, comment_id: commen.comment_id!) { (responce ,error) in
                                self.addLocalPeplyObjectToTableView(cell, commentText: commentText, nameText: nameText, emailText: emailText, index: tableCell.tag, forObject: commen, commentID: (responce?.result)!)
                                }
                            }
                        }
                    }
                }
            }
    }
    
    func logOutButtonPressed(tableCell: AddCommentCell, logOutButtonPressed logOutButton: AnyObject) {
        tableCell.nameTextField.text = ""
        tableCell.emailTextField.text = ""
        Saver.sharedInstance.removeWhenLogOutbuttonPressed()
        NetworkManager.sharedInstance.logOut()
        
        tableView.reloadData()
    }
    
    //MARK : LoadMoreCell delegate
    
    func loadMoreButtonPressed(tableCell: LoadMoreCell, loadMoreButtonPressed loadMoreButton: AnyObject) {
        if canGetCommentsFeed == true {
            canGetCommentsFeed = false
            from_count += Global.countLoadCommentsInPagination + 1
            to_count += Global.countLoadCommentsInPagination + 1
            
            NetworkManager.sharedInstance.getMoreCommentsFeed(from_count, to_count: to_count, completion: { (array ,error) in
                
                if error == nil {
                    self.addMoreCommentsToArrayOfObjects(array!)
                } else {
                    NetworkManager.sharedInstance.getMoreCommentsFeed(self.from_count, to_count: self.to_count, completion: { (array ,error) in
                        self.addMoreCommentsToArrayOfObjects(array!)
                    })
                }
            })
        }
    }
    func openVuukleButtonButtonPressed(tableCell: LoadMoreCell, openVuukleButtonPressed openVuukleButton: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: Global.websiteUrl)!)
    }
    
    //Mark: EmoticonCellDelegate
    
    func firstEmoticonButtonPressed(tableCell: EmoticonCell, firstEmoticonButtonPressed firstEmoticonButton: AnyObject) {
        
        ParametersConstructor.sharedInstance.setRate(Global.article_id, emote: 1, tableView: tableView)
    }
    
    func secondEmoticonButtonPressed(tableCell: EmoticonCell, secondEmoticonButtonPressed secondEmoticonButton: AnyObject) {
        ParametersConstructor.sharedInstance.setRate(Global.article_id, emote: 2, tableView: tableView)
    }
    
    func thirdEmoticonButtonPressed(tableCell: EmoticonCell, thirdEmoticonButtonPressed thirdEmoticonButton: AnyObject) {
        ParametersConstructor.sharedInstance.setRate(Global.article_id, emote: 3, tableView: tableView)
    }
    
    func fourthEmoticonButtonPressed(tableCell: EmoticonCell, fourthEmoticonButtonPressed fourthEmoticonButton: AnyObject) {
        ParametersConstructor.sharedInstance.setRate(Global.article_id, emote: 4, tableView: tableView)
    }
    
    func fifthEmoticonButtonPressed(tableCell: EmoticonCell, fifthEmoticonButtonPressed fifthEmoticonButton: AnyObject) {
        ParametersConstructor.sharedInstance.setRate(Global.article_id, emote: 5, tableView: tableView)
    }
    
    func sixthEmoticonButtonPressed(tableCell: EmoticonCell, sixthEmoticonButtonPressed sixthEmoticonButton: AnyObject) {
        ParametersConstructor.sharedInstance.setRate(Global.article_id, emote: 6, tableView: tableView)
    }

    //MARK: Keyboard (Show/Hide/Dismiss)
    
    func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y = -keyboardSize.height
        }
    }
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    func dismissKeyboard() {
        self.view.endEditing(true)
    }

    //MARK: Sharing to Facebook/Twitter
    func shareComment(index : Int , shareTo : String) {
        var socialservice = SLServiceTypeFacebook
        if shareTo == "Facebook" {
            socialservice = SLServiceTypeFacebook
        } else {
            socialservice = SLServiceTypeTwitter
        }
        let object = arrayObjectsForCell[index] as! CommentsFeed
        let textToshare = ParametersConstructor.sharedInstance.decodingString(object.comment!)
        if SLComposeViewController.isAvailableForServiceType(socialservice){
            let vc = SLComposeViewController(forServiceType: socialservice)
            vc.setInitialText("\(textToshare)")
            vc.addURL(NSURL(string: "\(Global.articleUrl)"))
            presentViewController(vc, animated: true, completion: nil)
        } else {
            ParametersConstructor.sharedInstance.showAlert("Accounts", message: "Please login to a \(shareTo) account to share.")
        }
    }
    
    //MARK: Addding local objects
    func addLocalPeplyObjectToTableView(cell : AddCommentCell, commentText : String,nameText : String , emailText : String , index : Int ,forObject : CommentsFeed , commentID : String) {
        let date = NSDate()
        let dateFormat = NSDateFormatter.init()
        dateFormat.dateStyle = .FullStyle
        dateFormat.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let stringOfDateInNewFornat = dateFormat.stringFromDate(date)
        let addComment = ParametersConstructor.sharedInstance.addReply(commentText, name: nameText, ts: stringOfDateInNewFornat, email: emailText, up_votes: 0, down_votes: 0, comment_id: commentID, replies: 0, user_id: "", avatar_url: "", parent_id: forObject.comment_id!, user_points: 0, myComment: true, level : forObject.level! + 1)
        forObject.replies! += 1
        self.arrayObjectsForCell.insert(addComment, atIndex: index)
        self.tableView.reloadData()
        cell.commentTextView.text = "Please write a comment..."
        cell.commentTextView.textColor = UIColor.lightGrayColor()
        self.morePost = true
    }
    
    func addLocalCommentObjectToTableView(cell : AddCommentCell, commentText : String,nameText : String , emailText : String , commentID : String ,index : Int) {
        let date = NSDate()
        let dateFormat = NSDateFormatter.init()
        dateFormat.dateStyle = .FullStyle
        dateFormat.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let stringOfDateInNewFornat = dateFormat.stringFromDate(date)
        Saver.sharedInstance.savingWhenPostButtonPressed(cell.nameTextField.text!, email: cell.emailTextField.text!)
        let addComment = ParametersConstructor.sharedInstance.addComment(commentText, name: nameText, ts: stringOfDateInNewFornat, email: emailText, up_votes: 0, down_votes: 0, comment_id: commentID, replies: 0, user_id: "", avatar_url: "", parent_id: "-1", user_points: 0, myComment: true, level : 0 )
        self.arrayObjectsForCell.insert(addComment, atIndex: index + 1)
        self.totalComentsCount += 1
        self.tableView.reloadData()
        cell.commentTextView.text = "Please write a comment..."
        cell.commentTextView.textColor = UIColor.lightGrayColor()
        self.morePost = true
    }
    
    func addMoreCommentsToArrayOfObjects(array : [CommentsFeed]) {
        self.arrayObjectsForCell.removeLast()
        for object in array {
            self.arrayObjectsForCell.append(object)
        }
        
        self.canLoadmore = true
        self.canGetCommentsFeed = true
        
        if array.count >= Global.countLoadCommentsInPagination{
            let load = LoadMore()
            load.showLoadMoreButton = true
            self.arrayObjectsForCell.append(load)
        } else {
            let load = LoadMore()
            load.showLoadMoreButton = false
            self.arrayObjectsForCell.append(load)
            
        }
        
        self.tableView.reloadData()
    }
    
    func saveCommentData(array : [CommentsFeed]) {

        self.from_count = 0
        self.to_count = Global.countLoadCommentsInPagination
        if array.count >= Global.countLoadCommentsInPagination {

            self.arrayObjectsForCell.append(WebView())
            self.arrayObjectsForCell.append(Emoticon())
            var addComment = CommentForm()
            addComment.addComment = true
            self.arrayObjectsForCell.append(addComment)
            for object in array {
                self.arrayObjectsForCell.append(object)
            }
            let load = LoadMore()
            load.showLoadMoreButton = true
            self.arrayObjectsForCell.append(load)
        } else {
            
            self.arrayObjectsForCell.append(WebView())
            self.arrayObjectsForCell.append(Emoticon())
            var addComment = CommentForm()
            addComment.addComment = true
            self.arrayObjectsForCell.append(addComment)
            for object in array {
                self.arrayObjectsForCell.append(object)
            }
            let load = LoadMore()
            load.showLoadMoreButton = false
            self.arrayObjectsForCell.append(load)
        }
        self.canGetCommentsFeed = true
        self.canLoadmore = true
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row {
            let myNumber = NSNumber(float: Float(tableView.contentSize.height))
            
            NSNotificationCenter.defaultCenter().postNotificationName("ContentHeightDidChaingedNotification", object: myNumber)
            }
    }   
}

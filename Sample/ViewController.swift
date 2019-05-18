//
//  ViewController.swift
//  Sample
//
//  Created by hide on 2019/05/12.
//  Copyright © 2019 com.nexwld.drew. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

final class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    
    @IBOutlet weak var layoutConstraintInputPaneTop: NSLayoutConstraint!
    @IBOutlet weak var layoutConstraintInputPaneBottom: NSLayoutConstraint!
    
    var initialTopOffset: CGFloat! //layoutConstraintInputPaneTop用
    var initialBottomOffset: CGFloat!//layoutConstraintInputPaneBottom
    
    var initialNameFieldPosition: CGFloat!
    var initialMsgFieldPosition: CGFloat!
    var initialsendButtonPosition: CGFloat!
    
    var database:DatabaseReference!
    
    override func viewDidLoad() {
        
        initialTopOffset = layoutConstraintInputPaneTop.constant
        initialBottomOffset = layoutConstraintInputPaneBottom.constant
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        //textViewを編集、選択可能にする
        self.textView.isEditable = false
        self.textView.isSelectable = true
        
        self.nameTextField.backgroundColor = UIColor(red: 117/255, green: 194/255, blue: 57/255, alpha: 1)
        self.messageTextField.backgroundColor = UIColor(red: 117/255, green: 194/255, blue: 57/255, alpha: 1)
        
        nameTextField.delegate = self as? UITextFieldDelegate
        messageTextField.delegate = self as? UITextFieldDelegate
        
        
        database = Database.database().reference()
        
        database.observe(.childAdded, with: { [weak self] snapshot in
            if let chunk = snapshot.value as? Dictionary<String, String> {
                if let name = chunk["name"], let message = chunk["message"] {
                    self?.textView.text.append("\(name): \(message)\n")
                    return
                }
            }
            print("Data format is invalid.")
        }) // database.observeの終わり
        
        //NSNotificationCenterクラス（観測センター）に自分自身(ViewController)を登録
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector:  #selector(handleKeyboardWillShowNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        notificationCenter.addObserver(self, selector:
            #selector(handleKeyboardWillHideNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    } //viewDidLoadの終わり
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onPressSendButton(_ sender: Any) {
        guard let name = nameTextField.text, let message = messageTextField.text else {
            fatalError("no name or message")
        }
        
        let chunk = ["name": name, "message": message]
        database.childByAutoId().setValue(chunk)
        
        messageTextField.text = ""
        
    } //onPressSendButtonの終わり
    
    @objc public func handleKeyboardWillShowNotification(notification: NSNotification) {
        //郵便入れみたいなもの
        let userInfo = notification.userInfo!
        //キーボードの大きさを取得
        let keyboardRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        
        offsetInputField(offset: keyboardRect.size.height)
        print("show呼び出されました")
        print(keyboardRect.size.height)
        
    } // handleKeyboardWillShowNotificationの終わり
    
    @objc func handleKeyboardWillHideNotification(notification: NSNotification) {
        
        _ = notification.userInfo!
        
        offsetInputField(offset: 0.0)
        print("hide呼ばれました")
    } //handleKeyboardWillHideNotificationの終わり
    
    
    
    func offsetInputField(offset: CGFloat) -> Void{
        layoutConstraintInputPaneTop.constant = initialTopOffset - offset
        
        layoutConstraintInputPaneBottom.constant = initialBottomOffset + offset
    } //offsetInputFieldの終わり
    
    // Viewが非表示になるたびに呼び出されるメソッド
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // NSNotificationCenterの解除処理
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    } //viewDidDisappearの終わり
    
    //キーボードのreturnが押された際にキーボードを閉じる処理
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        next?.resignFirstResponder()
        messageTextField.resignFirstResponder()
        return true
    } //textFieldShouldReturnの終わり
    
} //class ViewControllerの終わり

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("msgtxtfilefの幅:\(self.messageTextField.bounds.width)")
        
        return true
    }
}

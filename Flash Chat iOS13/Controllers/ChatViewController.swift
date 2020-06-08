import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    var message: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        title = K.appName
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessages()
    }
    
    func loadMessages(){
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener {(querySnapshot, error) in
            self.message = []
            if let e = error {
                print("The document have error: \(e)")
            }else{
                for document in querySnapshot!.documents {
                    let elem = document.data()
                    if let sender = elem[K.FStore.senderField] as? String, let messageBody = elem[K.FStore.bodyField] as? String{
                        self.message.append(Message(sender: sender, body: messageBody))
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            
                            let indexPath = IndexPath(row: self.message.count - 1 , section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: false)
                        }
                    }
                }
                self.messageTextfield.text = ""
            }
        }
    }
    
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        guard let messageBody = messageTextfield.text else { return }
        guard let messageSender = Auth.auth().currentUser?.email else { return }
       
        db.collection(K.FStore.collectionName)
            .addDocument(data: [K.FStore.bodyField: messageBody, K.FStore.senderField: messageSender, K.FStore.dateField: Date().timeIntervalSince1970])
        { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                self.loadMessages()
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        
    }
    

}

extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageOne = message[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message[indexPath.row].body
        if messageOne.sender == Auth.auth().currentUser?.email {
            cell.rightImage.isHidden = false
            cell.leftImage.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }else{
            cell.rightImage.isHidden = true
            cell.leftImage.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
        
        return cell
    }
    
    
}
extension ChatViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

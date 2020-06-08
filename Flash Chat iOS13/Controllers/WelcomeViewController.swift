import UIKit


class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func chatRegisterButton(_ sender: UIButton) {
        performSegue(withIdentifier: K.registerSegue, sender: self)
    }
    @IBAction func chatLoginButton(_ sender: UIButton) {
        performSegue(withIdentifier: K.loginSegue, sender: self)
    }
    
}

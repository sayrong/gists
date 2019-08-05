//
//  ViewController.swift
//  gists
//
//  Created by Dmitriy on 05/08/2019.
//  Copyright © 2019 Dmitriy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var model = [Gists]()
    
    @IBOutlet weak var table: UITableView!
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.dataSource = self
        self.table.delegate = self
        self.table.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "custom")
        // Do any additional setup after loading the view.
        load()
    }
    
    func load() {
        
        var components = URLComponents(string: "https://api.github.com/users/sayrong/gists")
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("token 89d23aad6f241da178aa4abb942470ca0ece0b50", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let this = self else { return }
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    break
                default:
                    print("Status: \(response.statusCode)")
                }
            }
            guard let data = data else { return }
            let res = Gists.parseResponse(data: data)
            if let res = res {
                this.model = res
                DispatchQueue.main.async {
                    this.table.reloadData()
                }
            }
        }
        task.resume()
    }

}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "custom", for: indexPath) as! CustomTableViewCell
        let gist = model[indexPath.row]
        if let lang = gist.files.first?.value.language {
            cell.language.text = lang
        }
        cell.name.text = gist.files.first?.value.filename ?? ""
        cell.creationDateLabel.text = "Creation date: \(gist.created_at)"
        cell.numberOfCommentsLabel.text = "Number of comments: \(gist.comments)"
        if let url = URL(string: gist.owner.avatar_url) {
            cell.gistImage.load(url: url)
        }
        cell.secretLabel.isHidden = gist.public
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    
}


extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

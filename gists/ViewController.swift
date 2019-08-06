//
//  ViewController.swift
//  gists
//
//  Created by Dmitriy on 05/08/2019.
//  Copyright © 2019 Dmitriy. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    var model = [Gists]()
    
    let token = "2a35aebc7f9356903e58e2e762d176a90e0b96a3"
    
    @IBOutlet weak var table: UITableView!
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.dataSource = self
        self.table.delegate = self
        self.table.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "custom")
        // Do any additional setup after loading the view.
        loadGistsFromApi(token: token)
    }
    
    func loadGistsFromApi(token: String) {
        var components = URLComponents(string: "https://api.github.com/users/sayrong/gists")
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        
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

    
    func convertDate(dateStr: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: dateStr) else { return "" }
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
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
        cell.creationDateLabel.text = "Creation date: \(convertDate(dateStr: gist.created_at))"
        cell.numberOfCommentsLabel.text = "Number of comments: \(gist.comments)"
        if let url = URL(string: gist.owner.avatar_url) {
            cell.gistImage.load(url: url)
        }
        cell.secretLabel.isHidden = gist.public
        cell.url = URL(string: gist.files.first?.value.raw_url ?? "")
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else { return }
        if let url = cell.url {
            let web = webViewController(req: URLRequest(url: url))
            self.navigationController?.pushViewController(web, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
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

class webViewController: UIViewController {
    private let webView = WKWebView()
    var request: URLRequest?
    
    convenience init(req: URLRequest) {
        self.init()
        request = req
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        if let req = request {
            webView.load(req)
        }
    }
    
    
    private func setupViews() {
        view.backgroundColor = .white
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}

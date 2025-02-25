//
//  NewsViewController.swift
//  NewsFinal
//
//  Created by Владислав Седенков on 24.08.2021.
//

import UIKit
import FirebaseAuth

class NewsViewController: UIViewController {

    private var viewModel: NewsViewModelProtocol
    private lazy var tableView = UITableView()
    
    //MARK: - init
    init(viewModel: NewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
   
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        getNewsData(category: .general)
        navigationItem.leftBarButtonItem = exitButton()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "scroll"), primaryAction: nil, menu: categoryMenu())
    }
    
}






//MARK: - TableViewDataSource
extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.news.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifier, for: indexPath) as!  NewsCell
        let news = viewModel.news[indexPath.row]
        cell.configure(for: news, viewModel: viewModel)
        return cell
    }
}
//MARK: TableViewDelegate
extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WebViewController()
        let news = viewModel.news[indexPath.row]
        vc.URL = news.url
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK: - Networking
extension NewsViewController {
    private func getNewsData(category: Category) {
        viewModel.getNewsData(category: category) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    self?.viewModel.imageCache.removeAllObjects()
                }
            case .failure:
                self?.showNetworkError()
                print(#function, "failure")
            }
        }
    }
}

//MARK: - FireBase
extension NewsViewController {
    @objc private func signOut() {
        do {
            try Auth.auth().signOut()
            viewModel.imageCache.removeAllObjects()
        } catch let error as NSError {
            print("Error signing out: \(error)")
        }
    }
}


//MARK: - UI
extension NewsViewController {
    private func categoryMenu() -> UIMenu {
        var categoryMenu: UIMenu {
            let menuAction = Category.allCases.map { [weak self] item -> UIAction in
                let name = item.rawValue
                return UIAction(title: name, image: UIImage(systemName: item.systemImage)) { [weak self] _ in
                    self?.getNewsData(category: item)
                }
            }
            return UIMenu(title: "Change Category", children: menuAction)
        }
        return categoryMenu
    }
    
    private func exitButton() -> UIBarButtonItem {
        let button = UIButton()
        button.setTitle("\u{2347}", for: .normal)
        button.setTitleColor(.orange, for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(25)
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        let barItem = UIBarButtonItem(customView: button)
        return barItem
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.register(NewsCell.self, forCellReuseIdentifier: NewsCell.identifier)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func showNetworkError() {
        let alert = UIAlertController(title: "Error", message: "There was an error accessing the News server. Please try again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}









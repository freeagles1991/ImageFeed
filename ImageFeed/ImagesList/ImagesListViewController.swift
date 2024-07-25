//
//  ViewController.swift
//  ImageFeed
//
//  Created by Дима on 03.05.2024.
//

import UIKit
import Kingfisher
import ProgressHUD

public protocol ImageListViewControllerProtocol: UIViewController {
    var presenter: ImageListPresenterProtocol? { get set }
    func updateTableViewAnimated(oldPhotosCount: Int, newPhotosCount: Int)
    func reloadData()
    func progressHUDDismiss()
    func imageListCellDidTapLike(_ cell: ImagesListCell)
    func configure(_ presenter: ImageListPresenterProtocol)
}

final class ImagesListViewController: UIViewController & ImageListViewControllerProtocol {
    var presenter: ImageListPresenterProtocol?
    
    private let alertService = AlertService.shared
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    let testMode =  ProcessInfo.processInfo.arguments.contains("testMode")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let presenter = presenter else { return }
        presenter.viewDidLoad()
        presenter.fetchInitialPhotos()
        
        alertService.delegate = self
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            guard let presenter = presenter else { return }
            if let imageUrl = presenter.getPhotoURL(indexPath: indexPath) {
                viewController.imageUrl = imageUrl
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    }
    
    ///Конфигурируем Presenter  и Viewer
    func configure(_ presenter: ImageListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func updateTableViewAnimated(oldPhotosCount: Int, newPhotosCount: Int) {
        if oldPhotosCount != newPhotosCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldPhotosCount..<newPhotosCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    func progressHUDDismiss(){
        ProgressHUD.dismiss()
    }
    
    func reloadData(){
        tableView.reloadData()
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, in tableView: UITableView) {
        guard let presenter = self.presenter else { return }
        let imageIndex = presenter.getPhotos()[indexPath.row]
        let imageURLString = imageIndex.thumbImageURL
        let imageURL = URL(string: imageURLString)
        
        _ = UIImage(named: "photo_stub")
        
        cell.cellImageView.kf.indicatorType = .activity
        
        cell.cellImageView.kf.cancelDownloadTask()
        cell.cellImageView.kf.setImage(
            with: imageURL,
            placeholder: createPlaceholderImage(forCellWith: tableView.rectForRow(at: indexPath)),
            options: nil) { completition in
                switch completition {
                case .success(_):
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    self.progressHUDDismiss()
                    print("ImagesListPresenter.configCell: Загрузка фото завершена")
                case .failure(let error):
                    self.progressHUDDismiss()
                    print("ImagesListPresenter.configCell: Загрузка фото НЕ завершена. Код - \(error)")
                }
            }
        
        let isLiked = imageIndex.isLiked
        let likeImage = isLiked ? UIImage(named: "FavoritreActive") : UIImage(named: "FavoritreNoActive")
        cell.likeButton.setImage(likeImage, for: .normal)
        
        guard let imageDate = imageIndex.createdAt else {
            cell.dateLabel.text = presenter.dateFormatter.string(from: Date())
            return
        }
        cell.dateLabel.text = presenter.dateFormatter.string(from: imageDate)
    }
    
    private func createPlaceholderImage(forCellWith frame: CGRect) -> UIImage {
        let placeholderView = UIView(frame: CGRect(origin: .zero, size: frame.size))
        placeholderView.backgroundColor = .white.withAlphaComponent(0.3)
        
        guard let imageStub = UIImage(named: "photo_stub") else { return UIImage() }
        let imageStubView = UIImageView(image: imageStub)
        imageStubView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.addSubview(imageStubView)
        
        NSLayoutConstraint.activate([
            imageStubView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            imageStubView.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            imageStubView.heightAnchor.constraint(equalToConstant: 75),
            imageStubView.widthAnchor.constraint(equalToConstant: 83)
        ])
        
        placeholderView.layoutIfNeeded()
        
        UIGraphicsBeginImageContextWithOptions(placeholderView.bounds.size, false, 0.0)
        placeholderView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let placeholderImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return placeholderImage ?? UIImage()
    }
}

extension ImagesListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presenter = presenter else { return 0 }
        return presenter.getPhotos().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        self.configCell(for: imageListCell, with: indexPath, in: tableView)
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !testMode{
            guard let presenter = presenter else { return }
            if indexPath.row == presenter.getPhotos().count - 1 {
                presenter.fetchInitialPhotos()
            }
        }
        
    }
}

extension ImagesListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        guard let presenter = presenter else { return CGFloat() }
        let imageIndex = presenter.getPhotos()[indexPath.row]
        let imageWidth = imageIndex.size.width
        let imageHeight = imageIndex.size.height
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let presenter = presenter else { return }
        let photo = presenter.getPhotos()[indexPath.row]
        
        cell.setIsLiked(isLiked: !photo.isLiked)
        UIBlockingProgressHUD.show()
        
        presenter.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result{
            case .success():
                print("ImagesListViewController: Лайк изменен")
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                print("ImagesListViewController: Лайк НЕ изменен - \(error)")
                cell.setIsLiked(isLiked: photo.isLiked)
                UIBlockingProgressHUD.dismiss()
                self.alertService.showAlert(title: "Ошибка", message: "Что-то пошло не так", buttonTitle: "ОК")
            }
        }
    }
}


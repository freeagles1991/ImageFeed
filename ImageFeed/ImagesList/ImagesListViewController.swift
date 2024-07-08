//
//  ViewController.swift
//  ImageFeed
//
//  Created by Дима on 03.05.2024.
//

import UIKit
import Kingfisher
import ProgressHUD

final class ImagesListViewController: UIViewController{
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private let alertService = AlertService.shared
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private var imageListServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchInitialPhotos()
        alertService.delegate = self
        
        imageListServiceObserver = NotificationCenter.default.addObserver(
                        forName: ProfileImageService.didChangeNotification,
                       object: nil,
                       queue: .main
                   ) { [weak self] _ in
                       guard let self = self else { return }
                       self.updateTableViewAnimated()
                   }
        
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
            
            let imageUrlString = photos[indexPath.row].largeImageURL
            if let imageUrl = URL(string: imageUrlString) {
                viewController.imageUrl = imageUrl
                //let image = UIImage(named: photosName[indexPath.row])
                //viewController.image = image
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    }
    
    private func updateTableViewAnimated(){
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        configCell(for: imageListCell, with: indexPath, in: tableView)
        return imageListCell
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, in tableView: UITableView) {
        // Получаем URL изображения из вашего массива или модели данных
        let imageIndex = photos[indexPath.row]
        let imageURLString = imageIndex.thumbImageURL
        let imageURL = URL(string: imageURLString)
        
        // Используем Kingfisher для асинхронной загрузки и кэширования изображения
        let placeholderImage = UIImage(named: "photo_stub")
        
        cell.cellImage.kf.indicatorType = .activity
        
        cell.cellImage.kf.cancelDownloadTask()
        cell.cellImage.kf.setImage(
            with: imageURL,
            placeholder: placeholderImage,
            options: nil) { completition in
                switch completition {
                case .success(_):
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    ProgressHUD.dismiss()
                    print("ImagesListViewController.configCell: Загрузка фото завершена")
                case .failure(let error):
                    ProgressHUD.dismiss()
                    print("ImagesListViewController.configCell: Загрузка фото НЕ завершена. Код - \(error)")
                }
            }
        
        //Выставляем лайк, если есть
        let isLiked = imageIndex.isLiked
        let likeImage = isLiked ? UIImage(named: "FavoritreActive") : UIImage(named: "FavoritreNoActive")
        cell.likeButton.setImage(likeImage, for: .normal)
        
        //Выставляем дату
        guard let imageDate = imageIndex.createdAt else {
            cell.dateLabel.text = dateFormatter.string(from: Date())
            return
        }
        cell.dateLabel.text = dateFormatter.string(from: imageDate)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            self.fetchInitialPhotos()
        }
    }
    
    private func fetchInitialPhotos() {
        ImagesListService.shared.fetchPhotosNextPage { result in
            switch result {
            case .success(let newPhotos):
                self.photos.append(contentsOf: newPhotos)
                self.tableView.reloadData()
            case .failure(let error):
                print("Ошибка загрузки фото: \(error)")
            }
        }
    }
}

extension ImagesListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        let imageIndex = photos[indexPath.row]
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
            let photo = photos[indexPath.row]
        
        cell.setIsLiked(isLiked: !photo.isLiked)
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result{
            case .success():
                print("ImagesListViewController: Лайк изменен")
                self.photos = self.imagesListService.photos
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


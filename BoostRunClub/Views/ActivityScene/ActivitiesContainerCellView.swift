//
//  ActivityCollectionContainerView.swift
//  BoostRunClub
//
//  Created by 김신우 on 2020/12/09.
//

import Combine
import UIKit

class ActivitiesContainerCellView: UITableViewCell {
    lazy var collectionView = ActivityCollectionView()

    var heightChangedPublisher = PassthroughSubject<UITableViewCell, Never>()
    var cancellables = Set<AnyCancellable>()

    init() {
        super.init(style: .default, reuseIdentifier: "\(Self.self)")
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        collectionView.heightPublisher
            .sink {
                self.bounds.size = $0
                self.heightChangedPublisher.send(self)
            }
            .store(in: &cancellables)

        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

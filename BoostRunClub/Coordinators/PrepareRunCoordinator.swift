//
//  PrepareRunCoordinator.swift
//  BoostRunClub
//
//  Created by 조기현 on 2020/11/23.
//

import Combine
import UIKit

protocol PrepareRunCoordinatorProtocol {
    func showGoalTypeActionSheet(goalType: GoalType) -> AnyPublisher<GoalType, Never>
    func showGoalValueSetupViewController(goalInfo: GoalInfo) -> AnyPublisher<String?, Never>
    func showRunningScene(goalInfo: GoalInfo)
}

enum PrepareRunCoordinationResult {
    case run(GoalInfo)
}

final class PrepareRunCoordinator: BasicCoordinator<PrepareRunCoordinationResult> {
    let factory: PrepareRunSceneFactory

    init(navigationController: UINavigationController, factory: PrepareRunSceneFactory = DependencyFactory.shared) {
        self.factory = factory
        super.init(navigationController: navigationController)
        navigationController.view.backgroundColor = .systemBackground
        navigationController.setNavigationBarHidden(false, animated: true)
    }

    override func start() {
        showPrepareRunViewController()
    }

    func showPrepareRunViewController() {
        let prepareRunVM = factory.makePrepareRunVM()

        prepareRunVM.outputs.showRunningSceneSignal
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                let result = PrepareRunCoordinationResult.run($0)
                self?.closeSignal.send(result)
            }
            .store(in: &cancellables)

        prepareRunVM.outputs.showGoalTypeActionSheetSignal
            .receive(on: RunLoop.main)
            .compactMap { [weak self] in self?.showGoalTypeActionSheet(goalType: $0) }
            .flatMap { $0 }
            .sink { prepareRunVM.inputs.didChangeGoalType($0) }
            .store(in: &cancellables)

        prepareRunVM.outputs.showGoalValueSetupSceneSignal
            .receive(on: RunLoop.main)
            .compactMap { [weak self] in self?.showGoalValueSetupViewController(goalInfo: $0) }
            .flatMap { $0 }
            .sink { prepareRunVM.inputs.didChangeGoalValue($0) }
            .store(in: &cancellables)

        let prepareRunVC = factory.makePrepareRunVC(with: prepareRunVM)
        navigationController.pushViewController(prepareRunVC, animated: true)
    }

    func showGoalTypeActionSheet(goalType: GoalType = .none) -> AnyPublisher<GoalType, Never> {
        let goalTypeVM = GoalTypeViewModel(goalType: goalType)
        let goalTypeVC = GoalTypeViewController(with: goalTypeVM)

        goalTypeVC.modalPresentationStyle = .overFullScreen
        navigationController.present(goalTypeVC, animated: false, completion: nil)

        return goalTypeVM.closeSheetSignal.receive(on: RunLoop.main)
            .map { [weak goalTypeVC] in
                goalTypeVC?.closeWithAnimation()
                return $0
            }.eraseToAnyPublisher()
    }

    func showGoalValueSetupViewController(goalInfo: GoalInfo) -> AnyPublisher<String?, Never> {
        // TODO: goalType, goalValue -> GoalInfo 타입으로 변경
        let goalValueSetupVM = GoalValueSetupViewModel(goalType: goalInfo.type, goalValue: goalInfo.value)
        let goalValueSetupVC = GoalValueSetupViewController(with: goalValueSetupVM)
        navigationController.pushViewController(goalValueSetupVC, animated: false)

        return goalValueSetupVM.closeSheetSignal
            .receive(on: RunLoop.main)
            .map { [weak goalValueSetupVC] in
                goalValueSetupVC?.navigationController?.popViewController(animated: false)
                return $0
            }
            .eraseToAnyPublisher()
    }
}

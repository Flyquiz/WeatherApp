//
//  PageViewController.swift
//  WeatherApp
//
//  Created by Иван Захаров on 24.10.2023.
//

import UIKit

final class PageViewController: UIPageViewController {
    
    private let citiesStore = CitiesStore.shared
    
    private lazy var vcs: [UIViewController] = {
        var array: [UIViewController] = []
        for city in self.citiesStore.cities {
            let vc = WeatherViewController()
            vc.getWeather(from: city.name)
            array.append(vc)
            print(city.name)
        }
        return array
    }()


    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: navigationOrientation)
        self.dataSource = self
        self.delegate = self
        self.setViewControllers([vcs[0]], direction: .forward, animated: true)
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? WeatherViewController else { return nil }
        if let index = vcs.firstIndex(of: viewController) {
            if index > 0 {
                return vcs[index - 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewController = viewController as? WeatherViewController else { return nil }
        if let index = vcs.firstIndex(of: viewController) {
            if index < vcs.count - 1 {
                return vcs[index + 1]
            }
        }
        return nil
    }
}

extension PageViewController: UIPageViewControllerDelegate {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return vcs.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

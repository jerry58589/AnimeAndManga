//
//  TestScheduler+Extension.swift
//  AnimeAndMangaTests
//
//  Created by JerryLo on 2022/4/22.
//

import Foundation
import RxSwift
import RxTest

extension TestScheduler {
    func record<O: ObservableConvertibleType>(_ source: O, disposeBag: DisposeBag) -> TestableObserver<O.Element> {
        let observer = self.createObserver(O.Element.self)
        source.asObservable()
            .bind(to: observer)
            .disposed(by: disposeBag)
        return observer
    }
}

//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>
//

import UIKit
import Token

extension TokensViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        guard
            let cell = gridCell(for: indexPath),
            let serviceData = cell.serviceData,
            cell.cellType != .placeholder
        else { return }
        presenter.handleUserTapped(on: serviceData)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let consumer = cell as? TokenTimerConsumer {
            presenter.handleRegisterTOTP(consumer)
        } else if let consumer = cell as? TokenCounterConsumer {
            consumer.didTapRefreshCounter = { [weak self] secret in
                DispatchQueue.main.asyncAfter(deadline: .now() + Theme.Animations.Timing.quick) {
                    self?.presenter.handleEnableHOTPCounter(for: secret)
                }
        }
            presenter.handleRegisterHOTP(consumer)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if let consumer = cell as? TokenTimerConsumer {
            presenter.handleRemoveTOTP(consumer)
        } else if let consumer = cell as? TokenCounterConsumer {
            consumer.didTapRefreshCounter = nil
            presenter.handleRemoveHOTP(consumer)
        }
    }
}

//
//  MasterViewController.swift
//  AnimationDemo
//
//  Created by Jay on 2017-01-06.
//  Copyright © 2017 Jay Abbott. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

	override func viewWillAppear(_ animated: Bool) {
		self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}

	func configure(curveController: CurveViewController, with cell: UITableViewCell) {
		curveController.setCurrentCurve(cell.reuseIdentifier ?? "zero")
		let curveName = cell.textLabel?.text
		curveController.navigationItem.title = curveName != nil ? "Curve - " + curveName! : "Curve"
		curveController.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
		curveController.navigationItem.leftItemsSupplementBackButton = true
	}

	// MARK: - Segues

	enum SegueIdentifier: String {
		case showAbout
		case showCurve
		case showAnimatable
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier! {
		case SegueIdentifier.showCurve.rawValue:
			if let selectedCell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!),
				let cVC = (segue.destination as? UINavigationController)?.topViewController as? CurveViewController {
				configure(curveController: cVC, with: selectedCell)
			}
		default: break
		}
	}

	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		switch identifier {
		case SegueIdentifier.showCurve.rawValue:
			if self.splitViewController?.viewControllers.count == 2 {
				if let selectedCell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!),
					let cVC = (self.splitViewController?.viewControllers[1] as? UINavigationController)?.topViewController as? CurveViewController {
					// There is already a curve controller there - keep and reconfigure it rather than segue to a new one
					configure(curveController: cVC, with: selectedCell)
					return false
				}
			}
		default: break
		}
		return true
	}
}


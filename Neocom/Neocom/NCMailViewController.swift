//
//  NCMailViewController.swift
//  Neocom
//
//  Created by Artem Shimanski on 14.04.17.
//  Copyright © 2017 Artem Shimanski. All rights reserved.
//

import UIKit
import CoreData
import EVEAPI

class NCMailViewController: NCTreeViewController {
	
	var label: ESI.Mail.MailLabelsAndUnreadCounts.Label? {
		didSet {
			updateTitle()
		}
	}

	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.register([Prototype.NCHeaderTableViewCell.default,
		                    Prototype.NCMailTableViewCell.default])
	}
	
	//MARK: - TreeControllerDelegate
	
	override func treeController(_ treeController: TreeController, didSelectCellWithNode node: TreeNode) {
		super.treeController(treeController, didSelectCellWithNode: node)
		if let node = node as? NCMailRow {
			if node.mail.isRead != true {
				var mail = node.mail
				mail.isRead = true
				treeController.reloadCells(for: [node])
				guard let record = node.cacheRecord else {return}
				guard var headers: [ESI.Mail.Header] = record.get() else {return}
				guard let i = headers.index(where: {$0.mailID == node.mail.mailID}) else {return}
				var header = headers[i]
				header.isRead = true
				headers[i] = header
				record.set(headers)
				if record.managedObjectContext?.hasChanges == true {
					try? record.managedObjectContext?.save()
				}
				if let unread = label?.unreadCount, unread > 0 {
					label?.unreadCount = unread - 1
					(parent as? NCMailPageViewController)?.saveUnreadCount()
				}
				updateTitle()
				_ = NCDataManager(account: NCAccount.current).markRead(mail: node.mail)
			}
		}
	}
	
	func treeController(_ treeController: TreeController, editActionsForNode node: TreeNode) -> [UITableViewRowAction]? {
		guard let node = node as? NCMailRow else {return nil}
		guard let mailID = node.mail.mailID else {return nil}
		let header = node.mail
		
		return [UITableViewRowAction(style: .destructive, title: NSLocalizedString("Delete", comment: ""), handler: { [weak self] (_,_) in
			guard let strongSelf = self else {return}
			guard let cell = self?.treeController?.cell(for: node) else {return}
			strongSelf.tableView.isUserInteractionEnabled = false

			
			let progress = NCProgressHandler(view: cell, totalUnitCount: 1, activityIndicatorStyle: .white)
			progress.progress.perform {
				strongSelf.dataManager.delete(mailID: mailID).then(on: .main) { result in
					guard let record = node.cacheRecord else {return}
					guard var headers: [ESI.Mail.Header] = record.get() else {return}
					guard let i = headers.index(where: {$0.mailID == node.mail.mailID}) else {return}
					headers.remove(at: i)
					
					guard let strongSelf = self else {return}
					
					if header.isRead == false, let unread = strongSelf.label?.unreadCount, unread > 0 {
						strongSelf.label?.unreadCount = unread - 1
						strongSelf.updateTitle()
						(strongSelf.parent as? NCMailPageViewController)?.saveUnreadCount()
					}
					
					record.set(headers)
					if record.managedObjectContext?.hasChanges == true {
						try? record.managedObjectContext?.save()
					}
					if let parent = node.parent, let i = parent.children.index(of: node) {
						parent.children.remove(at: i)
						if parent.children.isEmpty, let root = parent.parent, let i = root.children.index(of: parent) {
							root.children.remove(at: i)
						}
					}
				}.catch(on: .main) { error in
					strongSelf.present(UIAlertController(error: error), animated: true, completion: nil)
				}.finally(on: .main) {
					self?.tableView.isUserInteractionEnabled = true
					progress.finish()
				}
			}
		})]
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		fetchIfNeeded()
	}
	
	private var isEndReached = false
	private var isFetching = false {
		didSet {
			if isFetching {
				activityIndicator.startAnimating()
			}
			else {
				activityIndicator.stopAnimating()
			}
		}
	}
	private var lastID: Int64?
	private var mails: TreeNode?
	private var result: CachedValue<[ESI.Mail.Header]>?
	private var contacts: [Int64: NCContact] = [:]
	private var error: Error?

	override func load(cachePolicy: URLRequest.CachePolicy) -> Future<[NCCacheRecord]> {
		lastID = nil
		isEndReached = false
		mails = nil
		return fetch(from: nil).then { result in
			return [result.cacheRecord]
		}
	}
	
	override func content() -> Future<TreeNode?> {
		mails = TreeNode()
		return update(result: result).then { () -> TreeNode? in
			return mails
		}
	}
	
	private func update(result: CachedValue<[ESI.Mail.Header]>?) -> Future<Void> {
		guard let mails = mails, let label = label else {
			self.isFetching = false
			return .init(())
		}
		return updateContacts(result: result).then(on: .global(qos: .utility)) { contacts -> ([NCDateSection], Bool, Int64?) in
			var children = mails.children.map { i -> NCDateSection in
				let section = NCDateSection(date: (i as! NCDateSection).date)
				section.children = i.children
				return section
			}

			guard let headers = result?.value, !headers.isEmpty else { return (children, true, self.lastID) }

			var lastID = self.lastID
			let cacheRecord = result?.cacheRecord
			let dataManager = self.dataManager
			let contacts = self.contacts
			
			let calendar = Calendar(identifier: .gregorian)
			headers.filter {$0.mailID != nil && $0.timestamp != nil}.sorted{$0.mailID! > $1.mailID!}.forEach {
				header in
				let row = NCMailRow(mail: header, label: label, contacts: contacts, cacheRecord: cacheRecord, dataManager: dataManager)
				
				if let section = children.last, section.date < header.timestamp! {
					section.children.append(row)
				}
				else {
					
					let components = calendar.dateComponents([.year, .month, .day], from: header.timestamp!)
					let date = calendar.date(from: components) ?? header.timestamp!
					let section = NCDateSection(date: date)
					section.children = [row]
					children.append(section)
				}
				lastID = header.mailID
			}
			return (children, false, lastID)
		}.then(on: .main) { (children, isEndReached, lastID) in
			self.isEndReached = isEndReached

			UIView.performWithoutAnimation {
				mails.children = children
				self.treeController?.content = mails
			}
			self.mails = mails
			self.lastID = lastID
			self.fetchIfNeeded()
		}.catch(on: .main) { error in
			self.error = error
		}.finally(on: .main) {
			self.tableView.backgroundView = mails.children.isEmpty ? NCTableViewBackgroundLabel(text: self.error?.localizedDescription ?? NSLocalizedString("No Messages", comment: "")) : nil
			self.isFetching = false
		}
	}
	
	private func updateContacts(result: CachedValue<[ESI.Mail.Header]>?) -> Future<Void> {
		let promise = Promise<Void>()
		var ids = Set<Int64>()
		result?.value?.forEach { mail in
			ids.formUnion(Set(mail.recipients?.compactMap {Int64($0.recipientID)} ?? []))
			if let from = mail.from {
				ids.insert(Int64(from))
			}
		}
		ids.subtract(contacts.keys)
		if !ids.isEmpty {
			Progress(totalUnitCount: 1).perform {
				self.dataManager.contacts(ids: ids).then(on: .main) { result in
					let context = NCCache.sharedCache?.viewContext
					result.values.compactMap { (try? context?.existingObject(with: $0)) as? NCContact }.forEach {
						self.contacts[$0.contactID] = $0
					}
					try! promise.fulfill(())
				}.catch{error in
					try! promise.fail(error)
				}
			}
		}
		else {
			try! promise.fulfill(())
		}
		return promise.future
	}
	
	private func fetch(from: Int64?, completionHandler: ((CachedValue<[ESI.Mail.Header]>) -> Void)? = nil) {
		guard let label = label else {return}
		guard let labelID = label.labelID else {return}
		guard !isEndReached, !isFetching else {return}
		isFetching = true
		
		dataManager.returnMailHeaders(lastMailID: from, labels: [Int64(labelID)]).then(on: .main) { result in
			self.result = result
			self.error = nil
			self.update(result: result) {
				completionHandler?(result)
			}
		}.catch(on: .main) { error in
			self.error = error
			self.update(result: nil) {
			}
		}
	}
	
	private func fetchIfNeeded() {
		if let lastID = lastID, tableView.contentOffset.y > tableView.contentSize.height - tableView.bounds.size.height * 2 {
			guard !isEndReached, !isFetching else {return}
			
			let progress = NCProgressHandler(viewController: self, totalUnitCount: 1)
			progress.progress.perform {
				fetch(from: lastID) { _ in
					progress.finish()
				}
			}
		}
	}

	
	//MARK: - Private
	
	private func updateTitle() {
		guard let label = label else {return}
		if let unreadCount = label.unreadCount, unreadCount > 0 {
			title = "\(label.name ?? "") (\(unreadCount))"
		}
		else {
			title = label.name
		}
	}
	
}

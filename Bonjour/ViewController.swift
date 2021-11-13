//
//  ViewController.swift
//  Bonjour
//
//  Created by Fitzgerald Afful on 13/11/2021.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var browser = BonjourBrowser("_samplehttp._tcp")
    let cellName = "cell"
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellName)
        tableView.delegate = self
        tableView.dataSource = self
        browser.services.bind { _ in
            self.tableView.reloadData()
        }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath)
        cell.textLabel?.text = browser.services.value[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Do something")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return browser.services.value.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}


public class BonjourBrowser: NSObject {
    let type: String
    private var serviceBrowser = NetServiceBrowser()
    public var services: Observable<[NetService]> = Observable([NetService]())

    public init(_ type: String) {
        self.type = type
    }

    public func start() {
        services.value.removeAll()
        serviceBrowser.delegate = self
        serviceBrowser.schedule(in: .main, forMode: .common)
        serviceBrowser.searchForServices(ofType: type, inDomain: "local.")
    }
}

extension BonjourBrowser : NetServiceBrowserDelegate {
    public func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        //BonjourLog("BonjourBrowser:netServiceBrowser:didFind \(service)")
        services.value.append(service)
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        services.value = services.value.filter { $0 != service }
        //BonjourLog("BonjourBrowser:netServiceBroser:didRemove \(service), \(services.count)")
    }

    public func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        //BonjourLog("BonjourBrowser:netServiceBrowserDidStopSearch")
    }

    public func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        //BonjourLogError("BonjourBrowser:netServiceBrowser:didNotSearch \(errorDict)")
    }
}

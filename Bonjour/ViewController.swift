//
//  ViewController.swift
//  Bonjour
//
//  Created by Fitzgerald Afful on 13/11/2021.
//

import UIKit
import FTIndicator

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
        browser.start()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath)
        cell.textLabel?.text = browser.services.value[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myService = browser.services.value[indexPath.row]

        if (browser.selectedService != nil) {
            browser.selectedService?.stop()
        }
        myService.delegate = self
        myService.resolve(withTimeout: 0)
        FTIndicator.showProgress(withMessage: "")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return browser.services.value.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}

extension ViewController: NetServiceDelegate {
    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
        print("Did Accept")
    }

    func netServiceDidResolveAddress(_ sender: NetService) {
        FTIndicator.dismissProgress()
        print("Did Resolve \(sender.hostName ?? "Nil")")

        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServiceDetailsController") as! ServiceDetailsController
        controller.service = sender
        controller.title = sender.name
        print(sender.hostName)
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        FTIndicator.dismissProgress()
        FTIndicator.showError(withMessage: "Could not connect to service")
    }

    func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        print("Did Update TXT Record")
    }
}



public class BonjourBrowser: NSObject {
    let type: String
    public var selectedService: NetService?
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

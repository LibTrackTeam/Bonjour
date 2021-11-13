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

    var inputStream: InputStream?
    var outputStream: OutputStream?

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
        print("Did Resolve")
        print(sender.hostName)

        inputStream = InputStream()
        outputStream = OutputStream()


        let success = sender.getInputStream(&inputStream, outputStream: &outputStream)

        inputStream?.delegate = self
        outputStream?.delegate = self

        print("Success: \(success)")

        let word = "Hello are you there->"

        let buf = [UInt8](word.utf8)
        print("This is buf = \(buf))")

        inputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        outputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)

        inputStream?.open()
        print("Here the input stream will open")

        outputStream?.open()

        outputStream?.write(buf, maxLength: buf.count)

        //move to service details or chat or something
    }

    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        FTIndicator.dismissProgress()
        FTIndicator.showError(withMessage: "Could not connect to service")
    }

    func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        print("Did Update TXT Record")
    }
}

extension ViewController: StreamDelegate {

    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        print("we are in delegate method")

        print("EventCode = \(eventCode)")
        switch (eventCode)
        {
        case Stream.Event.openCompleted:
            if(aStream == outputStream) {
                print("output:OutPutStream opened")
            }
            print("Input = openCompleted")
            break
        case Stream.Event.errorOccurred:
            if(aStream === outputStream) {
                print("output:Error Occurred\n")

            }
            print("Input : Error Occurred\n")
            break

        case Stream.Event.endEncountered:
            if(aStream === outputStream) {
                print("output:endEncountered\n")
            }
            print("Input = endEncountered\n")
            break

        case Stream.Event.hasSpaceAvailable:
            if(aStream === outputStream) {
                print("output:hasSpaceAvailable\n")
            }

            print("Input = hasSpaceAvailable\n")
            break

        case Stream.Event.hasBytesAvailable:
            if(aStream === outputStream) {
                print("output:hasBytesAvailable\n")
            }
            if aStream === inputStream {
                print("Input:hasBytesAvailable\n")

                var buffer = [UInt8](repeating: 0, count: 4096)

                //print("input buffer = \(buffer)")
                // sleep(40)

                while (self.inputStream!.hasBytesAvailable)
                {
                    let len = inputStream!.read(&buffer, maxLength: buffer.count)

                    // If read bytes are less than 0 -> error
                    if len < 0
                    {
                        let error = self.inputStream!.streamError
                        print("Input stream has less than 0 bytes\(error!)")
                        //closeNetworkCommunication()
                    }
                    // If read bytes equal 0 -> close connection
                    else if len == 0
                    {
                        print("Input stream has 0 bytes")
                        // closeNetworkCommunication()
                    }


                    if(len > 0)
                        //here it will check it out for the data sending from the server if it is greater than 0 means if there is a data means it will write
                    {
                        let messageFromServer = NSString(bytes: &buffer, length: buffer.count, encoding: String.Encoding.utf8.rawValue)

                        if messageFromServer == nil
                        {
                            print("Network hasbeen closed")
                            // v1.closeNetworkCommunication()
                        }
                        else
                        {
                            print("MessageFromServer = \(String(describing: messageFromServer))")
                        }
                    }
                }
            }

            break

        default:
            print("default block")
        }
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

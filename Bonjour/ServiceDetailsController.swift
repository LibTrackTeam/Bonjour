//
//  ViewController.swift
//  Bonjour
//
//  Created by Fitzgerald Afful on 13/11/2021.
//

import UIKit
import FTIndicator
import CocoaAsyncSocket

class ServiceDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellName = "cell"
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTF: UITextField!
    var service: NetService?
    var messages: [String] = []

    var inputStream: InputStream?
    var outputStream: OutputStream?
    let maxReadLength = 4096
    private var socket: GCDAsyncSocket? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellName)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        //service?.delegate = self

        /*inputStream = InputStream()
        outputStream = OutputStream()

        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        // 2
        //CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, service!.hostName as CFString?, UInt32(service!.port), &readStream, &writeStream)
        //print(service.hos)
        Stream.getStreamsToHost(withName: service!.hostName!, port: service!.port, inputStream: &inputStream, outputStream: &outputStream)

        //inputStream = readStream!.takeRetainedValue()
        //outputStream = writeStream!.takeRetainedValue()

        //let success = service!.getInputStream(&inputStream, outputStream: &outputStream)

        inputStream!.delegate = self
        //outputStream!.delegate = self

        //print("Success: \(success)")

        inputStream!.schedule(in: .current, forMode: .common)
        outputStream!.schedule(in: .current, forMode: .common)

        inputStream!.open()
        outputStream!.open()*/

        socket = GCDAsyncSocket(delegate: self, delegateQueue: .main)
        try! socket!.connect(to: service!)
    
        
    }

    @IBAction func sendMessage() {
        let message = messageTF.text!
        if message.isEmpty {
            FTIndicator.showError(withMessage: "Please enter a message")
            return
        }
        let data = "\(message)\n".data(using: .utf8)!
        /*data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                print("Error joining chat")
                return
            }
            outputStream!.write(pointer, maxLength: data.count)
        }*/
        socket?.write(data, withTimeout: 30.0, tag: 1)
        self.messages.append(message)
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath)
        cell.textLabel?.text = messages[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}

extension ServiceDetailsController: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("Did connect to bastard \(host), \(port)")
        socket!.readData(withTimeout: -1, tag: 0)
        sock.readData(withTimeout: -1, tag: 0)
    }

    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        print("Did Accept New Socket")
        self.socket = newSocket
    }

    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("Did write message with tag \(tag)")

    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("Did Read \(tag)")
        let message = String(decoding: data, as: UTF8.self)
        self.messages.append(message)
        self.tableView.reloadData()
    }

    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Did Disconnect")
    }

    func socketDidCloseReadStream(_ sock: GCDAsyncSocket) {
        print("Did Close Read Stream")
    }

    func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        print("Did Read Partial Data Length")
    }
}

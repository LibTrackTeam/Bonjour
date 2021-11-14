//
//  CreateServiceController.swift
//  Bonjour
//
//  Created by Fitzgerald Afful on 13/11/2021.
//

import UIKit
import FTIndicator
import CocoaAsyncSocket


class CreateServiceController: UIViewController {

    var service: BonjourService?
    @IBOutlet weak var nameTF: UITextField!
    var socket: GCDAsyncSocket?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func createService() {
        let name = nameTF.text!
        if name.isEmpty {
            FTIndicator.showError(withMessage: "Please enter a name")
            return
        }
        service = BonjourService(type:"_samplehttp._tcp", port:8001, name: name)
        service?.delegate = self
        service?.start()

        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ServiceDetailsController") as! ServiceDetailsController
        controller.service = service?.service
        controller.title = service?.name
        //socket = GCDAsyncSocket(delegate: self, delegateQueue: .main)
        //try! socket?.accept(onPort: 8001)
        //self.navigationController?.pushViewController(controller, animated: true)
        //create server

    }

}


extension CreateServiceController: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("Did connect to bastard \(host), \(port)")
        socket!.readData(withTimeout: -1, tag: 0)
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

extension CreateServiceController: BonjourServiceDelegate {
    func serviceRunningStateDidChange(_ service: BonjourService) {
        print("Did Change")
    }

    func serviceClientsDidChange(_ service: BonjourService) {
        print("Clients Did Change: \(service.clients)")
    }

    func service(_ service: BonjourService, onRequest: BonjourRequest, socket: GCDAsyncSocket, context: String) {
        print("onRequest")
    }

    func service(_ service: BonjourService, onCall: String, params: [String : Any], socket: GCDAsyncSocket, context: String) {
        print("")
    }

}

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
        //create server
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

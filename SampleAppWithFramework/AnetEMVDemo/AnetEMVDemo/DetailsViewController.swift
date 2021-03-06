//
//  DetailsViewController.swift
//  AnetEMVDemo
//
//  Created by Pankaj Taneja on 2/29/16.
//  Copyright © 2016 Pankaj Taneja. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, AuthNetDelegate {

    @IBOutlet weak var action: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var sessionToken: String!
    var transId: String!
    var response: GetTransactionDetailsResponse!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.indicator.startAnimating()

        let request:GetTransactionDetailsRequest = GetTransactionDetailsRequest()
        request.anetApiRequest.merchantAuthentication.sessionToken = self.sessionToken
        request.anetApiRequest.merchantAuthentication.mobileDeviceId = "454545454545454545454"
        request.transId = self.transId
        AuthNet.getInstance().delegate = self
        AuthNet.getInstance().getTransactionDetailsRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func refund() -> () {
        self.indicator.startAnimating()
        let request:CreateTransactionRequest = CreateTransactionRequest()
        request.anetApiRequest.merchantAuthentication.sessionToken = self.sessionToken
        request.anetApiRequest.merchantAuthentication.mobileDeviceId = "454545454545454545454"
        request.transactionRequest.refTransId = self.response.transactionDetails.transId
        request.transactionRequest.amount = self.response.transactionDetails.settleAmount
        
        if self.response.transactionDetails.transactionStatus == "voided" {
            request.transactionRequest.payment = PaymentType();
            request.transactionRequest.payment.creditCard.cardNumber = self.response.transactionDetails.payment.creditCard.cardNumber
            request.transactionRequest.payment.creditCard.expirationDate = self.response.transactionDetails.payment.creditCard.expirationDate
        } else {
            request.transactionRequest.payment = nil
        }

        AuthNet.getInstance().delegate = self
        AuthNet.getInstance().void(with: request)
    }
    
    func getTransactionDetailsSucceeded(_ response: GetTransactionDetailsResponse!) {
        self.indicator.stopAnimating()
        self.textView.text = response.description
        self.response = response
        
        if self.response.transactionDetails.transactionStatus == "voided" {
            self.action.titleLabel?.text = "REFUND"
        } else {
            self.action.titleLabel?.text = "VOID"
        }
    }
    
    func paymentSucceeded(_ response: CreateTransactionResponse) -> () {
        let alertAction:UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: ({(action:UIAlertAction) -> Void  in
            self.navigationController?.popViewController(animated: true)
        }))
         
        var message:String = "Transaction Voided."
        
        if self.action.titleLabel?.text == "REFUND" {
            message = "Transaction Refunded."
        }
        
        let alert:UIAlertController = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: { () -> () in
            
        })
    }
    
    
    func requestFailed(_ response: AuthNetResponse) -> () {
        let alertAction:UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: ({(action:UIAlertAction) -> Void  in
            self.navigationController?.popViewController(animated: true)
        }))
        let alert:UIAlertController = UIAlertController(title: "Transaction failed.", message: "Transaction failed.", preferredStyle: .alert)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: { () -> () in
            
        })
    }
    
    func connectionFailed(_ response: AuthNetResponse) -> () {
        let alertAction:UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: ({(action:UIAlertAction) -> Void  in
            self.navigationController?.popViewController(animated: true)
        }))
        let alert:UIAlertController = UIAlertController(title: "Transaction failed.", message: "", preferredStyle: .alert)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: { () -> () in
            
        })
    }

}

import Braintree
import PassKit
import XCTest

class BTApplePay_Tests: XCTestCase {

    var mockClient : MockAPIClient = try! MockAPIClient(clientKey: "test_client_key")

    override func setUp() {
        super.setUp()
        mockClient = try! MockAPIClient(clientKey: "test_client_key")
    }

    func testTokenization_whenConfiguredOff_callsBackWithError() {
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "off"
            ]
            ])
        let expectation = expectationWithDescription("successful tokenization")

        let client = BTApplePayTokenizationClient(APIClient: mockClient)
        let payment = MockPKPayment()
        client.tokenizeApplePayPayment(payment) { (tokenizedPayment, error) -> Void in
            XCTAssertEqual(error!.domain, BTApplePayErrorDomain)
            XCTAssertEqual(error!.code, BTApplePayErrorType.Unsupported.rawValue)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenConfigurationFetchErrorOccurs_callsBackWithError() {
        mockClient.cannedConfigurationResponseError = NSError(domain: "MyError", code: 1, userInfo: nil)
        let client = BTApplePayTokenizationClient(APIClient: mockClient)
        let payment = MockPKPayment()
        let expectation = expectationWithDescription("tokenization error")

        client.tokenizeApplePayPayment(payment) { (tokenizedPayment, error) -> Void in
            XCTAssertEqual(error!.domain, "MyError")
            XCTAssertEqual(error!.code, 1)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenTokenizationErrorOccurs_callsBackWithError() {
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
            ])
        mockClient.cannedHTTPURLResponse = NSHTTPURLResponse(URL: NSURL(string: "any")!, statusCode: 503, HTTPVersion: nil, headerFields: nil)
        mockClient.cannedResponseError = NSError(domain: "foo", code: 100, userInfo: nil)
        let client = BTApplePayTokenizationClient(APIClient: mockClient)
        let payment = MockPKPayment()
        let expectation = expectationWithDescription("tokenization failure")

        client.tokenizeApplePayPayment(payment) { (tokenizedPayment, error) -> Void in
            XCTAssertEqual(error!, self.mockClient.cannedResponseError!)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenTokenizationFailureOccurs_callsBackWithError() {
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
            ])
        mockClient.cannedResponseError = NSError(domain: "MyError", code: 1, userInfo: nil)
        let client = BTApplePayTokenizationClient(APIClient: mockClient)
        let payment = MockPKPayment()
        let expectation = expectationWithDescription("tokenization failure")

        client.tokenizeApplePayPayment(payment) { (tokenizedPayment, error) -> Void in
            XCTAssertEqual(error!.domain, "MyError")
            XCTAssertEqual(error!.code, 1)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    func testTokenization_whenSuccessfulTokenizationInProduction_callsBackWithTokenizedPayment() {
        mockClient.cannedConfigurationResponseBody = BTJSON(value: [
            "applePay" : [
                "status" : "production"
            ]
        ])
        mockClient.cannedResponseBody = BTJSON(value: [
            "applePayCards": [
                [
                    "nonce" : "an-apple-pay-nonce",
                    "description": "a description",
                ]
            ]
            ])
        let expectation = expectationWithDescription("successful tokenization")

        let client = BTApplePayTokenizationClient(APIClient: mockClient)
        let payment = MockPKPayment()
        client.tokenizeApplePayPayment(payment) { (tokenizedPayment, error) -> Void in
            XCTAssertNil(error)
            XCTAssertEqual(tokenizedPayment!.localizedDescription, "a description")
            XCTAssertEqual(tokenizedPayment!.paymentMethodNonce, "an-apple-pay-nonce")
            expectation.fulfill()
        }

        XCTAssertEqual(mockClient.lastPOSTPath, "v1/payment_methods/apple_payment_tokens")

        waitForExpectationsWithTimeout(2, handler: nil)
    }

    class MockPKPaymentToken : PKPaymentToken {
        override var paymentData : NSData {
            get {
                return NSData()
            }
        }
        override var transactionIdentifier : String {
            get {
                return "transaction-id"
            }
        }
        override var paymentInstrumentName : String {
            get {
                return "payment-instrument-name"
            }
        }
        override var paymentNetwork : String {
            get {
                return "payment-network"
            }
        }
    }

    class MockPKPayment : PKPayment {
        var overrideToken = MockPKPaymentToken()
        override var token : PKPaymentToken {
            get {
                return overrideToken
            }
        }
    }

    class MockAPIClient : BTAPIClient {
        var lastPOSTPath = ""
        var lastPOSTParameters = [:] as [NSObject : AnyObject]

        var cannedConfigurationResponseBody : BTJSON? = nil
        var cannedConfigurationResponseError : NSError? = nil

        var cannedResponseError : NSError? = nil
        var cannedHTTPURLResponse : NSHTTPURLResponse? = nil
        var cannedResponseBody : BTJSON? = nil

        override func POST(path: String, parameters: [NSObject : AnyObject], completion completionBlock: (BTJSON?, NSHTTPURLResponse?, NSError?) -> Void) {
            lastPOSTPath = path
            lastPOSTParameters = parameters

            completionBlock(cannedResponseBody, cannedHTTPURLResponse, cannedResponseError)
        }

        override func fetchOrReturnRemoteConfiguration(completionBlock: (BTJSON?, NSError?) -> Void) {
            completionBlock(cannedConfigurationResponseBody, cannedConfigurationResponseError)
        }
    }

}







import Foundation

public extension Int {
    /**
     Categorizes a status code.
     - returns: The NetworkingStatusCodeType of the status code.
     */
    public func statusCodeType() -> Networking.StatusCodeType {
        if self >= 100 && self < 200 {
            return .informational
        } else if self >= 200 && self < 300 {
            return .successful
        } else if self >= 300 && self < 400 {
            return .redirection
        } else if self >= 400 && self < 500 {
            return .clientError
        } else if self >= 500 && self < 600 {
            return .serverError
        } else {
            return .unknown
        }
    }
}

open class Networking {
    static let ErrorDomain = "NetworkingErrorDomain"

    struct FakeRequest {
        let response: AnyObject?
        let statusCode: Int
    }

    /**
     Provides the options for configuring your Networking object with NSURLSessionConfiguration.
     - `Default:` This configuration type manages upload and download tasks using the default options.
     - `Ephemeral:` A configuration type that uses no persistent storage for caches, cookies, or credentials. It's optimized for transferring data to and from your app’s memory.
     - `Background:` A configuration type that allows HTTP and HTTPS uploads or downloads to be performed in the background. It causes upload and download tasks to be performed by the system in a separate process.
     */
    public enum ConfigurationType {
        case `default`, ephemeral, background
    }

    enum RequestType: String {
        case GET, POST, PUT, DELETE
    }

    enum SessionTaskType: String {
        case Data, Upload, Download
    }

    /**
     Sets the rules to serialize your parameters, also sets the `Content-Type` header.
     - `JSON:` Serializes your parameters using `NSJSONSerialization` and sets your `Content-Type` to `application/json`.
     - `FormURLEncoded:` Serializes your parameters using `Percent-encoding` and sets your `Content-Type` to `application/x-www-form-urlencoded`.
     - `MultipartFormData:` Serializes your parameters and parts as multipart and sets your `Content-Type` to `multipart/form-data`.
     - `Custom(String):` Sends your parameters as plain data, sets your `Content-Type` to the value inside `Custom`.
     */
    public enum ParameterType {
        /**
         Serializes your parameters using `NSJSONSerialization` and sets your `Content-Type` to `application/json`.
         */
        case json
        /**
         Serializes your parameters using `Percent-encoding` and sets your `Content-Type` to `application/x-www-form-urlencoded`.
         */
        case formURLEncoded
        /**
         Serializes your parameters and parts as multipart and sets your `Content-Type` to `multipart/form-data`.
         */
        case multipartFormData
        /**
         Sends your parameters as plain data, sets your `Content-Type` to the value inside `Custom`.
         */
        case custom(String)

        func contentType(boundary: String) -> String {
            switch self {
            case .json:
                return "application/json"
            case .formURLEncoded:
                return "application/x-www-form-urlencoded"
            case .multipartFormData:
                return "multipart/form-data; boundary=\(boundary)"
            case .custom(let value):
                return value
            }
        }
    }

    enum ResponseType {
        case json
        case data
        case image

        var accept: String? {
            switch self {
            case .json:
                return "application/json"
            default:
                return nil
            }
        }
    }

    /**
     Categorizes a status code.
     - `Informational`: This class of status code indicates a provisional response, consisting only of the Status-Line and optional headers, and is terminated by an empty line.
     - `Successful`: This class of status code indicates that the client's request was successfully received, understood, and accepted.
     - `Redirection`: This class of status code indicates that further action needs to be taken by the user agent in order to fulfill the request.
     - `ClientError:` The 4xx class of status code is intended for cases in which the client seems to have erred.
     - `ServerError:` Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has erred or is incapable of performing the request.
     - `Unknown:` This response status code could be used by Foundation for other types of states, for example when a request gets cancelled you will receive status code -999.
     */
    public enum StatusCodeType {
        case informational, successful, redirection, clientError, serverError, unknown
    }

    fileprivate let baseURL: String
    var fakeRequests = [RequestType : [String : FakeRequest]]()
    var token: String?
    var authorizationHeaderValue: String?
    var authorizationHeaderKey = "Authorization"
    var cache: NSCache<AnyObject, AnyObject>
    var configurationType: ConfigurationType

    /**
     Flag used to disable synchronous request when running automatic tests.
     */
    var disableTestingMode = false

    /**
     The boundary used for multipart requests
     */
    let boundary = String(format: "net.3lvis.networking.%08x%08x", arc4random(), arc4random())

    lazy var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration())
    }()

    /**
     Base initializer, it creates an instance of `Networking`.
     - parameter baseURL: The base URL for HTTP requests under `Networking`.
     */
    public init(baseURL: String, configurationType: ConfigurationType = .default, cache: NSCache<AnyObject, AnyObject>? = nil) {
        self.baseURL = baseURL
        self.configurationType = configurationType
        self.cache = cache ?? NSCache()
    }

    /**
     Authenticates using Basic Authentication, it converts username:password to Base64 then sets the Authorization header to "Basic \(Base64(username:password))".
     - parameter username: The username to be used.
     - parameter password: The password to be used.
     */
    open func authenticate(username: String, password: String) {
        let credentialsString = "\(username):\(password)"
        if let credentialsData = credentialsString.data(using: String.Encoding.utf8) {
            let base64Credentials = credentialsData.base64EncodedString(options: [])
            let authString = "Basic \(base64Credentials)"

            let config  = self.sessionConfiguration()
            config.httpAdditionalHeaders = [self.authorizationHeaderKey : authString]

            self.session = URLSession(configuration: config)
        }
    }

    /**
     Authenticates using a Bearer token, sets the Authorization header to "Bearer \(token)".
     - parameter token: The token to be used.
     */
    open func authenticate(token: String) {
        self.token = token
    }

    /**
     Authenticates using a custom HTTP Authorization header.
     - parameter authorizationHeaderKey: Sets this value as the key for the HTTP `Authorization` header
     - parameter authorizationHeaderValue: Sets this value to the HTTP `Authorization` header or to the `headerKey` if you provided that
     */
    open func authenticate(headerKey: String = "Authorization", headerValue: String) {
        self.authorizationHeaderKey = headerKey
        self.authorizationHeaderValue = headerValue
    }

    /**
     Returns a NSURL by appending the provided path to the Networking's base URL.
     - parameter path: The path to be appended to the base URL.
     - returns: A NSURL generated after appending the path to the base URL.
     */
    open func urlForPath(_ path: String) -> URL {
        guard let encodedPath = path.encodeUTF8() else { fatalError("Couldn't encode path to UTF8: \(path)") }
        guard let url = URL(string: self.baseURL + encodedPath) else { fatalError("Couldn't create a url using baseURL: \(self.baseURL) and encodedPath: \(encodedPath)") }
        return url
    }

    /**
     Returns the NSURL used to store a resource for a certain path. Useful to find where a download image is located.
     - parameter path: The path used to download the resource.
     - returns: A NSURL where a resource has been stored.
     */
    open func destinationURL(_ path: String, cacheName: String? = nil) throws -> URL {
        #if os(tvOS)
            let directory = NSSearchPathDirectory.CachesDirectory
        #else
            let directory = TestCheck.isTesting ? FileManager.SearchPathDirectory.cachesDirectory : FileManager.SearchPathDirectory.documentDirectory
        #endif
        let finalPath = cacheName ?? self.urlForPath(path).absoluteString
        let replacedPath = finalPath.replacingOccurrences(of: "/", with: "-")
        if let url = URL(string: replacedPath) {
            if let cachesURL = FileManager.default.urls(for: directory, in: .userDomainMask).first {
                #if !os(tvOS)
                try (cachesURL as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
                #endif
                let destinationURL = cachesURL.appendingPathComponent(url.absoluteString)

                return destinationURL
            } else {
                throw NSError(domain: Networking.ErrorDomain, code: 9999, userInfo: [NSLocalizedDescriptionKey : "Couldn't normalize url"])
            }
        } else {
            throw NSError(domain: Networking.ErrorDomain, code: 9999, userInfo: [NSLocalizedDescriptionKey : "Couldn't create a url using replacedPath: \(replacedPath)"])
        }
    }

    /**
     Splits a url in base url and relative path.
     - parameter path: The full url to be splitted.
     - returns: A base url and a relative path.
     */
    open static func splitBaseURLAndRelativePath(_ path: String) -> (baseURL: String, relativePath: String) {
        guard let encodedPath = path.encodeUTF8() else { fatalError("Couldn't encode path to UTF8: \(path)") }
        guard let url = URL(string: encodedPath) else { fatalError("Path \(encodedPath) can't be converted to url") }
        guard let baseURLWithDash = URL(string: "/", relativeTo: url)?.absoluteURL.absoluteString else { fatalError("Can't find absolute url of url: \(url)") }
        let index = baseURLWithDash.characters.index(baseURLWithDash.endIndex, offsetBy: -1)
        let baseURL = baseURLWithDash.substring(to: index)
        let relativePath = path.replacingOccurrences(of: baseURL, with: "")

        return (baseURL, relativePath)
    }

    /**
     Cancels all the current requests.
     - parameter completion: The completion block to be called when all the requests are cancelled.
     */
    open func cancelAllRequests(_ completion: ((Void) -> Void)?) {
        self.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            for sessionTask in dataTasks {
                sessionTask.cancel()
            }
            for sessionTask in downloadTasks {
                sessionTask.cancel()
            }
            for sessionTask in uploadTasks {
                sessionTask.cancel()
            }

            TestCheck.testBlock(disabled: self.disableTestingMode) {
                completion?()
            }
        }
    }

    /**
     Downloads data from a URL, caching the result.
     - parameter path: The path used to download the resource.
     - parameter completion: A closure that gets called when the download request is completed, it contains  a `data` object and a `NSError`.
     */
    open func downloadData(_ path: String, cacheName: String? = nil, completion: @escaping (_ data: Data?, _ error: NSError?) -> Void) {
        self.request(.GET, path: path, cacheName: cacheName, parameterType: nil, parameters: nil, parts: nil, responseType: .data) { response, error in
            completion(response as? Data, error)
        }
    }

    /**
     Retrieves data from the cache or from the filesystem.
     - parameter path: The path where the image is located.
     - parameter cacheName: The cache name used to identify the downloaded data, by default the path is used.
     - parameter completion: A closure that returns the data from the cache, if no data is found it will return nil.
     */
    open func dataFromCache(_ path: String, cacheName: String? = nil, completion: @escaping (_ data: Data?) -> Void) {
        self.objectFromCache(path, cacheName: cacheName, responseType: .data) { object in
            TestCheck.testBlock(disabled: self.disableTestingMode) {
                completion(object as? Data)
            }
        }
    }

    //*************************//
    //**** Deprecated area ****//
    //*************************//

    /**
     [Deprecated] Use `authenticate(headerValue)` instead.
     */
    @available(*, deprecated: 1.1.0, message: "Use `authenticate(headerValue)` instead") open func authenticate(authorizationHeader: String) {
        self.authenticate(headerValue: authorizationHeader)
    }
}

extension Networking {
    func objectFromCache(_ path: String, cacheName: String? = nil, responseType: ResponseType, completion: @escaping (_ object: AnyObject?) -> Void) {
        guard let destinationURL = try? self.destinationURL(path, cacheName: cacheName) else { fatalError("Couldn't get destination URL for path: \(path) and cacheName: \(cacheName)") }

        if let object = self.cache.object(forKey: destinationURL.absoluteString as AnyObject) {
            completion(object)
        } else if FileManager.default.fileExistsAtURL(destinationURL) {
            let semaphore = DispatchSemaphore(value: 0)
            var returnedObject: AnyObject?

            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.low).async {
                let object = self.dataForDestinationURL(destinationURL)
                if responseType == .image {
                    returnedObject = NetworkingImage(data: object)
                } else {
                    returnedObject = object as AnyObject?
                }
                if let returnedObject = returnedObject {
                    self.cache.setObject(returnedObject, forKey: destinationURL.absoluteString as AnyObject)
                }

                if TestCheck.isTesting && self.disableTestingMode == false {
                    semaphore.signal()
                } else {
                    completion(returnedObject)
                }
            }

            if TestCheck.isTesting && self.disableTestingMode == false {
                semaphore.wait(timeout: DispatchTime.distantFuture)
                completion(returnedObject)
            }
        } else {
            completion(nil)
        }
    }

    func dataForDestinationURL(_ url: URL) -> Data {
//        guard let path = url.path else { fatalError("Couldn't get path for url: \(url)") }
        guard let data = FileManager.default.contents(atPath: url.path) else { fatalError("Couldn't get image in destination url: \(url)") }

        return data
    }

    func sessionConfiguration() -> URLSessionConfiguration {
        switch self.configurationType {
        case .default:
            return URLSessionConfiguration.default
        case .ephemeral:
            return URLSessionConfiguration.ephemeral
        case .background:
            return URLSessionConfiguration.background(withIdentifier: "NetworkingBackgroundConfiguration")
        }
    }

    func fake(_ requestType: RequestType, path: String, fileName: String, bundle: Bundle = Bundle.main) {
        do {
            if let result = try JSON.from(fileName, bundle: bundle) {
                self.fake(requestType, path: path, response: result, statusCode: 200)
            }
        } catch ParsingError.notFound {
            fatalError("We couldn't find \(fileName), are you sure is there?")
        } catch {
            fatalError("Converting data to JSON failed")
        }
    }

    func fake(_ requestType: RequestType, path: String, response: AnyObject?, statusCode: Int) {
        var fakeRequests = self.fakeRequests[requestType] ?? [String : FakeRequest]()
        fakeRequests[path] = FakeRequest(response: response, statusCode: statusCode)
        self.fakeRequests[requestType] = fakeRequests
    }

    func request(_ requestType: RequestType, path: String, cacheName: String? = nil, parameterType: ParameterType?, parameters: AnyObject?, parts: [FormDataPart]?, responseType: ResponseType, completion: @escaping (_ response: AnyObject?, _ error: NSError?) -> ()) {
        if let responses = self.fakeRequests[requestType], let fakeRequest = responses[path] {
            if fakeRequest.statusCode.statusCodeType() == .successful {
                completion(fakeRequest.response, nil)
            } else {
                let error = NSError(domain: Networking.ErrorDomain, code: fakeRequest.statusCode, userInfo: [NSLocalizedDescriptionKey : HTTPURLResponse.localizedString(forStatusCode: fakeRequest.statusCode)])
                completion(nil, error)
            }
        } else {
            switch responseType {
            case .json:
                self.dataRequest(requestType, path: path, cacheName: cacheName, parameterType: parameterType, parameters: parameters, parts: parts, responseType: responseType) { data, error in
                    var returnedError = error
                    var returnedResponse: AnyObject?
                    if error == nil {
                        if let data = data , data.count > 0 {
                            do {
                                returnedResponse = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                            } catch let JSONError as NSError {
                                returnedError = JSONError
                            }
                        }
                    }

                    TestCheck.testBlock(disabled: self.disableTestingMode) {
                        completion(returnedResponse, returnedError)
                    }
                }
                break
            case .data, .image:
                self.objectFromCache(path, cacheName: cacheName, responseType: responseType) { object in
                    if let object = object {
                        TestCheck.testBlock(disabled: self.disableTestingMode) {
                            completion(object, nil)
                        }
                    } else {
                        self.dataRequest(requestType, path: path, cacheName: cacheName, parameterType: parameterType, parameters: parameters, parts: parts, responseType: responseType) { data, error in
                            var returnedResponse: AnyObject?
                            if let data = data , data.count > 0 {
                                guard let destinationURL = try? self.destinationURL(path, cacheName: cacheName) else { fatalError("Couldn't get destination URL for path: \(path) and cacheName: \(cacheName)") }
                                try? data.write(to: destinationURL, options: [.atomic])
                                switch responseType {
                                case .data:
                                    self.cache.setObject(data as AnyObject, forKey: destinationURL.absoluteString as AnyObject)
                                    returnedResponse = data as AnyObject?
                                    break
                                case .image:
                                    if let image = NetworkingImage(data: data) {
                                        self.cache.setObject(image, forKey: destinationURL.absoluteString as AnyObject)
                                        returnedResponse = image
                                    }
                                    break
                                default:
                                    fatalError("Response Type is different than Data and Image")
                                    break
                                }
                            }
                            TestCheck.testBlock(disabled: self.disableTestingMode) {
                                completion(returnedResponse, error)
                            }
                        }
                    }
                }
                break
            }
        }
    }

    func dataRequest(_ requestType: RequestType, path: String, cacheName: String? = nil, parameterType: ParameterType?, parameters: AnyObject?, parts: [FormDataPart]?, responseType: ResponseType, completion: @escaping (_ response: Data?, _ error: NSError?) -> ()) {
        let request = NSMutableURLRequest(url: self.urlForPath(path))
        request.httpMethod = requestType.rawValue

        if let parameterType = parameterType {
            request.addValue(parameterType.contentType(boundary: self.boundary), forHTTPHeaderField: "Content-Type")
        }

        if let accept = responseType.accept {
            request.addValue(accept, forHTTPHeaderField: "Accept")
        }

        if let authorizationHeader = self.authorizationHeaderValue {
            request.setValue(authorizationHeader, forHTTPHeaderField: self.authorizationHeaderKey)
        } else if let token = self.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: self.authorizationHeaderKey)
        }

        DispatchQueue.main.async {
            NetworkActivityIndicator.sharedIndicator.visible = true
        }

        var serializingError: NSError?
        if let parameterType = parameterType, let parameters = parameters {
            switch parameterType {
            case .json:
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                } catch let error as NSError {
                    serializingError = error
                }
                break
            case .formURLEncoded:
                guard let parametersDictionary = parameters as? [String : AnyObject] else { fatalError("Couldn't convert parameters to a dictionary: \(parameters)") }
                let formattedParameters = parametersDictionary.formURLEncodedFormat()
                request.httpBody = formattedParameters.data(using: String.Encoding.utf8)
                break
            case .multipartFormData:
                let bodyData = NSMutableData()

                if let parameters = parameters as? [String : AnyObject] {
                    for (key, value) in parameters {
                        let usedValue: AnyObject = value is NSNull ? "null" as AnyObject : value
                        var body = ""
                        body += "--\(self.boundary)\r\n"
                        body += "Content-Disposition: form-data; name=\"\(key)\""
                        body += "\r\n\r\n\(usedValue)\r\n"
                        bodyData.append(body.data(using: String.Encoding.utf8)!)
                    }
                }

                if let parts = parts {
                    for var part in parts {
                        part.boundary = self.boundary
                        bodyData.append(part.formData as Data)
                    }
                }

                bodyData.append("--\(self.boundary)--\r\n".data(using: String.Encoding.utf8)!)
                request.httpBody = bodyData as Data
                break
            case .custom(_):
                request.httpBody = parameters as? Data
                break
            }
        }

        if let serializingError = serializingError {
            completion(nil, serializingError)
        } else {
            var connectionError: NSError?
            let semaphore = DispatchSemaphore(value: 0)
            var returnedResponse: URLResponse?
            var returnedData: Data?

            self.session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                returnedResponse = response
                connectionError = error as NSError?
                returnedData = data

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                        if let data = data , data.count > 0 {
                            returnedData = data
                        }
                    } else {
                        connectionError = NSError(domain: Networking.ErrorDomain, code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey : HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)])
                    }
                }

                if TestCheck.isTesting && self.disableTestingMode == false {
                    semaphore.signal()
                } else {
                    DispatchQueue.main.async {
                        NetworkActivityIndicator.sharedIndicator.visible = false
                    }

                    self.logError(parameterType: parameterType, parameters: parameters, data: returnedData, request: request as URLRequest, response: returnedResponse, error: connectionError)
                    completion(returnedData, connectionError)
                }
                }) .resume()

            if TestCheck.isTesting && self.disableTestingMode == false {
                semaphore.wait(timeout: DispatchTime.distantFuture)
                self.logError(parameterType: parameterType, parameters: parameters, data: returnedData, request: request as URLRequest, response: returnedResponse, error: connectionError)
                completion(returnedData, connectionError)
            }
        }
    }

    func cancelRequest(_ sessionTaskType: SessionTaskType, requestType: RequestType, url: URL) {
        self.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            var sessionTasks = [URLSessionTask]()
            switch sessionTaskType {
            case .Data:
                sessionTasks = dataTasks
                break
            case .Download:
                sessionTasks = downloadTasks
                break
            case .Upload:
                sessionTasks = uploadTasks
                break
            }

            for sessionTask in sessionTasks {
                if sessionTask.originalRequest?.httpMethod == requestType.rawValue && sessionTask.originalRequest?.url?.absoluteString == url.absoluteString {
                    sessionTask.cancel()
                }
            }
        }
    }

    func logError(parameterType: ParameterType?, parameters: AnyObject? = nil, data: Data?, request: URLRequest?, response: URLResponse?, error: NSError?) {
        guard let error = error else { return }

        print(" ")
        print("========== Networking Error ==========")
        print(" ")

        let isCancelled = error.code == -999
        if isCancelled {
            if let request = request {
                print("Cancelled request: \(request)")
                print(" ")
            }
        } else {
            print("Error \(error.code): \(error.description)")
            print(" ")

            if let request = request {
                print("Request: \(request)")
                print(" ")
            }

            if let parameterType = parameterType, let parameters = parameters {
                switch parameterType {
                case .json:
                    do {
                        let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                        let string = String(data: data, encoding: String.Encoding.utf8)
                        print("Parameters: \(string)")
                        print(" ")
                    } catch let error as NSError {
                        print("Failed pretty printing parameters: \(parameters), error: \(error)")
                        print(" ")
                    }
                    break
                case .formURLEncoded:
                    guard let parametersDictionary = parameters as? [String : AnyObject] else { fatalError("Couldn't cast parameters as dictionary: \(parameters)") }
                    let formattedParameters = parametersDictionary.formURLEncodedFormat()
                    print("Parameters: \(formattedParameters)")
                    print(" ")
                    break
                default: break
                }

                print(" ")
            }

            if let data = data, let stringData = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                print("Data: \(stringData)")
                print(" ")
            }

            if let response = response as? HTTPURLResponse {
                if let headers = request?.allHTTPHeaderFields {
                    print("Headers: \(headers)")
                    print(" ")
                }
                print("Response status code: \(response.statusCode) — \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))")
                print(" ")
                print("Path: \(response.url?.absoluteString)")
                print(" ")
                print("Response: \(response)")
                print(" ")
            }
        }
        print("================= ~ ==================")
        print(" ")
    }
}

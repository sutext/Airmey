//
//  Request.swift
//  
//
//  Created by supertext on 2021/6/6.
//

import UIKit

public class Request{
    typealias Handler = (Response<JSON>)->Void
    private let task:URLSessionTask
    private let handler:Handler?
    public private(set) var error:Error?
    @Protected
    private var mutableData: Data? = nil
    private let retrier:Retrier = Retrier()
    var retryCount:Int = 0
    var metrics:URLSessionTaskMetrics?
    init(_ task:URLSessionTask,handler:Handler?) {
        self.task = task
        self.handler = handler
    }
    var method:Network.Method? {
        if let str = task.originalRequest?.httpMethod {
            return .init(rawValue: str)
        }
        return nil
    }
    var statusCode:Int?{
        if let resp = task.response as? HTTPURLResponse{
            return resp.statusCode
        }
        return nil
    }
    public var progress:Progress { task.progress }
    public var data:Data?{ mutableData }
    public var taskIdentifier:Int { task.taskIdentifier }
    public var state:URLSessionTask.State{
        self.task.state
    }
    func append(_ data:Data) {
        if self.data == nil {
            mutableData = data
        } else {
            $mutableData.write { $0?.append(data) }
        }
    }
    public func resume()  {
        task.resume()
    }
    public func cancel()  {
        task.cancel()
    }
    public func suspend()  {
        task.suspend()
    }
    func finish(_ error:Error?) {
        guard task.state == .completed else {
            fatalError("finis task when task did not completed")
        }
        self.error = error
        var result:Result<JSON,Swift.Error>
        if let data = data{
            result = .success(JSON.parse(data))
        }else{
            result = .failure(error ?? NTError.invalidData)
        }
        let response = Response<JSON>.init(data: data, result: result, request: task.originalRequest, response: task.response)
        self.handler?(response)
    }
}

/// Type describing the origin of the upload, whether `Data`, file, or stream.
public enum Uploadable {
    /// Upload from the provided `Data` value.
    case data(Data)
    /// Upload from the provided file `URL`, as well as a `Bool` determining whether the source file should be
    /// automatically removed once uploaded.
    case file(URL, shouldRemove: Bool)
    /// Upload from the provided `InputStream`.
    case stream(InputStream)
}
public class Upload{
    
}

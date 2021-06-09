//
//  Request.swift
//  Airmey
//
//  Created by supertext on 2021/6/09.
//  Copyright © 2021年 airmey. All rights reserved.
//

import UIKit
public class Request{
    typealias Handler = (Response<JSON>)->Void
    private var task:URLSessionTask
    private let urlreq:URLRequest
    private let handler:Handler?
    public private(set) var error:Error?
    public private(set) var retrier:HTTPRetrier?
    @Protected
    private var mutableData: Data? = nil
    var metrics:URLSessionTaskMetrics?
    init(_ task:URLSessionTask,urlreq:URLRequest,handler:Handler?,retrier:HTTPRetrier?) {
        self.task = task
        self.urlreq = urlreq
        self.handler = handler
        self.retrier  = retrier
    }
    public var method:HTTPMethod? {
        if let str = task.originalRequest?.httpMethod {
            return .init(rawValue: str)
        }
        return nil
    }
    public var statusCode:Int?{
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
    public func resume()  {
        task.resume()
    }
    public func cancel()  {
        task.cancel()
    }
    public func suspend()  {
        task.suspend()
    }
    func append(_ data:Data) {
        if self.data == nil {
            mutableData = data
        } else {
            $mutableData.write { $0?.append(data) }
        }
    }
    func finish(_ error:Error?)->HTTPRetrier.Result {
        guard task.state == .completed else {
            fatalError("finis task when task did not completed")
        }
        self.error = error
        // success callback directly
        guard let error = error else{
            var result:Result<JSON,Error>
            if let data = data {
                result = .init{try JSON.parse(data)}
            }else{
                result = .success(.null)
            }
            let response = Response<JSON>(data: data, result: result, request: task.originalRequest, metrics: metrics,response: task.response)
            self.handler?(response)
            return .not
        }
        // when some error consider retry
        let result = self.retrier?.doRetry(self, when: error)
        switch result {
        case .none,.not:
            let response = Response<JSON>(data: data, result: .failure(error), request: task.originalRequest, metrics: metrics,response: task.response)
            self.handler?(response)
            return .not
        case .now:
            return .now
        case .delay(let time):
            return .delay(time)
        }
    }
    func reset(in session:URLSession) {
        mutableData = nil
        metrics = nil
        error = nil
        task = session.dataTask(with: urlreq)
    }
}

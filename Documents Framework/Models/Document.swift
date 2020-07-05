//
//  Document.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 14/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation

struct Document {
    var createdDate: Date {
        return Date(timeIntervalSince1970: createdTimeStamp)
    } // computed property, represent In Seconds
    
    var createdTimeStampInMilliseconds: Int64 {
        return Int64(createdTimeStamp * 1000)
    }
    
    var createdTimeStamp: Double // represent In Seconds
    var documentId: Int
    var documentName: String
    var isClosed: Bool
    var isReported: Bool
    var skip: Bool
    var drafted: Bool
    var remoteUrl: String?
    var localUrl: String?
    var isDownloaded: Bool
    var documentType: String
    var seed: Int
    var metadatas: String = "[]"
    var userId: Int?
    var barcodes: String = "[]"
    
    init(documentId: Int, documentName: String, documentType: String, createdTimeStamp: Double = Date().timeIntervalSince1970) {
        isClosed = false
        isReported = false
        skip = false
        drafted = false
        isDownloaded = false
        
        seed = 0
        
        self.documentId = documentId
        self.documentName = documentName
        self.documentType = documentType
        self.createdTimeStamp = createdTimeStamp
    }
    
    public mutating func set() {
        self.drafted = false
    }
    
    public static func convertRemoteMetadatasToLocalMetadatas(remoteMetadatas: [[String:Any]]) -> [[String:Any]] {
        let localMetadatas = remoteMetadatas.map {
            convertRemoteMetadataToLocalMetadata(metadataJson: $0)
        }
        return localMetadatas
    }
    
    private static func convertRemoteMetadataToLocalMetadata(metadataJson: [String:Any]) -> [String:Any] {
        var metadata: [String:Any] = [:]
        
        metadata["metadataId"] = metadataJson["metadata_id"]
        
        if let metadataDefaultValue = metadataJson["metadata_default_value"] {
            metadata["metadataDefaultValue"] = metadataDefaultValue
        }
        else {
            metadata["metadataDefaultValue"] = ""
        }
        
        metadata["metadataKey"] = metadataJson["metadata_key"]
        metadata["metadataMessage"] = metadataJson["metadata_message"]
        metadata["metadataName"] = metadataJson["metadata_name"]
        metadata["metadataOptions"] = metadataJson["metadata_options"]
        metadata["metadataType"] = metadataJson["metadata_type"]
        
        if let metadataValue = metadataJson["metadata_value"] {
            metadata["metadataValue"] = metadataValue
        }
        else {
            metadata["metadataValue"] = ""
        }
        
        metadata["post"] = metadataJson["post"]
        metadata["pre"] = metadataJson["pre"]
        metadata["valueType"] = metadataJson["value_type"]
        metadata["isSetting"] = metadataJson["is_setting"]
        metadata["isRequired"] = metadataJson["is_required"]
        
        if let metadataActionType = metadataJson["metadata_action_type"] {
            metadata["metadataActionType"] = metadataActionType
        }
        else {
            metadata["metadataActionType"] = ""
        }
        return metadata
    }
}

extension Document {
    public static func decode(data: Data) throws -> [Document] { // because JsonDecoder cant deocde type any - problem in metadatas and brcodes as arbitary types
        let jsonDocuments = try JSONSerialization.jsonObject(with: data) as! [[String:Any]]
        return try jsonDocuments.map {
            var document = try JSONDecoder().decode(Document.self, from: JSONSerialization.data(withJSONObject: $0))
            
            if let metadatas = $0["metadatas"] as? [[String:Any]],
                let jsonMetadatas = String(data: try JSONSerialization.data(withJSONObject: metadatas), encoding: .utf8) {
                document.metadatas = jsonMetadatas
            }
            
            if let barcodes = $0["barcodes"] as? [[String:Any]],
                let jsonBarcodes = String(data: try JSONSerialization.data(withJSONObject: barcodes), encoding: .utf8) {
                document.barcodes = jsonBarcodes
            }
            return document
        }
    }
}


extension Document: Codable {
    enum CodingKeys: String, CodingKey {
        case documentId = "document_id"
        case toCreatedDateStr = "created_date"
        case fromCreatedDateStr = "date_created"
        case isClosed = "is_closed"
        case isDownloaded = "is_downloaded"
        case isReported = "is_reported"
        case localUrl = "url"
        case remoteUrl = "docUrl"
        case documentType = "document_type"
        case documentName = "document_name"
        case userId = "user_id"
        case barcodes
        case metadatas
        case seed
        case skip
        case drafted
    }
    
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.documentId = try container.decode(Int.self, forKey: .documentId)
        self.isClosed = try container.decode(Bool.self, forKey: .isClosed)
        self.isReported = try container.decode(Bool.self, forKey: .isReported)
        self.remoteUrl = try container.decodeIfPresent(String.self, forKey: .remoteUrl)
        self.documentType = (try container.decode(String.self, forKey: .documentType)).lowercased()
        self.documentName = try container.decode(String.self, forKey: .documentName)
        self.seed = try container.decodeIfPresent(Int.self, forKey: .seed) ?? 0
        self.skip = (try container.decodeIfPresent(Bool.self, forKey: .skip)) ?? false
        self.drafted = (try container.decodeIfPresent(Bool.self, forKey: .drafted)) ?? false
        self.userId = try container.decodeIfPresent(Int.self, forKey: .userId)
        
        let createdDateStr = try container.decode(String.self, forKey: .fromCreatedDateStr)
        self.createdTimeStamp = Date.convertFrom(date: createdDateStr, as: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")!.timeIntervalSince1970
        
        self.localUrl = nil
        self.isDownloaded = false
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(documentId, forKey: .documentId)
        try container.encode(isClosed, forKey: .isClosed)
        try container.encode(isDownloaded, forKey: .isDownloaded)
        try container.encode(isReported, forKey: .isReported)
        try container.encode(localUrl, forKey: .localUrl)
        try container.encode(documentType, forKey: .documentType)
        try container.encode(documentName, forKey: .documentName)
        try container.encode(metadatas, forKey: .metadatas)
        try container.encode(seed, forKey: .seed)
        try container.encode(skip, forKey: .skip)
        try container.encode(drafted, forKey: .drafted)
        try container.encode(userId, forKey: .userId)
        try container.encode(barcodes, forKey: .barcodes)
        
        try container.encode(createdDate.convertToString(), forKey: .toCreatedDateStr)
    }
}

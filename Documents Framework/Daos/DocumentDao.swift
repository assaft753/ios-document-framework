//
//  DocumentDao.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 11/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation
import SQLite

struct DocumentDao {
    
    private let db: Connection
    
    public init(db: Connection) {
        self.db = db
    }
    
    public func getDocumentsBy(type: String) -> [Document] {
        if let dbDocuments = try? db.prepare(DocumentDao.table.filter(DocumentDao.documentType == type)) {
            return DocumentDao.convertToDocumentModelsFrom(rows: dbDocuments)
        }
        return []
    }
    
    public func getDocumentsBy(type: DocumentType) -> [Document] {
        if let dbDocuments = try? db.prepare(DocumentDao.table.filter(DocumentDao.documentType == type.rawValue.lowercased())) {
            return DocumentDao.convertToDocumentModelsFrom(rows: dbDocuments)
        }
        return []
    }
    
    public func getAllDocuments() -> [Document] {
        if let dbDocuments = try? db.prepare(DocumentDao.table) {
            return DocumentDao.convertToDocumentModelsFrom(rows: dbDocuments)
        }
        return []
    }
    
    public func getDocumentBy(id: Int) -> Document? {
        if let dbDocuments = try? db.prepare(DocumentDao.table.filter(DocumentDao.documentId == id)),
            let dbDocument = dbDocuments.first() {
            return DocumentDao.convertToDocumentModelFrom(row: dbDocument)
        }
        return nil
    }
    
    public func deleteDocumentBy(id: Int) {
        let _ = try? db.run(DocumentDao.table.filter(DocumentDao.documentId == id).delete())
    }
    
    public func deleteDocuments() {
        let _ = try? db.run(DocumentDao.table.delete())
    }
    
    public func insert(documents: [Document]) throws -> [Int] {
        var ids: [Int] = []
        try db.transaction {
            ids.append(contentsOf: try documents.map { try insert(document: $0) })
        }
        return ids
    }
    
    public func insert(document: Document) throws -> Int {
        return try Int(db.run(DocumentDao.table.insert(
            or: .replace,
            DocumentDao.documentId <- document.documentId,
            DocumentDao.documentName <- document.documentName,
            DocumentDao.documentType <- document.documentType,
            DocumentDao.isClosed <- document.isClosed,
            DocumentDao.isReported <- document.isReported,
            DocumentDao.skip <- document.skip,
            DocumentDao.drafted <- document.drafted,
            DocumentDao.remoteUrl <- document.remoteUrl,
            DocumentDao.localUrl <- document.localUrl,
            DocumentDao.createdDate <- document.createdTimeStampInMilliseconds,
            DocumentDao.isDownloaded <- document.isDownloaded,
            DocumentDao.seed <- document.seed,
            DocumentDao.metadatas <- document.metadatas,
            DocumentDao.userId <- document.userId,
            DocumentDao.barcodes <- document.barcodes
        )))
    }
    
    private func updateDocument<T>(id: Int, col: Expression<T>, value: T) where T : Value {
        _ = try? db.run(DocumentDao.table.filter(DocumentDao.documentId == id).update(col <- value))
    }
    
    private func updateDocument(id: Int, values: Setter...) { // In case we update a nullable col with a non-nullable value, generic here will not do the work
        _ = try? db.run(DocumentDao.table.filter(DocumentDao.documentId == id).update(values))
    }
    
    public func update(documentId: Int, isReported: Bool) {
        updateDocument(id: documentId, col: DocumentDao.isReported, value: isReported)
    }
    
    public func update(documentId: Int, seed: Int) {
        updateDocument(id: documentId, col: DocumentDao.seed, value: seed)
    }
    
    public func update(documentId: Int, skip: Bool) {
        updateDocument(id: documentId, col: DocumentDao.skip, value: skip)
    }
    
    public func update(documentId: Int, isDownloaded: Bool) {
        updateDocument(id: documentId, col: DocumentDao.isDownloaded, value: isDownloaded)
    }
    
    public func update(documentId: Int, metadatas: String) {
        updateDocument(id: documentId, col: DocumentDao.metadatas, value: metadatas)
    }
    
    public func update(documentId: Int, barcodes: String) {
        updateDocument(id: documentId, col: DocumentDao.barcodes, value: barcodes)
    }
    
    public func update(documentId: Int, createdDate: Int64) {
        updateDocument(id: documentId, values: DocumentDao.createdDate <- createdDate)
    }
    
    public func update(documentId: Int, isClosed: Bool) {
        updateDocument(id: documentId, col: DocumentDao.isClosed, value: isClosed)
    }
    
    public func update(documentId: Int, localUrl: String) {
        updateDocument(id: documentId, values: DocumentDao.localUrl <- localUrl)
    }
    
    public func update(documentId: Int, drafted: Bool) {
        updateDocument(id: documentId, col: DocumentDao.drafted, value: drafted)
    }
}

extension DocumentDao {
    private static let table = Table("document")
    private static let documentId = Expression<Int>("document_id")
    private static let documentName = Expression<String>("document_name")
    private static let isClosed = Expression<Bool>("is_closed")
    private static let isReported = Expression<Bool>("is_reported")
    private static let skip = Expression<Bool>("skip")
    private static let drafted = Expression<Bool>("drafted")
    private static let remoteUrl = Expression<String?>("remote_url")
    private static let localUrl = Expression<String?>("local_url")
    private static let createdDate = Expression<Int64?>("created_date")
    private static let isDownloaded = Expression<Bool>("is_downloaded")
    private static let documentType = Expression<String>("document_type")
    private static let seed = Expression<Int>("seed")
    private static let metadatas = Expression<String>("metadatas")
    private static let userId = Expression<Int?>("user_id")
    private static let barcodes = Expression<String>("barcodes")
    
    private static func convertToDocumentModelsFrom(rows: AnySequence<Row>) -> [Document] {
        return rows.map { convertToDocumentModelFrom(row: $0) }
    }
    
    private static func convertToDocumentModelFrom(row: Row) -> Document {
        var createdTimeStamp = Date().timeIntervalSince1970
        if let unwrappedCreatedTimeStamp = row[DocumentDao.createdDate] {
            createdTimeStamp = Double(Double(unwrappedCreatedTimeStamp) / 1000) // In Seconds
        }
        
        var document = Document(documentId: row[DocumentDao.documentId], documentName: row[DocumentDao.documentName], documentType: row[DocumentDao.documentType], createdTimeStamp: createdTimeStamp)
        
        document.isClosed = row[DocumentDao.isClosed]
        document.isReported = row[DocumentDao.isReported]
        document.skip = row[DocumentDao.skip]
        document.drafted = row[DocumentDao.drafted]
        document.remoteUrl = row[DocumentDao.remoteUrl]
        document.localUrl = row[DocumentDao.localUrl]
        document.isDownloaded = row[DocumentDao.isDownloaded]
        document.seed = row[DocumentDao.seed]
        document.metadatas = row[DocumentDao.metadatas]
        document.userId = row[DocumentDao.userId]
        document.barcodes = row[DocumentDao.barcodes]
        
        return document
    }
}



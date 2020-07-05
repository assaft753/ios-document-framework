//
//  DocumentService.swift
//  POD Offline
//
//  Created by Assaf Tayouri on 15/06/2020.
//  Copyright © 2020 Assaf Tayouri. All rights reserved.
//

import Foundation

struct DocumentService {
    
    public static var docDirectory: URL {
        return URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])!.appendingPathComponent("files", isDirectory: true)
    }
    
    private static var _instance: DocumentService!
    
    public static var shared: DocumentService {
        _instance = _instance ?? DocumentService()
        return _instance
    }
    
    private let documentDao: DocumentDao
    private var locker: ReadWriteLock
    
    private init() {
        self.documentDao = DocumentDao(db: Database.shared.db)
        self.locker = ReadWriteLock()
    }
    
    public func getDocumentsBy(documentType: DocumentType) -> [Document] {
        return self.locker.acquireReadLock {
            return documentDao.getDocumentsBy(type: documentType)
        }
    }
    
    public func getAllDocuments() -> [Document] {
        return self.locker.acquireReadLock {
            return documentDao.getAllDocuments()
        }
    }
    
    public func getDocumentsBy(documentId: Int) -> Document? {
        return self.locker.acquireReadLock {
            return documentDao.getDocumentBy(id: documentId)
        }
    }
    
    public func deleteDocumentBy(documentId: Int) {
        return self.locker.acquireWriteLock {
            documentDao.deleteDocumentBy(id: documentId)
        }
    }
    
    public func deleteAllDocument() {
        return self.locker.acquireWriteLock {
            documentDao.deleteDocuments()
        }
    }
    
    public func insert(document: inout Document) throws {
        return try self.locker.acquireWriteLock {
            let documentId = try documentDao.insert(document: document)
            document.documentId = documentId
        }
    }
    
    public func update(document: inout Document, isReported: Bool) {
        self.locker.acquireWriteLock {
            documentDao.update(documentId: document.documentId, isReported: isReported)
            document.isReported = isReported
        }
        
    }
    
    public func update(document: inout Document, seed: Int) {
        self.locker.acquireWriteLock {
            documentDao.update(documentId: document.documentId, seed: seed)
            document.seed = seed
        }
        
    }
    
    public func update(document: inout Document, skip: Bool) {
        self.locker.acquireWriteLock {
            documentDao.update(documentId: document.documentId, skip: skip)
            document.skip = skip
        }
        
    }
    
    public func update(document: inout Document, isDownloaded: Bool) {
        self.locker.acquireWriteLock {
            documentDao.update(documentId: document.documentId, isDownloaded: isDownloaded)
            document.isDownloaded = isDownloaded
        }
        
    }
    
    public func update(document: inout Document, metadatas: String) {
        self.locker.acquireWriteLock {
            documentDao.update(documentId: document.documentId, metadatas: metadatas)
            document.metadatas = metadatas
        }
        
    }
    
    public func update(document: inout Document, barcodes: String) {
        self.locker.acquireWriteLock {
            documentDao.update(documentId: document.documentId, barcodes: barcodes)
            document.barcodes = barcodes
        }
        
    }
    
    public func update(document: inout Document, createdDate: Date) { // Pass the correct date format
        self.locker.acquireWriteLock {
            documentDao.update(documentId: document.documentId, createdDate: Int64(createdDate.timeIntervalSince1970 * 1000))
            document.createdTimeStamp = createdDate.timeIntervalSince1970
        }
        
    }
    
    public func update(document: inout Document, isClosed: Bool) {
        self.locker.acquireWriteLock{
            documentDao.update(documentId: document.documentId, isClosed: isClosed)
            document.isClosed = isClosed
        }
        
    }
    
    public func update(document: inout Document, localUrl: String) {
        self.locker.acquireWriteLock {
            documentDao.update(documentId: document.documentId, localUrl: localUrl)
            document.localUrl = localUrl
        }
        
    }
    
    public func update(document: inout Document, drafted: Bool) {
        self.locker.acquireWriteLock {
            documentDao.update(documentId: document.documentId, drafted: drafted)
            document.drafted = drafted
        }
        
    }
    
    //MARK: refresh methods
    public func refreshDocuments(andReturn documentType: DocumentType? = nil) throws -> [Document]
    {
        return try self.locker.acquireWriteLock {
            try self.refreshPaperMetadatas()
            
            var documents: [Document] = []
            do {
                if let documentsData = try PODNetworking().request(httpMethod: .GET, entryPoint: "document")
                {  
                    let documentsArr = try Document.decode(data: documentsData)
                    documents.append(contentsOf: documentsArr)
                }
            } catch {
                throw ErrorContainer(error: error, track: Track.track(), message: "refreshDocuments Of Documents")
            }
            
            do {
                if let notesData = try PODNetworking().request(httpMethod: .GET, entryPoint: "document/user/notes")
                {
                    let notesArr = try Document.decode(data: notesData)
                    documents.append(contentsOf: notesArr)
                }
            } catch {
                throw ErrorContainer(error: error, track: Track.track(), message: "refreshDocuments Of Notes")
            }
            
            documents = try refreshLocalDocuments(with: documents)
            
            if let documentType = documentType {
                return documents.filter {
                    $0.documentType == documentType.rawValue.lowercased()
                }
            }
            else {
                return documents
            }
        }
    }
    
    private func refreshLocalDocuments(with imutableRemoteDocuments: [Document]) throws -> [Document]
    {
        let localDocuments: [Document] = documentDao.getAllDocuments()
        var remoteDocuments: [Document] = imutableRemoteDocuments
        var notExistDocuments: [Document] = []
        var shouldDeleteDocuments: [Document] = []
        documentDao.deleteDocuments()
        
        var documentExists: Bool = false
        do {
            for (remoteDocumentIndex, remoteDocument) in remoteDocuments.enumerated() {
                for (localDocumentIndex, localDocument) in localDocuments.enumerated() {
                    if remoteDocument.documentId == localDocument.documentId {
                        documentExists = true
                        remoteDocuments[remoteDocumentIndex].isDownloaded = localDocuments[localDocumentIndex].isDownloaded
                        remoteDocuments[remoteDocumentIndex].localUrl = localDocuments[localDocumentIndex].localUrl
                        remoteDocuments[remoteDocumentIndex].isClosed = localDocuments[localDocumentIndex].isClosed
                        remoteDocuments[remoteDocumentIndex].isReported = localDocuments[localDocumentIndex].isReported
                        remoteDocuments[remoteDocumentIndex].drafted = localDocuments[localDocumentIndex].drafted
                        remoteDocuments[remoteDocumentIndex].skip = localDocuments[localDocumentIndex].skip
                        
                        //Update Metadatas
                        var relevantMetadatas: [[String: Any]] = []
                        
                        let localMetadatas = try JSONSerialization.jsonObject(with: localDocument.metadatas.data(using: .utf8)!) as! [[String: Any]]
                        
                        let remoteMetadatas = try JSONSerialization.jsonObject(with: remoteDocument.metadatas.data(using: .utf8)!) as! [[String: Any]]
                        
                        for var remoteMetadata in remoteMetadatas {
                            for localMetadata in localMetadatas {
                                if (remoteMetadata["metadata_key"] as! String) == (localMetadata["metadata_key"] as! String) && ((remoteMetadata["post"] as! Bool) || (remoteMetadata["pre"] as! Bool)) {
                                    remoteMetadata["metadata_value"] = localMetadata["metadata_value"]
                                    break
                                }
                            }
                            relevantMetadatas.append(remoteMetadata)
                        }
                        
                        remoteDocuments[remoteDocumentIndex].metadatas = String(data: try JSONSerialization.data(withJSONObject: relevantMetadatas), encoding: .utf8)!
                        
                        //Update Barcodes
                        var relevantBarcodes: [[String: Any]] = []
                        
                        let localBarcodes = try JSONSerialization.jsonObject(with: localDocument.barcodes.data(using: .utf8)!) as! [[String: Any]]
                        
                        let remoteBarcodes = try JSONSerialization.jsonObject(with: remoteDocument.barcodes.data(using: .utf8)!) as! [[String: Any]]
                        
                        for var remoteBarcode in remoteBarcodes {
                            for localBarcode in localBarcodes {
                                if (remoteBarcode["barcode"] as! String) == (localBarcode["barcode"] as! String) {
                                    remoteBarcode["is_charged"] = localBarcode["is_charged"]
                                    remoteBarcode["is_discharged"] = localBarcode["is_discharged"]
                                    remoteBarcode["charged_quantity"] = localBarcode["charged_quantity"]
                                    remoteBarcode["discharged_quantity"] = localBarcode["discharged_quantity"]
                                    break
                                }
                            }
                            relevantBarcodes.append(remoteBarcode)
                        }
                        remoteDocuments[remoteDocumentIndex].barcodes = String(data: try JSONSerialization.data(withJSONObject: relevantBarcodes), encoding: .utf8)!
                        
                        if remoteDocument.documentType.lowercased() == "note"
                            && localDocument.seed > remoteDocument.seed {
                            remoteDocuments[remoteDocumentIndex].seed = localDocument.seed
                        }
                        break
                    }
                }
                
                if !documentExists {
                    notExistDocuments.append(remoteDocument)
                }
                else if (remoteDocument.isDownloaded || remoteDocument.localUrl == nil ||
                    remoteDocument.localUrl!.isEmpty) && TaskService.shared.getTaskBy(identifier: remoteDocument.documentId, notificationType: "ManualDownloadDocument") == nil &&
                    TaskService.shared.getTaskBy(identifier: remoteDocument.documentId, notificationType: "DownloadDocument") == nil {
                    notExistDocuments.append(remoteDocument)
                }
                
                documentExists = false
            }
            
            documentExists = false
            for localDocument in localDocuments {
                for remoteDocument in remoteDocuments {
                    if localDocument.documentId == remoteDocument.documentId {
                        documentExists = true
                        break
                    }
                }
                if !documentExists {
                    shouldDeleteDocuments.append(localDocument)
                }
                documentExists = false
            }
            
            let _ = try documentDao.insert(documents: remoteDocuments)
            
            try notExistDocuments.forEach {
                var task: Task = Task(notificationType: "ManualDownloadDocument")
                task.identifier = $0.documentId
                try TaskService.shared.insert(task: &task)
            }
            
            shouldDeleteDocuments.forEach {
                if let docUrl = $0.localUrl, $0.isDownloaded {
                    let _ = FileService.shared.remove(at: docUrl)
                }
            }
            
            remoteDocuments.sort { $0.documentId > $1.documentId }
            
            return remoteDocuments
        } catch {
            throw ErrorContainer(error: error, track: Track.track(), message: "refreshLocalDocuments")
        }
    }
    
    private func refreshPaperMetadatas() throws {
        do {
            if let data = try PODNetworking().request(httpMethod: .GET, entryPoint: "metadata/paper"),
                let jsonMetadatas = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["metadatas"] as? [[String: Any]],
                let remoteJsonMetadatasData = try? JSONSerialization.data(withJSONObject: Document.convertRemoteMetadatasToLocalMetadatas(remoteMetadatas: jsonMetadatas)),
                let remoteJsonMetadatasStr = String(data: remoteJsonMetadatasData, encoding: .utf8) {
                LocalStorageService.shared.set(for: "paper_metadatas", value: remoteJsonMetadatasStr)
            }
        } catch {
            throw ErrorContainer(error: error, track: Track.track(), message: "refreshPaperMetadatas")
        }
    }
    
    public func refreshDocumentMetadatas() throws -> [Document] {
        try locker.acquireWriteLock {
            let documentIds = documentDao.getAllDocuments().map { $0.documentId }
            do {
                if  let responseData = try PODNetworking().request(httpMethod: .POST, entryPoint: "metadata/document", body: documentIds),
                let jsonData = try? JSONSerialization.jsonObject(with: responseData) as? [String:Any],
                let metadatas = jsonData["metadatas"] as? [String: [[String: Any]]] {
                    documentIds.forEach {
                        if let documentMetadatas = metadatas["\($0)"],
                            let documentMetadatasData = try? JSONSerialization.data(withJSONObject: documentMetadatas),
                            let documentMetadatasStr = String(data: documentMetadatasData, encoding: .utf8) {
                            documentDao.update(documentId: $0, metadatas: documentMetadatasStr)
                        }
                    }
                }
            }
                
            catch {
                throw ErrorContainer(error: error, track: Track.track(), message: "refreshDocumentMetadatas")
            }
            
            return documentDao.getDocumentsBy(type: DocumentType.document)
        }
    }
    
    public func report(documentIds: [Int]) throws {
        try locker.acquireWriteLock {
            do {
                let _ = try PODNetworking().request(httpMethod: .PUT, entryPoint: "document/report", body: ["document_ids": documentIds])
            }
                
            catch HttpError.notAuthorizeError(let message) {
                throw ErrorContainer(error: HttpError.notAuthorizeError(message: message), track: Track.track(), message: "from documents report")
            }
                
            catch PODError.podComponentsFromLocalStorageError(let message) {
                throw ErrorContainer(error: PODError.podComponentsFromLocalStorageError(message), track: Track.track(), message: "from documents report")
            }
                
            catch {
                let jsonDocumentIds = try! String(data: JSONSerialization.data(withJSONObject: ["document_ids": documentIds]), encoding: .utf8)!
                var task = Task(notificationType: "ReportDocuments")
                task.data = jsonDocumentIds
                let _ = try? TaskService.shared.insert(task: &task)
            }
            
            documentIds.forEach {
                documentDao.update(documentId: $0, isReported: true)
            }
        }
    }
    
    public func duplicateNote(documentId: Int) throws -> String {
        try locker.acquireWriteLock {
            if let note = documentDao.getDocumentBy(id: documentId), let docUrl = note.localUrl {
                if note.documentType != DocumentType.note.rawValue.lowercased() {
                    throw ErrorContainer(error: DocumentError.documentNotNoteError, track: Track.track(), message: "duplicateNote")
                }
                let splitedNoteName = note.documentName.split(separator: ".")
                
                let noteName: String
                
                if splitedNoteName.count == 0 {
                    noteName = note.documentName
                }
                else {
                    noteName = String(splitedNoteName[0])
                }
                
                let dstFileName = "\(noteName)_\(Double(Date().timeIntervalSince1970) / 1000)"
                if FileService.shared.duplicate(srcPath: docUrl, dstPath: DocumentService.docDirectory.normalizedAbsoluteString(), dstFileName: dstFileName) {
                    return DocumentService.docDirectory.appendingPathComponent(dstFileName, isDirectory: false).normalizedAbsoluteString()
                }
                else {
                    throw ErrorContainer(error: DocumentError.documentLocalUrlMissingError, track: Track.track(), message: "duplicateNote")
                }
            }
            else {
                throw ErrorContainer(error: DocumentError.documentNotFoundError, track: Track.track(), message: "duplicateNote")
            }
        }
    }
    
    
    //TODO: Add Broadcaster
    
    //MARK: Document Error
    enum DocumentError: Error {
        case documentNotFoundError
        case documentNotNoteError
        case documentLocalUrlMissingError
    }
}


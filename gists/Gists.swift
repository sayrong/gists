//
//  Gist.swift
//  gists
//
//  Created by Dmitriy on 05/08/2019.
//  Copyright © 2019 Dmitriy. All rights reserved.
//

import Foundation

struct Gists: Codable {
    //Дата создания
    let created_at: String?
    //Количество комментариев
    let comments: Int?
    let files: [String: GistFile]
    let owner: Owner?
    let `public`: Bool?
    
    static func parseResponse(data: Data) -> [Gists]? {
        var result = [Gists]()
        do {
            result = try JSONDecoder().decode([Gists].self, from: data)
        } catch {
            print("Error \(error.localizedDescription)")
            return nil
        }
        return result
    }
}

struct Owner: Codable {
    let login: String
    let avatar_url: String
}

struct GistFile: Codable {
    let filename: String?
    let type: String?
    let language: String?
    let raw_url: String?
    let size: Int?
    let content: String?
}

//
//  File.swift
//
//
//  Created by PEXAVC on 5/7/23.
//

import Foundation
import SwiftUI

extension Prompts {
    public struct Reword {
        public init(){}
    }
}

extension Prompts.Reword: BasicPrompt {
    public var prompt: String {
        """
        Provide suggestions on how to reword {$subcommand=subject}.
        
        Upto 4 suggestions that diversifies the words and grammar to attract multiple audiences. The audiences that are picked are up to your discretion. Label each suggestion with a header describing the audience you picked.
        
        An audience can be any demographic of your choosing depending on the subject matter.
        
        Use the H3 markdown when labeling audiences and put suggestions in markdown blockquote
        """
    }
    
    public var iconName: String {
        "highlighter"
    }
    
    public var baseColor: Color {
        .init(red: 0 / 255, green: 128 / 255, blue: 128 / 255)
    }
    
    public var description: String {
        "Reword a phrase or passage from another perspective..."
    }
    
    public var hasSubcommand: Bool {
        false
    }
    
    public var command: any BasicCommand {
        SystemCommand(value: Prompts.reword.rawValue.lowercased())
    }
    
//    public var subCommandHelperText: String? {
//        ""
//    }
}

//extension Prompts.Reword {
//    public var subCommands: [any AnySubcommand] {
//        [
//            SubjectSubcommand()
//        ]
//    }
//
//    public struct SubjectSubcommand: AnySubcommand {
//        public var id: String {
//            "subject"
//        }
//
//        public var values: [SubcommandValue] {
//            [
//                .init(id: "general", value: "the prompt"),
//                .init(id: "resume",
//                      value: """
//                        Provide suggestions on how to reword a resume. The resume will be labeled with this flag, within the double quotes and after the equal sign \"\(Prompts.Subcommand.file)\".
//
//                        The user prompt will be a job description and use it as a guide on how to reword it appropriately.
//
//                        Try to use the text from the user prompt to properly connec t the resume to the employer's job description. Aligning skill sets that might align with what the job requires.
//
//                        Style it as a modern 1 page resume.
//                        """,
//                      acceptsFile: true,
//                      ignoresBasePrompt: true,
//                      acceptedFileExtensions: ["pdf"],
//                      additionalHelperText: "Upload a PDF & paste a job description here")
//            ]
//        }
//    }
//}

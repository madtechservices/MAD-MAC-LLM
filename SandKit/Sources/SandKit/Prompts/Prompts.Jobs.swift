//
//  File.swift
//
//
//  Created by PEXAVC on 5/7/23.
//

import Foundation
import SwiftUI

extension Prompts {
    public struct Jobs {
        public init(){}
    }
}

extension Prompts.Jobs: BasicPrompt {
    public var prompt: String {
        """
        """
    }
    
    public var iconName: String {
        "briefcase"
    }
    
    public var baseColor: Color {
        .init(red: 255 / 255, green: 222 / 255, blue: 85 / 255)
    }
    
    public var description: String {
        "Write a cover letter, revise a resumé, or research a company..."
    }
    
    public var hasSubcommand: Bool {
        true
    }
    
    public var subCommandHelperText: String? {
        ""
    }
    
    public var config: PromptConfig {
        .init(temperature: 0.4,
              systemPrompt: "Act like a Career Advisor")
    }
    
    public var command: any BasicCommand {
        SystemCommand(value: Prompts.jobs.rawValue.lowercased())
    }
}

extension Prompts.Jobs {
    public var subCommands: [any AnySubcommand] {
        [
            SubjectSubcommand(),
            ResearchSubcommand()
        ]
    }
    
    public struct SubjectSubcommand: AnySubcommand {
        public var id: String {
            "subject"
        }
        
        public var values: [SubcommandValue] {
            [
                .init(id: "research",
                      value: "",
                      isSubCommandConditional: true,
                      ignoresBasePrompt: true,
                      additionalHelperText: ""),
                .init(id: "cover letter",
                      value: """
                        Provide a template for a cover letter using a resume and a job description as a reference. The resume will be provided with this flag, within the double quotes and after the equal sign \"\(Prompts.Subcommand.file)\".
                        
                        The user prompt will be a job description and use it as a guide on how to reword it appropriately.
                        
                        Try to use the text from the user prompt to properly connect the resume to the employer's job description. Aligning skill sets that might align with what the job requires.
                        
                        Style the cover letter as an email template.
                        """,
                      acceptsFile: true,
                      ignoresBasePrompt: true,
                      acceptedFileExtensions: ["pdf"],
                      additionalHelperText: "Add a portion of your resume & paste a job description here",
                      fileMaxTokenCount: 1200,
                      fileDescription: "Resumé"),
                .init(id: "resumé",
                      value: """
                        Provide suggestions on how to reword this portion of a resume. The resume will be labeled with this flag, within the double quotes and after the equal sign \"\(Prompts.Subcommand.file)\".
                        
                        The user prompt will be a job description and use it as a guide on how to reword it appropriately.
                        
                        Try to use the text from the user prompt to properly connect the resume to the employer's job description. Aligning skill sets that might align with what the job requires.
                        """,
                      acceptsFile: true,
                      ignoresBasePrompt: true,
                      acceptedFileExtensions: ["pdf"],
                      additionalHelperText: "Add a portion of your resume & paste a job description here",
                      fileMaxTokenCount: 1200,
                      fileDescription: "Resumé")
            ]
        }
    }
    
    public struct ResearchSubcommand: AnySubcommand {
        public var id: String {
            "research"
        }
        
        public var subCommandConditional: String? {
            "subject"
        }
        
        public var values: [SubcommandValue] {
            [
                .init(id: "company",
                      value: """
                        The user prompt will be a company name or company url and use it as a guide on how to provide research notes of the company that helps in an interview process or job outreach.
                        
                        Can you also provide input on whether the company is currently hiring. If the user_prompt includes an industry or job role check for this role specifically.
                        
                        Can you provide a website link to their career page.
                        
                        Can you provide Dun & Bradstreet (https://www.dnb.com) metadata of key people.
                        """,
                      ignoresBasePrompt: true,
                      additionalHelperText: "Type a company name or website to receive research notes"),
                .init(id: "opportunity",
                      value: """
                        The user prompt will describe where the user works or what field, speciality, trade the user is in.
                        
                        Provide up to 20 suggestions on companies to research for potential jobs. These companies have a high likelihood or are known to be hiring for the job or speciality the user can work in.
                        
                        Of the 20 suggestions, up to 10 should be publicly traded companies and up to 10 should be start-ups. Each of these should be in seperate sections.
                        
                        Can you provide a company website link for each suggestion. Or a public crunchbase or linkedin link that leads to the company. At least one of these links should be provided. If the company is a publicly traded company add a Stock Ticker that matches said company.
                        
                        Each suggestion should inform an estimated company size as well.
                        """,
                      ignoresBasePrompt: true,
                      additionalHelperText: "Describe your professional title, job, or trade to find potential employers")
            ]
        }
    }
}

//
//  AboutView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2026/08/05.
//

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct AboutView: View {
  var body: some View {
    VStack(spacing: 16) {
#if os(macOS)
      Image(nsImage: appIcon)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 180, height: 180)
#else
      Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 180, height: 180)
#endif

      Text("ManyTime")
        .font(.headline)

      Text("Version \(version)")
        .font(.caption)
        .foregroundColor(.secondary)

      Text("Domenic Murtari")
        .font(.caption)
        .foregroundColor(.secondary)

      Link("https://codeberg.org/dmurtari/ManyTime", destination: repositoryURL!)
        .font(.caption)
        .focusable(false)
    }
    .padding()
    .frame(minWidth: 280)
  }

#if os(macOS)
  private var appIcon: NSImage {
    NSApplication.shared.applicationIconImage
  }
#endif

  private var version: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
  }

  private var buildNumber: String {
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
  }

  private var repositoryURL: URL? {
    return URL(string: "https://codeberg.org/dmurtari/ManyTime")
  }
}
#Preview {
  AboutView()
}

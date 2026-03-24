import Flutter
import UIKit
import UniformTypeIdentifiers

class FolderPickerPlugin: NSObject, FlutterPlugin, UIDocumentPickerDelegate {
  private var pendingResult: FlutterResult?

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "io.wormhole.app/folder_picker",
      binaryMessenger: registrar.messenger()
    )
    let instance = FolderPickerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "pickFolder" else {
      result(FlutterMethodNotImplemented)
      return
    }
    pendingResult = result

    let picker: UIDocumentPickerViewController
    if #available(iOS 14.0, *) {
      picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
    } else {
      picker = UIDocumentPickerViewController(documentTypes: ["public.folder"], in: .open)
    }
    picker.delegate = self
    picker.allowsMultipleSelection = false

    guard let root = UIApplication.shared.windows.first?.rootViewController else {
      result(FlutterError(code: "NO_CONTROLLER", message: "No root view controller", details: nil))
      return
    }
    root.present(picker, animated: true)
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let url = urls.first, let result = pendingResult else { return }
    pendingResult = nil

    let accessed = url.startAccessingSecurityScopedResource()
    defer { if accessed { url.stopAccessingSecurityScopedResource() } }

    do {
      let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent(url.lastPathComponent)
      if FileManager.default.fileExists(atPath: tempDir.path) {
        try FileManager.default.removeItem(at: tempDir)
      }
      try FileManager.default.copyItem(at: url, to: tempDir)
      result(tempDir.path)
    } catch {
      result(FlutterError(code: "COPY_FAILED", message: error.localizedDescription, details: nil))
    }
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    pendingResult?(nil)
    pendingResult = nil
  }
}

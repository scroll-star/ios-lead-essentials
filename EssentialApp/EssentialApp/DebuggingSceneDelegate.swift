//
//  DebuggingSceneDelegate.swift
//  EssentialApp
//
//  Created by Stoyan Kostov on 2.07.23.
//

#if DEBUG
    import EssentialFeed
    import UIKit

    final class DebuggingSceneDelegate: SceneDelegate {
        override func scene(
            _ scene: UIScene,
            willConnectTo session: UISceneSession,
            options connectionOptions: UIScene.ConnectionOptions
        ) {
            guard let _ = (scene as? UIWindowScene) else { return }

            if CommandLine.arguments.contains("-reset") {
                try? FileManager.default.removeItem(at: localStoreURL)
            }

            super.scene(scene, willConnectTo: session, options: connectionOptions)
        }

        override func makeRemoteClient() -> HTTPClient {
            if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
                return AlwaysFailingHTTPClient()
            }
            return super.makeRemoteClient()
        }
    }

    private class AlwaysFailingHTTPClient: HTTPClient {
        private class Task: HTTPClientTask {
            func cancel() {}
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(.failure(NSError(domain: "offline", code: 0)))
            return Task()
        }
    }
#endif
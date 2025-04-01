//
//  TradingChartView.swift
//  TradingViewChartTest
//
//  Created by Jiwon Yoon on 3/10/25.
//

import SwiftUI
import WebKit

struct TradingChartView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        loadHTML(in: webView)
        fetchUpbitData(for: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    private func loadHTML(in webView: WKWebView) {
        if let htmlPath = Bundle.main.path(forResource: "chart", ofType: "html") {
            let htmlURL = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL)
        } else {
            print("HTML file not found")
        }
    }

    private func fetchUpbitData(for webView: WKWebView) {
        // Upbit API 호출 (예시)
        let url = URL(string: "https://api.upbit.com/v1/candles/minutes/1?market=KRW-BTC&count=200")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching Upbit data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                let chartData = json?.map { item in
                    return [
                        "time": item["candle_date_time_utc"] as? String ?? "",
                        "open": item["opening_price"] as? Double ?? 0.0,
                        "high": item["high_price"] as? Double ?? 0.0,
                        "low": item["low_price"] as? Double ?? 0.0,
                        "close": item["trade_price"] as? Double ?? 0.0
                    ]
                } ?? []

                // JavaScript로 데이터 전달
                DispatchQueue.main.async {
                    let jsonData = try! JSONSerialization.data(withJSONObject: chartData, options: [])
                    let jsonString = String(data: jsonData, encoding: .utf8)!
                    let script = "setChartData(\(jsonString))"
                    webView.evaluateJavaScript(script) { result, error in
                        if let error = error {
                            print("Error evaluating JavaScript: \(error)")
                        }
                    }
                }
            } catch {
                print("Error parsing Upbit data: \(error)")
            }
        }.resume()
    }
}

final class Coordinator: NSObject, WKNavigationDelegate {
    var parent: TradingChartView

    init(parent: TradingChartView) {
        self.parent = parent
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WebView finished loading")
    }
}

#Preview {
    TradingChartView()
}

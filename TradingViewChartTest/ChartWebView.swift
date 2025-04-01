import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "fetchCandles")
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        context.coordinator.webView = webView
        webView.navigationDelegate = context.coordinator


        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        } else {
            print("Error: index.html not found in bundle")
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        let parent: WebView
        var webView: WKWebView?

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            fetchUpbitCandles { candles in
                guard let candles = candles else { return }
                let tradingViewData = convertToTradingViewFormat(candles: candles)
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: tradingViewData, options: [])
                    let jsonString = String(data: jsonData, encoding: .utf8)!
                    let script = "if (window.setChartData) { window.setChartData(\(jsonString)); }"
                    DispatchQueue.main.async {
                        self.webView?.evaluateJavaScript(script) { (result, error) in
                            if let error = error {
                                print("JavaScript Error: \(error)")
                            } else {
                                print("JavaScript executed successfully")
                            }
                        }
                    }
                } catch {
                    print("JSON Serialization Error: \(error)")
                }
            }
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("didReceive called with message: \(message.body)")
            fetchUpbitCandles { candles in
                guard let candles = candles else { return }
                let tradingViewData = convertToTradingViewFormat(candles: candles)
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: tradingViewData, options: [])
                    let jsonString = String(data: jsonData, encoding: .utf8)!
                    let script = "window.postMessage(\(jsonString), '*');"
                    DispatchQueue.main.async {
                        self.webView?.evaluateJavaScript(script) { (result, error) in
                            if let error = error {
                                print("JavaScript Error: \(error)")
                            } else {
                                print("JavaScript executed successfully")
                            }
                        }
                    }
                } catch {
                    print("JSON Serialization Error: \(error)")
                }
            }
        }
    }
}

// Upbit 캔들 데이터 모델과 함수 (이전과 동일)
struct Candle: Codable {
    let market: String
    let candleDateTimeKst: String
    let openingPrice: Double
    let highPrice: Double
    let lowPrice: Double
    let tradePrice: Double
    let timestamp: Int
    let candleAccTradeVolume: Double

    enum CodingKeys: String, CodingKey {
        case market
        case candleDateTimeKst = "candle_date_time_kst"
        case openingPrice = "opening_price"
        case highPrice = "high_price"
        case lowPrice = "low_price"
        case tradePrice = "trade_price"
        case timestamp
        case candleAccTradeVolume = "candle_acc_trade_volume"
    }
}

func fetchUpbitCandles(completion: @escaping ([Candle]?) -> Void) {
    let url = URL(string: "https://api.upbit.com/v1/candles/minutes/1?market=KRW-BTC&count=200")!

    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }

        do {
            let candles = try JSONDecoder().decode([Candle].self, from: data)
            completion(candles)
        } catch {
            print("Decoding error: \(error)")
            completion(nil)
        }
    }.resume()
}

func convertToTradingViewFormat(candles: [Candle]) -> [String: Any] {
    let times = candles.map { $0.timestamp / 1000 }
    let opens = candles.map { $0.openingPrice }
    let highs = candles.map { $0.highPrice }
    let lows = candles.map { $0.lowPrice }
    let closes = candles.map { $0.tradePrice }
    let volumes = candles.map { $0.candleAccTradeVolume }

    return [
        "s": "ok",
        "t": times,
        "o": opens,
        "h": highs,
        "l": lows,
        "c": closes,
        "v": volumes
    ]
}

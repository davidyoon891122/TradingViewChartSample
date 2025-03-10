//
//  TradingChartView.swift
//  TradingViewChartTest
//
//  Created by Jiwon Yoon on 3/10/25.
//

import SwiftUI
import LightweightCharts
import SnapKit

struct TradingChartView: UIViewRepresentable {

    func makeUIView(context: Context) -> some UIView {
        let chart = LightweightCharts()
        chart.delegate = context.coordinator

        setupChart(chart: chart)

        return chart
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    private func setupChart(chart: LightweightCharts) {
        let series: CandlestickSeries = chart.addCandlestickSeries(options: .none)

        let data = [
            CandlestickData(time: .string("2025-03-10 00:00:00"), open: 100.0, high: 120.0, low: 80.0, close: 92.0),
            CandlestickData(time: .string("2025-03-11 00:01:00"), open: 120.0, high: 140.0, low: 90.0, close: 50.0),
            CandlestickData(time: .string("2025-03-12 00:02:00"), open: 180.0, high: 120.0, low: 80.0, close: 92.0),
            CandlestickData(time: .string("2025-03-13 00:03:00"), open: 100.0, high: 120.0, low: 80.0, close: 92.0),
            CandlestickData(time: .string("2025-03-14 00:04:00"), open: 100.0, high: 120.0, low: 80.0, close: 92.0),
            CandlestickData(time: .string("2025-03-15 00:05:00"), open: 100.0, high: 120.0, low: 80.0, close: 92.0),
            CandlestickData(time: .string("2025-03-16 00:06:00"), open: 100.0, high: 120.0, low: 80.0, close: 92.0),
            CandlestickData(time: .string("2025-03-17 00:07:00"), open: 100.0, high: 120.0, low: 80.0, close: 92.0),
        ]

        series.setData(data: data)
    }

}


final class Coordinator: ChartDelegate {

    var parent: TradingChartView

    init(parent: TradingChartView) {
        self.parent = parent
    }


    func didClick(onChart chart: ChartApi, parameters: MouseEventParams) {
        print(chart)
    }
    
    func didCrosshairMove(onChart chart: ChartApi, parameters: MouseEventParams) {
        print(chart)
    }

}

#Preview {
    TradingChartView()
}

import Charts
import SwiftUI

struct StatsOverviewView: View {
    @Bindable var model: StatsOverviewModel

    var body: some View {
        ZStack {
            Color.rookBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: RookSpacing.l) {
                    periodPicker
                    headlineRow
                    chart
                    topGamesSection
                    allTimeFooter
                }
                .padding(.horizontal, RookSpacing.l)
                .padding(.vertical, RookSpacing.m)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.rookBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var periodPicker: some View {
        Picker("Period", selection: $model.period) {
            ForEach(StatsOverviewModel.Period.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }

    private var headlineRow: some View {
        HStack(spacing: RookSpacing.m) {
            tile(value: "\(model.totalPlays)", title: "Plays")
            tile(value: "\(model.totalMinutes / 60)h", title: "Total time")
            tile(value: "\(model.uniqueGames)", title: "Unique games")
        }
    }

    private func tile(value: String, title: String) -> some View {
        VStack(spacing: RookSpacing.xs) {
            Text(value)
                .rookFont(.title2)
                .foregroundStyle(LinearGradient.rookBrand)
            Text(title)
                .rookFont(.caption)
                .foregroundStyle(Color.rookForegroundSecondary)
        }
        .frame(maxWidth: .infinity)
        .rookCard(padding: RookSpacing.m, radius: RookRadius.m)
    }

    private var chart: some View {
        VStack(alignment: .leading, spacing: RookSpacing.s) {
            Text("Plays per day")
                .rookFont(.subheadline)
                .foregroundStyle(Color.rookForegroundSecondary)
                .textCase(.uppercase)
            Chart {
                ForEach(model.dailyBuckets) { bucket in
                    BarMark(
                        x: .value("Day", bucket.day, unit: .day),
                        y: .value("Plays", bucket.count)
                    )
                    .foregroundStyle(LinearGradient.rookBrand)
                    .cornerRadius(RookRadius.s)
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: chartStride)) { value in
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day(), centered: true)
                        .foregroundStyle(Color.rookForegroundTertiary)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel().foregroundStyle(Color.rookForegroundTertiary)
                    AxisGridLine().foregroundStyle(Color.rookSeparator)
                }
            }
            .rookCard()
        }
    }

    private var chartStride: Calendar.Component {
        switch model.period {
        case .week: .day
        case .month, .quarter: .weekOfYear
        case .year: .month
        }
    }

    @ViewBuilder
    private var topGamesSection: some View {
        VStack(alignment: .leading, spacing: RookSpacing.s) {
            Text("Top games")
                .rookFont(.subheadline)
                .foregroundStyle(Color.rookForegroundSecondary)
                .textCase(.uppercase)

            if model.topGames.isEmpty {
                Text("No plays in this period yet.")
                    .rookFont(.subheadline)
                    .foregroundStyle(Color.rookForegroundTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .rookCard()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(model.topGames.enumerated()), id: \.offset) { index, entry in
                        HStack {
                            Text("\(index + 1)")
                                .rookFont(.headline)
                                .foregroundStyle(LinearGradient.rookBrand)
                                .frame(width: 28, alignment: .leading)
                            Text(entry.game.name)
                                .rookFont(.body)
                                .foregroundStyle(Color.rookForeground)
                            Spacer()
                            Text("\(entry.count)")
                                .rookFont(.headline)
                                .monospacedDigit()
                                .foregroundStyle(Color.rookForeground)
                        }
                        .padding(.vertical, RookSpacing.s)
                        if index != model.topGames.count - 1 {
                            Divider().background(Color.rookSeparator)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .rookCard()
            }
        }
    }

    private var allTimeFooter: some View {
        HStack {
            Text("All-time plays")
                .rookFont(.subheadline)
                .foregroundStyle(Color.rookForegroundSecondary)
            Spacer()
            Text("\(model.allTimePlays)")
                .rookFont(.headline)
                .foregroundStyle(Color.rookForeground)
        }
        .rookCard(padding: RookSpacing.m, radius: RookRadius.m)
    }
}

import Charts
import SwiftUI

struct GameStatsView: View {
    @Bindable var model: GameStatsModel

    var body: some View {
        ZStack {
            Color.rookBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: RookSpacing.l) {
                    headline
                    chart
                    if let highest = model.highestScore {
                        scoreCard(highest: highest)
                    }
                }
                .padding(.horizontal, RookSpacing.l)
                .padding(.vertical, RookSpacing.m)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(model.game?.name ?? "Stats")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.rookBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var headline: some View {
        HStack(spacing: RookSpacing.m) {
            statTile(title: "Plays", value: "\(model.totalPlays)")
            statTile(title: "Avg time", value: model.totalPlays == 0 ? "—" : "\(model.averageMinutes)m")
            statTile(
                title: "Win rate",
                value: model.winRate.map { "\(Int(($0 * 100).rounded()))%" } ?? "—"
            )
        }
    }

    private func statTile(title: String, value: String) -> some View {
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
            Text("Plays per month")
                .rookFont(.subheadline)
                .foregroundStyle(Color.rookForegroundSecondary)
                .textCase(.uppercase)
            Chart {
                ForEach(model.monthlyPlays) { bucket in
                    BarMark(
                        x: .value("Month", bucket.month, unit: .month),
                        y: .value("Plays", bucket.count)
                    )
                    .foregroundStyle(LinearGradient.rookBrand)
                    .cornerRadius(RookRadius.s)
                }
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(values: .stride(by: .month, count: 2)) { value in
                    AxisValueLabel(format: .dateTime.month(.narrow), centered: true)
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

    private func scoreCard(highest: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: RookSpacing.xs) {
                Text("Highest score")
                    .rookFont(.subheadline)
                    .foregroundStyle(Color.rookForegroundSecondary)
                Text("\(highest)")
                    .rookFont(.title)
                    .foregroundStyle(Color.rookForeground)
            }
            Spacer()
            Image(systemName: "trophy.fill")
                .font(.system(size: 32))
                .foregroundStyle(LinearGradient.rookBrand)
        }
        .rookCard()
    }
}

import SwiftUI
import Charts

struct MoodStar: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let color: Color
    let size: CGFloat
    let glow: Double
}


struct AnalyticsView: View {
    @EnvironmentObject var moodStore: MoodStore
    @EnvironmentObject var userVM: UserViewModel

    @State private var selfMoods: [MoodEntry] = []          // your moods from CloudKit
    @State private var partnerMoods: [MoodEntry] = []
    @State private var isLoadingPartnerData = false
    @State private var isLoadingCoupleAnalytics = false

    private let calendar = Calendar.current

    // MARK: - Derived flags

    private var hasSelfData: Bool {
        !moodStore.entries.isEmpty
    }

    private var hasPartnerData: Bool {
        userVM.partner != nil && !partnerMoods.isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // Title
                    Text(NSLocalizedString("analytics_title", comment: ""))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.pink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                    overviewCard

                    moodHarmonySection    // 💞 NEW COUPLE ANALYTICS
                    moodGalaxySection

                    // Overview Card

                    if !hasSelfData && !hasPartnerData {
                        emptyState
                    } else {
                        // Self analytics
                        if hasSelfData {
                            selfAnalyticsSection
                        }

                        // Partner analytics
                        if let partner = userVM.partner {
                            partnerAnalyticsSection(partner: partner)
                        }
                    }

                }
                .padding()
            }
            .onAppear { loadCoupleAnalytics() }   // 👈 ADD THIS
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.96, blue: 0.99),
                        Color(red: 0.94, green: 0.98, blue: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadPartnerMoodsIfNeeded()
        }
    }

    // MARK: - Data loading

    private func loadPartnerMoodsIfNeeded() {
        guard let partner = userVM.partner else {
            partnerMoods = []
            return
        }

        isLoadingPartnerData = true

        CloudKitService.shared.fetchAllMoods(forOwnerId: partner.appleID) { entries in
            DispatchQueue.main.async {
                self.partnerMoods = entries
                self.isLoadingPartnerData = false
            }
        }
    }

    // MARK: - Overview Card

    private var overviewCard: some View {
        let totalMoods = moodStore.entries.count
        let last7Days = calendar.date(byAdding: .day, value: -7, to: Date())!
        let last7Count = moodStore.entries.filter { $0.date >= last7Days }.count

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("analytics_overview_title", comment: ""))
                        .font(.headline)
                        .foregroundColor(.purple)

                    if hasSelfData {
                        Text(
                            String(
                                format: NSLocalizedString("analytics_overview_logs", comment: ""),
                                totalMoods
                            )
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                        Text(
                            String(
                                format: NSLocalizedString("analytics_overview_last7", comment: ""),
                                last7Count
                            )
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    } else {
                        Text(NSLocalizedString("analytics_overview_empty", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Text("꒰ᐢ｡•༝•｡ᐢ꒱♡")
                    .font(.system(size: 34))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }

    // MARK: - Self Analytics Section

    private var selfAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(NSLocalizedString("analytics_self_section_title", comment: ""))
                .font(.title3.bold())
                .foregroundColor(.pink)

            moodPieChart

            weekBarChart

            moodInsights
        }
    }

    // Pie chart of your moods
    private var moodPieChart: some View {
        let moodCounts = MoodType.allCases.map { mood in
            (mood, moodStore.entries.filter { $0.moodType == mood }.count)
        }

        return VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("analytics_mood_ratio", comment: ""))
                .font(.headline)

            Chart {
                ForEach(moodCounts, id: \.0.id) { (mood, count) in
                    if count > 0 {
                        SectorMark(
                            angle: .value("Count", count),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(Color(hex: mood.colorHex))
                        .annotation(position: .overlay) {
                            if count > 0 {
                                Text(mood.emoji)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .frame(height: 260)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }

    // Weekly distribution of moods
    private var weekBarChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("analytics_weekly_trend", comment: ""))
                .font(.headline)

            Chart {
                let grouped = Dictionary(grouping: moodStore.entries) { weekdayName($0.date) }

                ForEach(grouped.keys.sorted(), id: \.self) { day in
                    let moods = grouped[day] ?? []
                    BarMark(
                        x: .value("Day", day),
                        y: .value("Count", moods.count)
                    )
                    .foregroundStyle(Color.pink.gradient)
                    .cornerRadius(4)
                }
            }
            .frame(height: 220)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }

    // Text-based self insights
    private var moodInsights: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("analytics_insight_title", comment: ""))
                .font(.headline)

            if moodStore.entries.isEmpty {
                Text(NSLocalizedString("analytics_insight_empty", comment: ""))
                    .foregroundColor(.gray)
            } else {
                Text(emojiInsight())
                    .font(.subheadline)
                    .foregroundColor(.black)

                Text(bestDayInsight())
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }

    // MARK: - Partner Analytics

    private func partnerAnalyticsSection(partner: PMUser) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text(NSLocalizedString("analytics_partner_section_title", comment: ""))
                    .font(.title3.bold())
                    .foregroundColor(.purple)

                if isLoadingPartnerData {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }

            if !hasPartnerData {
                Text(NSLocalizedString("analytics_partner_no_data", comment: ""))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                partnerSummaryCard(partner: partner)
                coupleComparisonChart
                coupleInsights
            }
        }
    }

    // Summary metrics for couple
    private func partnerSummaryCard(partner: PMUser) -> some View {
        let metrics = computeCoupleMetrics()

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(
                        String(
                            format: NSLocalizedString("analytics_partner_summary_title", comment: ""),
                            partner.displayName
                        )
                    )
                    .font(.headline)

                    if let sync = metrics.syncPercent {
                        Text(
                            String(
                                format: NSLocalizedString("analytics_partner_sync_days", comment: ""),
                                sync
                            )
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }

                    if let align = metrics.alignmentPercent {
                        Text(
                            String(
                                format: NSLocalizedString("analytics_partner_alignment", comment: ""),
                                align
                            )
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }

                    if let day = metrics.bestSharedDayName {
                        Text(
                            String(
                                format: NSLocalizedString("analytics_partner_best_day", comment: ""),
                                day
                            )
                        )
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }

                    if let mood = metrics.sharedTopMood {
                        Text(
                            String(
                                format: NSLocalizedString("analytics_partner_top_shared_mood", comment: ""),
                                "\(mood.emoji) \(mood.label)"
                            )
                        )
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Text("💞")
                    .font(.system(size: 40))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.97))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }

    // Line chart comparing mood scores
    private var coupleComparisonChart: some View {
        let points = coupleMoodPoints(limitDays: 14)

        return VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("analytics_partner_chart_title", comment: ""))
                .font(.headline)

            if points.isEmpty {
                Text(NSLocalizedString("analytics_partner_chart_empty", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Chart {
                    ForEach(points) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("MyMood", point.myScore)
                        )
                        .foregroundStyle(.pink)
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("PartnerMood", point.partnerScore)
                        )
                        .foregroundStyle(.purple)
                        .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value("Date", point.date),
                            yStart: .value("MyMood", point.myScore),
                            yEnd: .value("PartnerMood", point.partnerScore)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [
                                    Color.pink.opacity(0.1),
                                    Color.purple.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .frame(height: 260)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.97))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }

    // Text insights about couple dynamics
    private var coupleInsights: some View {
        let metrics = computeCoupleMetrics()

        return VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("analytics_partner_insight_title", comment: ""))
                .font(.headline)

            if !hasPartnerData {
                Text(NSLocalizedString("analytics_partner_insight_empty", comment: ""))
                    .foregroundColor(.gray)
            } else {
                Text(coupleMoodSummaryText(metrics: metrics))
                    .font(.subheadline)
                    .foregroundColor(.black)

                if let support = supportBalanceText() {
                    Text(support)
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.97))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("꒰ᐢ｡•༝•｡ᐢ꒱♡")
                .font(.system(size: 60))
            Text(NSLocalizedString("analytics_empty_title", comment: ""))
                .font(.headline)
                .foregroundColor(.gray)
            Text(NSLocalizedString("analytics_empty_subtitle", comment: ""))
                .foregroundColor(.pink)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helper: weekday name

    private func weekdayName(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current  // language-aware
        f.dateFormat = "EEE"
        return f.string(from: date)
    }

    // MARK: - Helper: self insights

    private func emojiInsight() -> String {
        let moodCounts = MoodType.allCases.map { mood in
            (mood, moodStore.entries.filter { $0.moodType == mood }.count)
        }

        guard let mostCommon = moodCounts.max(by: { $0.1 < $1.1 }), mostCommon.1 > 0 else {
            return NSLocalizedString("analytics_insight_no_dominant", comment: "")
        }

        return String(
            format: NSLocalizedString("analytics_insight_most_common", comment: ""),
            "\(mostCommon.0.emoji) \(mostCommon.0.label)"
        )
    }

    private func bestDayInsight() -> String {
        let grouped = Dictionary(grouping: moodStore.entries) { weekdayName($0.date) }

        guard let best = grouped.max(by: { $0.value.count < $1.value.count }) else {
            return NSLocalizedString("analytics_insight_bestday_unknown", comment: "")
        }

        return String(
            format: NSLocalizedString("analytics_insight_bestday", comment: ""),
            best.key
        )
    }

    // MARK: - Couple Metrics

    private struct CoupleMetrics {
        var syncPercent: Int?
        var alignmentPercent: Int?
        var bestSharedDayName: String?
        var sharedTopMood: MoodType?
    }

    private func computeCoupleMetrics() -> CoupleMetrics {
        guard hasSelfData, hasPartnerData else { return CoupleMetrics() }

        // Recent window
        let recentFrom = calendar.date(byAdding: .day, value: -60, to: Date()) ?? Date.distantPast

        let myRecent = moodStore.entries.filter { $0.date >= recentFrom }
        let partnerRecent = partnerMoods.filter { $0.date >= recentFrom }

        let myByDay = Dictionary(grouping: myRecent, by: { calendar.startOfDay(for: $0.date) })
            .compactMapValues { $0.first }     // one per day
        let partnerByDay = Dictionary(grouping: partnerRecent, by: { calendar.startOfDay(for: $0.date) })
            .compactMapValues { $0.first }

        let allDays = Set(myByDay.keys).union(partnerByDay.keys)
        let syncDays = allDays.filter { myByDay[$0] != nil && partnerByDay[$0] != nil }

        // Sync percent
        var syncPercent: Int? = nil
        if !allDays.isEmpty {
            let ratio = Double(syncDays.count) / Double(allDays.count)
            syncPercent = Int((ratio * 100).rounded())
        }

        // Alignment percent
        var alignmentPercent: Int? = nil
        if !syncDays.isEmpty {
            var totalScore: Double = 0
            for day in syncDays {
                let m1 = myByDay[day]!.moodType
                let m2 = partnerByDay[day]!.moodType
                let diff = abs(moodScore(m1) - moodScore(m2))
                // 0 diff => 1.0, 6+ diff => 0.0
                let maxDiff = 6.0
                let score = max(0.0, 1.0 - Double(diff) / maxDiff)
                totalScore += score
            }
            let avg = totalScore / Double(syncDays.count)
            alignmentPercent = Int((avg * 100).rounded())
        }

        // Best shared weekday
        var bestSharedDay: String? = nil
        if !syncDays.isEmpty {
            let groupedByWeekday = Dictionary(grouping: syncDays) { weekdayName($0) }
            let bestDay = groupedByWeekday.max(by: { $0.value.count < $1.value.count })
            bestSharedDay = bestDay?.key
        }

        // Most common shared mood (same mood both)
        var sharedTopMood: MoodType? = nil
        if !syncDays.isEmpty {
            var counts: [MoodType: Int] = [:]
            for day in syncDays {
                let m1 = myByDay[day]!.moodType
                let m2 = partnerByDay[day]!.moodType
                if m1 == m2 {
                    counts[m1, default: 0] += 1
                }
            }
            if let top = counts.max(by: { $0.value < $1.value }) {
                sharedTopMood = top.key
            }
        }

        return CoupleMetrics(
            syncPercent: syncPercent,
            alignmentPercent: alignmentPercent,
            bestSharedDayName: bestSharedDay,
            sharedTopMood: sharedTopMood
        )
    }

    // Score scale for moods (for comparison)
    private func moodScore(_ mood: MoodType) -> Int {
        switch mood {
        case .veryHappy: return 3
        case .happy:     return 2
        case .calm:      return 1
        case .okay:      return 0
        case .tired:     return -1
        case .sad:       return -2
        case .angry:     return -3
        }
    }

    // MARK: - Couple comparison points (for chart)

    private struct CoupleMoodPoint: Identifiable {
        let id = UUID()
        let date: Date
        let myScore: Double
        let partnerScore: Double
    }

    private func coupleMoodPoints(limitDays: Int) -> [CoupleMoodPoint] {
        guard hasSelfData, hasPartnerData else { return [] }

        let from = calendar.date(byAdding: .day, value: -limitDays, to: Date()) ?? Date.distantPast

        let myRecent = moodStore.entries.filter { $0.date >= from }
        let partnerRecent = partnerMoods.filter { $0.date >= from }

        let myByDay = Dictionary(grouping: myRecent, by: { calendar.startOfDay(for: $0.date) })
            .compactMapValues { $0.first }
        let partnerByDay = Dictionary(grouping: partnerRecent, by: { calendar.startOfDay(for: $0.date) })
            .compactMapValues { $0.first }

        let syncDays = Set(myByDay.keys).intersection(partnerByDay.keys).sorted()

        return syncDays.map { day in
            let my = myByDay[day]!.moodType
            let partner = partnerByDay[day]!.moodType

            return CoupleMoodPoint(
                date: day,
                myScore: Double(moodScore(my)),
                partnerScore: Double(moodScore(partner))
            )
        }
    }

    // MARK: - Couple textual Insight helpers

    private func coupleMoodSummaryText(metrics: CoupleMetrics) -> String {
        guard let sync = metrics.syncPercent,
              let align = metrics.alignmentPercent else {
            return NSLocalizedString("analytics_partner_insight_generic", comment: "")
        }

        return String(
            format: NSLocalizedString("analytics_partner_insight_summary", comment: ""),
            sync,
            align
        )
    }

    private func supportBalanceText() -> String? {
        guard hasSelfData, hasPartnerData else { return nil }

        let myLowDays = lowMoodDays(in: moodStore.entries)
        let partnerLowDays = lowMoodDays(in: partnerMoods)

        if myLowDays == 0 && partnerLowDays == 0 {
            return nil
        }

        if partnerLowDays > myLowDays {
            return NSLocalizedString("analytics_partner_support_partner", comment: "")
        } else if myLowDays > partnerLowDays {
            return NSLocalizedString("analytics_partner_support_you", comment: "")
        } else {
            return NSLocalizedString("analytics_partner_support_balanced", comment: "")
        }
    }

    private func lowMoodDays(in entries: [MoodEntry]) -> Int {
        let byDay = Dictionary(grouping: entries, by: { calendar.startOfDay(for: $0.date) })
            .compactMapValues { $0.first }

        return byDay.values.filter { entry in
            switch entry.moodType {
            case .sad, .tired, .angry:
                return true
            default:
                return false
            }
        }.count
    }
    
    private func loadCoupleAnalytics() {
        // Need both user and partner
        guard let user = userVM.user,
              let partner = userVM.partner else {
            return
        }

        isLoadingCoupleAnalytics = true

        let group = DispatchGroup()
        var selfResults: [MoodEntry] = []
        var partnerResults: [MoodEntry] = []

        group.enter()
        CloudKitService.shared.fetchAllMoods(forOwnerId: user.appleID) { entries in
            selfResults = entries
            group.leave()
        }

        group.enter()
        CloudKitService.shared.fetchAllMoods(forOwnerId: partner.appleID) { entries in
            partnerResults = entries
            group.leave()
        }

        group.notify(queue: .main) {
            self.selfMoods = selfResults
            self.partnerMoods = partnerResults
            self.isLoadingCoupleAnalytics = false
        }
    }
    
    /// 0.0 ... 1.0 harmony
    private func harmonyScore() -> Double? {
        guard !selfMoods.isEmpty, !partnerMoods.isEmpty else { return nil }

        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"

        let selfByDay = Dictionary(grouping: selfMoods, by: { f.string(from: $0.date) })
        let partnerByDay = Dictionary(grouping: partnerMoods, by: { f.string(from: $0.date) })

        let commonDays = Set(selfByDay.keys).intersection(partnerByDay.keys)
        guard !commonDays.isEmpty else { return nil }

        var total: Double = 0
        var count: Double = 0

        for day in commonDays {
            guard let myMood = selfByDay[day]?.first,
                  let partnerMood = partnerByDay[day]?.first else { continue }

            let diff = abs(myMood.moodType.score - partnerMood.moodType.score) // 0…4
            let dayScore = max(0, 1.0 - Double(diff) / 4.0) // 1.0 = same, 0 = opposite

            total += dayScore
            count += 1
        }

        guard count > 0 else { return nil }
        return total / count // 0…1
    }

    private func harmonyLabel(for score: Double) -> String {
        switch score {
        case 0.85...1.0:
            return NSLocalizedString("analytics_harmony_label_perfect", comment: "")
        case 0.65..<0.85:
            return NSLocalizedString("analytics_harmony_label_good", comment: "")
        case 0.45..<0.65:
            return NSLocalizedString("analytics_harmony_label_soft", comment: "")
        case 0.25..<0.45:
            return NSLocalizedString("analytics_harmony_label_mix", comment: "")
        default:
            return NSLocalizedString("analytics_harmony_label_journey", comment: "")
        }
    }

    private func harmonySubtext(for score: Double) -> String {
        switch score {
        case 0.85...1.0:
            return NSLocalizedString("analytics_harmony_sub_perfect", comment: "")
        case 0.65..<0.85:
            return NSLocalizedString("analytics_harmony_sub_good", comment: "")
        case 0.45..<0.65:
            return NSLocalizedString("analytics_harmony_sub_soft", comment: "")
        case 0.25..<0.45:
            return NSLocalizedString("analytics_harmony_sub_mix", comment: "")
        default:
            return NSLocalizedString("analytics_harmony_sub_journey", comment: "")
        }
    }

    private var moodHarmonySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(NSLocalizedString("analytics_harmony_title", comment: ""))
                    .font(.headline)
                Spacer()
                if isLoadingCoupleAnalytics {
                    ProgressView()
                }
            }

            if let score = harmonyScore() {
                let percent = Int((score * 100).rounded())

                HStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .stroke(Color.pink.opacity(0.18), lineWidth: 12)

                        Circle()
                            .trim(from: 0, to: score)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        Color.pink,
                                        Color.purple,
                                        Color.blue,
                                        Color.pink
                                    ]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 4) {
                            Text("\(percent)%")
                                .font(.system(size: 30, weight: .bold))
                            Text(harmonyLabel(for: score))
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(width: 150, height: 150)

                    Text(harmonySubtext(for: score))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            } else {
                Text(NSLocalizedString("analytics_harmony_empty", comment: ""))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .shadow(radius: 5)
        )
    }
    private var moodGalaxySection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(NSLocalizedString("analytics_galaxy_title", comment: ""))
                .font(.headline)
                .foregroundColor(.purple)

            Text(NSLocalizedString("analytics_galaxy_subtitle", comment: ""))
                .font(.footnote)
                .foregroundColor(.secondary)

            let moodStars = generateGalaxyStars(limitDays: 40)
            let skyStars = generateBackgroundStars()

            ZStack {
                // Background sky stars
                ForEach(0..<skyStars.count, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.3...1.0)))
                        .frame(width: CGFloat.random(in: 1...2),
                               height: CGFloat.random(in: 1...2))
                        .position(x: skyStars[i].x, y: skyStars[i].y)
                        .opacity(Double.random(in: 0.5...1.0))
                        .animation(.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(), value: UUID())
                }

                // Nebula fog
                nebulaGradient
                    .blur(radius: 40)
                    .opacity(0.8)

                // Actual mood stars (from real data)
                ForEach(moodStars) { star in
                    Circle()
                        .fill(star.color)
                        .frame(width: star.size, height: star.size)
                        .position(x: star.x, y: star.y)
                        .shadow(color: star.color.opacity(star.glow),
                                radius: star.size * 2)
                        .opacity(Double.random(in: 0.8...1.0))
                        .animation(
                            .easeInOut(duration: Double.random(in: 1.3...2.8))
                                .repeatForever(),
                            value: UUID()
                        )
                }
            }
            .frame(height: 280)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black)   // fully black sky
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.96))
                .shadow(radius: 4)
        )
    }

    private func generateGalaxyStars(limitDays: Int) -> [MoodStar] {
        guard hasSelfData, hasPartnerData else { return [] }

        let recent = calendar.date(byAdding: .day, value: -limitDays, to: Date())!

        let myRecent = moodStore.entries.filter { $0.date >= recent }
        let partnerRecent = partnerMoods.filter { $0.date >= recent }

        let byDayMy = Dictionary(grouping: myRecent, by: { calendar.startOfDay(for: $0.date) })
            .compactMapValues { $0.first }
        let byDayPartner = Dictionary(grouping: partnerRecent, by: { calendar.startOfDay(for: $0.date) })
            .compactMapValues { $0.first }

        let sharedDays = Set(byDayMy.keys).intersection(byDayPartner.keys)
        if sharedDays.isEmpty { return [] }

        return sharedDays.compactMap { day in
            guard let my = byDayMy[day], let partner = byDayPartner[day] else { return nil }

            let diff = abs(my.moodType.score - partner.moodType.score) // 0…4

            // Position in galaxy
            let x = CGFloat.random(in: 20...330)
            let y = CGFloat.random(in: 20...240)

            // Color blend
            let color = Color(
                red: 1.0 - Double(diff) * 0.15,
                green: 0.6 - Double(diff) * 0.1,
                blue: 1.0
            )

            return MoodStar(
                x: x,
                y: y,
                color: color,
                size: CGFloat.random(in: 4...(10 - CGFloat(diff))),
                glow: diff == 0 ? 0.8 : 0.3
            )
        }
    }
    private func generateBackgroundStars(count: Int = 250) -> [CGPoint] {
        (0..<count).map { _ in
            CGPoint(
                x: CGFloat.random(in: 0...350),
                y: CGFloat.random(in: 0...260)
            )
        }
    }
    private var nebulaGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.purple.opacity(0.25),
                Color.blue.opacity(0.20),
                Color.black.opacity(0.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }


}

// MARK: - Preview
//
//#Preview {
//    AnalyticsView()
//        .environmentObject(MoodStore())
//        .environmentObject(UserViewModel())
//}

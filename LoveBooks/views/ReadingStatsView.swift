//
//  ReadingStatsView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 3/6/25.
//

import SwiftUI

struct ReadingStatsView: View {
    @State private var currentMonthGoal: MonthlyGoal?
        @State private var yearlyStats: YearlyStats?
        @State private var booksReadThisMonth: Int = 0
        @State private var showGoalEditor = false
        @State private var newGoalValue: Int = 5

        @State private var userBooksVM = UserBooksViewModel()

        let currentMonthYear: String = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            return formatter.string(from: Date())
        }()
        
        let currentYear = Calendar.current.component(.year, from: Date())

        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    Text("📚 Tu progreso de lectura")
                        .font(.title2)
                        .bold()

                    // 🌙 Tarjeta con glassmorphism y progreso circular
                    ZStack {
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .background(
                                LinearGradient(colors: [.pink.opacity(0.3), .purple.opacity(0.4)],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                            .blur(radius: 1)
                            .shadow(radius: 10)
                        
                        VStack(spacing: 12) {
                            Text("Meta mensual")
                                .font(.headline)
                                .foregroundColor(.white)

                            if let goal = currentMonthGoal {
                                CircularProgressView(current: booksReadThisMonth, total: goal.goal)
                                    .frame(width: 120, height: 120)

                                Text("Leídos: \(booksReadThisMonth) / \(goal.goal)")
                                    .foregroundColor(.white.opacity(0.8))

                                Button("Editar meta") {
                                    showGoalEditor = true
                                    newGoalValue = goal.goal
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                            } else {
                                Text("No tienes una meta aún")
                                    .foregroundColor(.white.opacity(0.8))
                                Button("Crear meta") {
                                    showGoalEditor = true
                                }
                                .foregroundColor(.white)
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)

                    // 🏆 Tarjeta anual con trofeo
                    ZStack {
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(
                                AngularGradient(gradient: Gradient(colors: [.mint, .blue.opacity(0.5)]),
                                                center: .center)
                            )
                            .shadow(radius: 6)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)

                            Text("Libros leídos en \(currentYear)")
                                .font(.headline)
                                .foregroundColor(.white)

                            Text("\(yearlyStats?.booksRead ?? 0) 📖")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .task {
                await loadStats()
            }
            .sheet(isPresented: $showGoalEditor) {
                VStack(spacing: 20) {
                    Text("📌 Nueva meta")
                        .font(.headline)
                    Stepper("Libros: \(newGoalValue)", value: $newGoalValue, in: 1...30)
                        .padding()

                    Button("Guardar") {
                        Task {
                            let goal = MonthlyGoal(id: currentMonthYear, goal: newGoalValue)
                            await userBooksVM.saveMonthlyGoal(goal)
                            currentMonthGoal = goal
                            showGoalEditor = false
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Cancelar", role: .cancel) {
                        showGoalEditor = false
                    }
                }
                .padding()
            }
        }

        func loadStats() async {
            currentMonthGoal = await userBooksVM.getMonthlyGoal(for: currentMonthYear)
            yearlyStats = await userBooksVM.getYearlyStats(for: currentYear)

            let books = await userBooksVM.fetchBooksByStatus("read")
            booksReadThisMonth = books.filter {
                Calendar.current.isDate($0.dateAdded, equalTo: Date(), toGranularity: .month)
            }.count
        }
    }

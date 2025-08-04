// RecipesView.swift
// Depends on: Recipe (Models/Recipe.swift), AppState (ViewModels/AppState.swift)
import SwiftUI

struct RecipesView: View {
    var selectedMealType: String?
    var selectedDate: Date
    var onAddToPlan: (Recipe) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var isRefreshing = false
    @State private var selectedRecipe: Recipe? = nil
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 0)]
    
    // Filter out recipes that are already in the current day's meals
    private var availableRecipes: [Recipe] {
        let plan = appState.mealPlan(for: selectedDate)
        let usedRecipeIds = Set([
            plan.breakfast?.id,
            plan.lunch?.id,
            plan.dinner?.id
        ].compactMap { $0 })
        
        return appState.recipes.filter { recipe in
            !usedRecipeIds.contains(recipe.id)
        }
    }
    
    // Separate favorites and other recipes
    private var favoriteRecipes: [Recipe] {
        return availableRecipes.filter { appState.isFavorite($0) }
    }
    
    private var otherRecipes: [Recipe] {
        return availableRecipes.filter { !appState.isFavorite($0) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header
            HStack {
                Button(action: { dismiss() }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "chevron.down")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.black)
                        )
                }
                Spacer()
                Text("Recipes")
                    .font(.custom("Nunito-Bold", size: 16))
                    .foregroundColor(Color(red: 0.16, green: 0.17, blue: 0.18))
                Spacer()
                Button(action: {
                    Task {
                        isRefreshing = true
                        await appState.fetchRecipes()
                        isRefreshing = false
                    }
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.black)
                                .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                                .animation(isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)
            .background(Color.clear)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Favorites Section
                    if !favoriteRecipes.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("FAVOURITES")
                                    .font(.custom("Inter-Regular", size: 15))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(favoriteRecipes.count) recipes")
                                    .font(.custom("Inter-Regular", size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 16)
                            
                            LazyVGrid(columns: columns, spacing: 24) {
                                ForEach(favoriteRecipes) { recipe in
                                    RecipeCard(
                                        recipe: recipe,
                                        onTap: { selectedRecipe = recipe },
                                        onFavoriteToggle: { appState.toggleFavorite(for: recipe) }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Other Recipes Section
                    if !otherRecipes.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("TOP RECIPES")
                                    .font(.custom("Inter-Regular", size: 15))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(otherRecipes.count) recipes")
                                    .font(.custom("Inter-Regular", size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 16)
                            
                            LazyVGrid(columns: columns, spacing: 24) {
                                ForEach(otherRecipes) { recipe in
                                    RecipeCard(
                                        recipe: recipe,
                                        onTap: { selectedRecipe = recipe },
                                        onFavoriteToggle: { appState.toggleFavorite(for: recipe) }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Empty State
                    if availableRecipes.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No available recipes")
                                .font(.custom("Nunito-Bold", size: 18))
                                .foregroundColor(.gray)
                            Text("All recipes are already in today's plan")
                                .font(.custom("Inter-Regular", size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 100)
                    }
                }
            }
            .padding(.top, 8)
        }
        .background(Color(red: 0.97, green: 0.97, blue: 0.97).ignoresSafeArea())
        .sheet(item: $selectedRecipe) { recipe in
            RecipeDetailsView(recipe: recipe, appState: appState, onAddToPlan: onAddToPlan)
        }
    }
}

// MARK: - Recipe Card Component
struct RecipeCard: View {
    let recipe: Recipe
    let onTap: () -> Void
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    ZStack(alignment: .bottomLeading) {
                        // Recipe image or placeholder
                        if let imageURL = recipe.imageURL, !imageURL.isEmpty {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(red: 0.93, green: 0.94, blue: 0.95))
                                    .overlay(
                                        Image(systemName: "fork.knife")
                                            .font(.system(size: 32))
                                            .foregroundColor(.gray)
                                    )
                            }
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .clipped()
                            .cornerRadius(20)
                        } else {
                            // Fallback placeholder
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.93, green: 0.94, blue: 0.95))
                                .aspectRatio(1, contentMode: .fit)
                                .overlay(
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 32))
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        // Time and calories overlay
                        HStack(spacing: 8) {
                            Text("\(recipe.prepTime) min")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(12)
                            Text("\(recipe.calories) Cal")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        .padding(12)
                    }
                    
                    // Heart icon in top right corner
                    HeartIcon(isFavorite: recipe.isFavorite) {
                        onFavoriteToggle()
                    }
                    .padding(12)
                }
                
                Text(recipe.name)
                    .font(.custom("Nunito-Bold", size: 18))
                    .foregroundColor(.black)
                    .lineLimit(2)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
} 
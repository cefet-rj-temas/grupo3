import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def compute_payoffs(R, LR, Cs, I, L, alpha, Ca, G, P):
    # Conflict Scenarios (Judicial Bet)
    g1 = P * (R - LR - Cs - G) + (1 - P) * (-Cs)   # Consortium expected payoff if fighting
    g2 = (1 - P) * (I - Ca) + P * (I - L + G - Ca) # Surf expected payoff if fighting

    # Construct the 2x2 Game Matrix
    matrix_tbl = pd.DataFrame({
        'offshore_action': ["Implement", "Implement", "Withdraw", "Withdraw"],
        'surf_action': ["Accept", "Fight", "Accept", "Fight"],
        'offshore_payoff': [R, g1, 0, 0],
        'surf_payoff': [I - L, g2, I, I - alpha * Ca],
        'G_scenario': G
    })

    # Rationality and Equilibrium Evaluation
    matrix_tbl['better_for_offshore'] = [
        matrix_tbl['offshore_payoff'][0] >= matrix_tbl['offshore_payoff'][2], # If Surf accepts: Implement >= Withdraw?
        matrix_tbl['offshore_payoff'][1] >= matrix_tbl['offshore_payoff'][3], # If Surf fights: Implement >= Withdraw?
        matrix_tbl['offshore_payoff'][2] >= matrix_tbl['offshore_payoff'][0], # Inverse
        matrix_tbl['offshore_payoff'][3] >= matrix_tbl['offshore_payoff'][1]  # Inverse
    ]

    matrix_tbl['better_for_surf'] = [
        matrix_tbl['surf_payoff'][0] >= matrix_tbl['surf_payoff'][1], # If Plant implements: Accept >= Fight?
        matrix_tbl['surf_payoff'][1] >= matrix_tbl['surf_payoff'][0], # Inverse
        matrix_tbl['surf_payoff'][2] >= matrix_tbl['surf_payoff'][3], # If Plant withdraws: Accept >= Fight?
        matrix_tbl['surf_payoff'][3] >= matrix_tbl['surf_payoff'][2]  # Inverse
    ]

    # Nash Equilibrium occurs when NO player has an incentive to unilaterally deviate
    matrix_tbl['is_nash'] = matrix_tbl['better_for_offshore'] & matrix_tbl['better_for_surf']

    return matrix_tbl[matrix_tbl['is_nash'] == True]

def main():
    print("--- Compensation Sensitivity Analysis Configuration (G) ---")
    R = float(input("Enter Consortium Return (R): "))
    LR = float(input("Enter Return Loss due to delay (LR): "))
    Cs = float(input("Enter Consortium Judicial Cost (Cs): "))
    I = float(input("Enter Surf Initial Income (I): "))
    L = float(input("Enter Local Economic Loss (L): "))
    alpha = float(input("Enter alpha factor (Pre-conflict mobilization): "))
    Ca = float(input("Enter Surf Judicial Cost (Ca): "))
    P = float(input("Enter fixed Probability of Plant winning (P) [0 to 1]: "))

    # numpy.linspace is used here to generate a uniform 1D sequence of 20 values for G.
    # It creates a grid of compensation offers ranging from 0 up to 50% above the local loss (L * 1.5).
    g_range = np.linspace(0, L * 1.5, 20)
    
    print(f"\nRunning analysis for G varying from 0 to {g_range.max():.2f}...")

    # Map the function for each G value and stack the results
    mapa_sensibilidade_G = pd.concat(
        [compute_payoffs(R, LR, Cs, I, L, alpha, Ca, g, P) for g in g_range], 
        ignore_index=True
    )

    print("\n--- Reality Check: G Sensitivity ---")
    print(mapa_sensibilidade_G[['G_scenario', 'offshore_action', 'surf_action']])

    # Preparation for Plotting
    # We use numpy.linspace with 100 points to ensure the plot lines are smooth
    p_range_grafico = np.linspace(0, L * 1.5, 100)

    dados_plot = pd.DataFrame({'G': p_range_grafico})
    dados_plot['Accept'] = I - L                                    # Payoff if surrendering to Agreement
    dados_plot['Fight'] = (1 - P) * (I - Ca) + P * (I - L + dados_plot['G'] - Ca) # Expected Payoff in a Fight (g2)

    # Exact algebraic calculation where the rational decision changes (Accept == Fight)
    if P > 0:
        G_point = (Ca - L * (1 - P)) / P
    else:
        G_point = float('inf')

    # Rendering the Plot
    plt.figure(figsize=(8, 6))
    plt.plot(dados_plot['G'], dados_plot['Accept'], color='black', linestyle='dashed', linewidth=2, label='Agreement')
    plt.plot(dados_plot['G'], dados_plot['Fight'], color='dimgray', linestyle='solid', linewidth=2, label='Fight')

    plt.title(f"Sensitivity of Compensation Offer (G) for P = {P}", fontsize=14, fontweight='bold', fontfamily='serif')
    plt.suptitle("Payoff Intersection for Stakeholders (Surf Community)", fontsize=11, color='gray', fontfamily='serif', y=0.92)
    plt.xlabel("Compensation Offer Value (G)", fontsize=12, fontfamily='serif')
    plt.ylabel("Expected Payoff of the Surf Community", fontsize=12, fontfamily='serif')
    
    # Legend settings
    plt.legend(title="Rational Decision", loc='lower center', bbox_to_anchor=(0.5, -0.2), ncol=2, frameon=True, edgecolor='black')

    plt.grid(which='major', color='lightgray', linestyle='-')
    plt.minorticks_off()

    # Annotation logic for the Change Point
    if not np.isinf(G_point) and G_point >= 0:
        plt.plot(G_point, I - L, marker='o', markersize=8, markerfacecolor='white', markeredgecolor='black', markeredgewidth=1.5)
        
        # Calculate an offset for the text annotation to not overlap the point
        y_offset = (dados_plot['Fight'].max() - dados_plot['Fight'].min()) * 0.05
        plt.annotate(f"Price of Peace: G = {G_point:.2f}",
                     xy=(G_point, I - L),
                     xytext=(G_point + (g_range.max() * 0.02), I - L - y_offset), 
                     fontfamily='serif', fontsize=10)
    else:
        print("\n[Warning] The Change Point (G) is negative. Agreement dominates Fight in all realistic scenarios.")

    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    main()

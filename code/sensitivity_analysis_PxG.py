import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import itertools
from matplotlib.patches import Patch

def get_nash_equilibrium(R, LR, Cs, I, L, alpha, Ca, G, P):
    # Expected utility calculation under uncertainty (judicial litigation scenario)
    g1 = P * (R - LR - Cs - G) + (1 - P) * (-Cs)
    g2 = (1 - P) * (I - Ca) + P * (I - L + G - Ca)

    # Simultaneous game representation in normal form (Normal-form game)
    matrix_tbl = pd.DataFrame({
        'offshore_action': ["Implement", "Implement", "Withdraw", "Withdraw"],
        'surf_action': ["Accept", "Fight", "Accept", "Fight"],
        'offshore_payoff': [R, g1, 0, 0],
        'surf_payoff': [I - L, g2, I, I - alpha * Ca]
    })

    # Best Response Functions evaluation
    better_for_offshore = [
        matrix_tbl['offshore_payoff'][0] >= matrix_tbl['offshore_payoff'][2],
        matrix_tbl['offshore_payoff'][1] >= matrix_tbl['offshore_payoff'][3],
        matrix_tbl['offshore_payoff'][2] >= matrix_tbl['offshore_payoff'][0],
        matrix_tbl['offshore_payoff'][3] >= matrix_tbl['offshore_payoff'][1]
    ]

    better_for_surf = [
        matrix_tbl['surf_payoff'][0] >= matrix_tbl['surf_payoff'][1],
        matrix_tbl['surf_payoff'][1] >= matrix_tbl['surf_payoff'][0],
        matrix_tbl['surf_payoff'][2] >= matrix_tbl['surf_payoff'][3],
        matrix_tbl['surf_payoff'][3] >= matrix_tbl['surf_payoff'][2]
    ]

    # Intersection of best responses defines the Nash Equilibrium
    is_nash = [o and s for o, s in zip(better_for_offshore, better_for_surf)]
    matrix_tbl['is_nash'] = is_nash
    
    # Record input parameters for full traceability
    matrix_tbl['R'] = R
    matrix_tbl['LR'] = LR
    matrix_tbl['Cs'] = Cs
    matrix_tbl['I'] = I
    matrix_tbl['L'] = L
    matrix_tbl['alpha'] = alpha
    matrix_tbl['Ca'] = Ca
    matrix_tbl['G_scenario'] = G
    matrix_tbl['P_scenario'] = P

    nash_cenario = matrix_tbl[matrix_tbl['is_nash']]

    # Verification of existence of Equilibrium in Pure Strategies
    if nash_cenario.empty:
        eq_string = "Absence of Pure Equilibrium"
    else:
        # Select the first occurrence in case of multiplicity
        nash_row = nash_cenario.iloc[0] 
        eq_string = f"{nash_row['offshore_action']} / {nash_row['surf_action']}"
        
    return matrix_tbl, eq_string

def main():
    print("--- 2D Model Parameters (P vs G) ---")
    R = float(input("Consortium Expected Return (R): "))
    LR = float(input("Opportunity cost due to project delay (LR): "))
    Cs = float(input("Consortium judicial/transaction costs (Cs): "))
    I = float(input("Stakeholders base economic revenue (I): "))
    L = float(input("Estimated local economic impact (L): "))
    alpha = float(input("Mobilization cost coefficient (alpha): "))
    Ca = float(input("Stakeholders judicial/transaction costs (Ca): "))

    # Discretization of the parameter space (100 levels per variable)
    # numpy.linspace generates a 1D uniform sequence for both parameters
    p_grid = np.linspace(0, 1, 100)
    g_grid = np.linspace(0, L * 1.5, 100)

    # itertools.product is used to calculate the Cartesian Product between the two lists.
    # It creates a 2D grid matrix of scenarios (n = 10,000) containing every possible combination of P and G.
    grade_cenarios = list(itertools.product(p_grid, g_grid))
    
    print(f"\nComputing {len(grade_cenarios)} analytical iterations...")

    # Batch computational evaluation: apply the equilibrium function over the parametric space matrix
    equilibria = []
    all_matrices = []
    for P_val, G_val in grade_cenarios:
        matrix, eq = get_nash_equilibrium(R, LR, Cs, I, L, alpha, Ca, G_val, P_val)
        equilibria.append({'P': P_val, 'G': G_val, 'Equilibrium': eq})
        all_matrices.append(matrix)
    
    dados_heatmap = pd.DataFrame(equilibria)

    print("\nSaving full traceability data (this might take a few seconds)...")
    mapa_sensibilidade_PxG = pd.concat(all_matrices, ignore_index=True)
    csv_filename = "traceability_sensitivity_PxG.csv"
    mapa_sensibilidade_PxG.to_csv(csv_filename, index=False)
    print(f"[Info] Full traceability data saved to {csv_filename}")

    # Visualization: Heatmap
    color_map = {
        "Implement / Accept": "#4CAF50",          # Mutually beneficial agreement
        "Implement / Fight": "#F44336",           # Materialized conflict
        "Withdraw / Accept": "#9E9E9E",           # Withdrawal without conflict
        "Withdraw / Fight": "#607D8B",            # Withdrawal induced by pressure
        "Absence of Pure Equilibrium": "#FFC107"  # Strategic instability
    }

    # Creating a pivot table to shape the data for plotting
    pivot_table = dados_heatmap.pivot(index='P', columns='G', values='Equilibrium')
    
    unique_equilibria = list(color_map.keys())
    eq_to_int = {eq: i for i, eq in enumerate(unique_equilibria)}
    
    # Transform the string values to numerical categories
    Z = np.zeros(pivot_table.shape)
    for i in range(pivot_table.shape[0]):
        for j in range(pivot_table.shape[1]):
            Z[i, j] = eq_to_int.get(pivot_table.iloc[i, j], 4)

    # Define the discrete colormap
    cmap = mcolors.ListedColormap([color_map[eq] for eq in unique_equilibria])
    bounds = np.arange(len(unique_equilibria) + 1) - 0.5
    norm = mcolors.BoundaryNorm(bounds, cmap.N)

    plt.figure(figsize=(8, 6))
    
    # We use numpy.meshgrid to generate 2D coordinate matrices from the 1D vectors for plotting.
    # matplotlib.pyplot.pcolormesh then uses these coordinate matrices to render the heatmap grid.
    P_mesh, G_mesh = np.meshgrid(pivot_table.index, pivot_table.columns, indexing='ij')
    
    # Plot the heatmap
    plt.pcolormesh(G_mesh, P_mesh, Z, cmap=cmap, norm=norm, shading='auto')

    plt.title("Sensitivity Analysis: Probability (P) vs. Compensation (G)", fontsize=14, fontweight='bold', fontfamily='serif')
    plt.suptitle("Mapping Nash Equilibrium zones in the Offshore vs. Stakeholders conflict", fontsize=11, color='gray', fontfamily='serif', y=0.92)
    plt.xlabel("Financial Compensation Offered (G)", fontsize=12, fontfamily='serif')
    plt.ylabel("Probability of Consortium Judicial Success (P)", fontsize=12, fontfamily='serif')

    # Remove margin padding
    plt.margins(x=0, y=0)

    # Custom Legend Configuration
    legend_elements = [Patch(facecolor=color_map[eq], edgecolor='black', label=eq) 
                       for eq in unique_equilibria if eq in dados_heatmap['Equilibrium'].unique()]
    
    plt.legend(handles=legend_elements, title="Resulting Equilibrium:", loc='lower center', 
               bbox_to_anchor=(0.5, -0.25), ncol=2, frameon=True, edgecolor='black')

    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    main()

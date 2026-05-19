import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import itertools

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
    print("--- Sensitivity Analysis of Equilibrium Areas by Consortium Judicial Cost (Cs) ---")
    R = float(input("Consortium Expected Return (R): "))
    LR = float(input("Opportunity cost due to project delay (LR): "))
    Cs_base = float(input("Base Consortium judicial/transaction costs (Cs_base): "))
    I = float(input("Stakeholders base economic revenue (I): "))
    L = float(input("Estimated local local economic impact (L): "))
    alpha = float(input("Mobilization cost coefficient (alpha): "))
    Ca = float(input("Stakeholders base judicial/transaction costs (Ca): "))

    # Discretization of the parameter space (100 levels per variable)
    p_grid = np.linspace(0, 1, 100)
    g_grid = np.linspace(0, L * 1.5, 100)

    # itertools.product is used to calculate the Cartesian Product between the two lists.
    # It creates a 2D grid matrix of scenarios (n = 10,000) containing every possible combination of P and G.
    grade_cenarios = list(itertools.product(p_grid, g_grid))
    total_cenarios = len(grade_cenarios)
    
    # Variation parameters: From -50% to +50% in steps of 5%
    variation_steps = np.arange(-50, 55, 5) 
    
    print(f"\nComputing {total_cenarios} analytical iterations for {len(variation_steps)} Cs levels...")

    all_matrices = []
    area_results = []
    
    # Visualization color map definition
    color_map = {
        "Implement / Accept": "#4CAF50",          # Mutually beneficial agreement
        "Implement / Fight": "#F44336",           # Materialized conflict
        "Withdraw / Accept": "#9E9E9E",           # Withdrawal without conflict
        "Withdraw / Fight": "#607D8B",            # Withdrawal induced by pressure
        "Absence of Pure Equilibrium": "#FFC107"  # Strategic instability
    }
    
    # Batch computational evaluation iterating over Cs variations
    for var in variation_steps:
        Cs_current = Cs_base * (1 + var / 100.0)
        
        # Track counts of each equilibrium for the current Cs
        equilibria = []
        matrices_for_var = []
        
        for P_val, G_val in grade_cenarios:
            matrix, eq = get_nash_equilibrium(R, LR, Cs_current, I, L, alpha, Ca, G_val, P_val)
            equilibria.append({'P': P_val, 'G': G_val, 'Equilibrium': eq})
            matrices_for_var.append(matrix)
            
        # Record rows for full traceability
        all_matrices.extend(matrices_for_var)
        
        # Calculate percentage area for the grid space
        dados_areas = pd.DataFrame(equilibria)
        counts = dados_areas['Equilibrium'].value_counts().to_dict()
        
        row_result = {'Cs_Variation_Pct': var, 'Cs_Value': Cs_current}
        for eq in color_map.keys():
            count = counts.get(eq, 0)
            row_result[eq] = (count / total_cenarios) * 100.0
            
        area_results.append(row_result)
        print(f"Computed Cs = {Cs_current:7.2f} (Variation: {var:+4d}%)")
        
    df_areas = pd.DataFrame(area_results)
    
    # Export full traceability to CSV
    print("\nSaving full traceability data (this might take a few seconds)...")
    mapa_sensibilidade_Cs = pd.concat(all_matrices, ignore_index=True)
    csv_filename = "traceability_sensitivity_Cs_areas.csv"
    mapa_sensibilidade_Cs.to_csv(csv_filename, index=False)
    print(f"[Info] Full traceability data saved to {csv_filename}")
    
    # Export summarized area data to CSV
    csv_summary = "summary_areas_by_Cs_variation.csv"
    df_areas.to_csv(csv_summary, index=False)
    print(f"[Info] Area summary data saved to {csv_summary}")

    # Rendering the Visualization: Line Chart of Area Evolution
    plt.figure(figsize=(10, 6))
    
    for eq, color in color_map.items():
        # Only plot lines that have some area > 0 across the variations
        if df_areas[eq].max() > 0:
            plt.plot(df_areas['Cs_Variation_Pct'], df_areas[eq], 
                     color=color, linewidth=2.5, marker='o', markersize=5, label=eq)

    plt.title("Evolution of Equilibrium Areas by Consortium Judicial Cost Variation", fontsize=14, fontweight='bold', fontfamily='serif')
    plt.suptitle(f"Base Cs = {Cs_base}", fontsize=11, color='gray', fontfamily='serif', y=0.92)
    plt.xlabel("Variation of Consortium Judicial Cost 'Cs' (%)", fontsize=12, fontfamily='serif')
    plt.ylabel("Area in the P vs G scenario grid (%)", fontsize=12, fontfamily='serif')

    # X-axis ticks matching the variation steps
    plt.xticks(variation_steps)
    plt.grid(True, linestyle='--', alpha=0.6)

    # Custom Legend Configuration
    plt.legend(title="Nash Equilibrium", loc='center left', bbox_to_anchor=(1, 0.5), frameon=True, edgecolor='black')

    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    main()

import pandas as pd
import os

# Helper function to compare CSVs ignoring row order and whitespace
def compare_csv_files(file1, file2):
    df1 = pd.read_csv(file1)
    df2 = pd.read_csv(file2)
    # Compare shapes
    if df1.shape != df2.shape:
        return False
    # Sort by all columns (assuming no index column)
    df1_sorted = df1.sort_values(by=df1.columns.tolist()).reset_index(drop=True)
    df2_sorted = df2.sort_values(by=df2.columns.tolist()).reset_index(drop=True)
    # Compare all values
    return df1_sorted.equals(df2_sorted)


def test_qc_summary_output():
    prefix = "2025-04-29_Project_Test_Pipeline_nanoQC" 
    current_file = f"results/{prefix}/{prefix}_report/{prefix}_report.csv"
    reference_file = f".test/reference_data/{prefix}_report.csv"
    assert os.path.exists(current_file), f"{current_file} does not exist."
    assert os.path.exists(reference_file), f"{reference_file} does not exist."
    assert compare_csv_files(current_file, reference_file), "QC summary output differs from reference!"

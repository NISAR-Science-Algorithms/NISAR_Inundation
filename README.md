# NISAR_L3_Wetlands
Repository for L3 science products for the Ecosystems Wetlands workflow



### ***NISAR_L3_Wetlands_ProductGeneration.ipynb:***
This notebook describes the ATBD for generating a wetland inundation product from NISAR time series data stacks. The algorithm implemented within is designed to meet the Level-2 Science requirement for detecting inundated vegetation.  The contents of this repository  is tailored to provide users the supported resources needed to generate the L3 product, including a cropped & coregistered NISAR-simulated GCOV time series stack, an array of thresholds derived from ..., a geojson file specifying the AOI, as well as a configuration file.  



### Installation and Setup:
1) Fork the repository

2) Clone your fork to your local machine with an SSH key
   ```
   git clone git@github.com:{your_github_username}/NISAR_Wetlands.git
   ```
3) Install the required Python packages
   ```
   cd NISAR_Wetlands
   conda env create -f requirements.yml
   conda activate NISAR_Wetlands
   ```
4) Run the notebooks
   ```
   jupyter notebook
   ```
test

   
### For Developers Submitting Code
1) Install pre-commit to ensure pre-commit hooks are run
   ```
   pip install pre-commit
   pre-commit install
   ```
2) Install Trufflehog

   To install in a specific directory, change ~/ to your chosen path
   ```
   curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b ~/
   ```
   Make sure to add the path to trufflehog to your $PATH.
   ```
   export PATH="$PATH:~"
   ```
   
4) Make a new branch to develop your changes in
   ```
   git checkout -b {your_branch}
   ```
5) Make changes to files and add changes to your commit
   ```
   git add {file}
   ```
   ***Make sure to clear the outputs of any Jupyter Notebook before committing changes.***
7) Commit changes to your fork
   ```
   git commit -m "comments related to this commit"
   ```
   This will run trufflehog pre-commit hooks to scan for any potential secrets. If secrets are detected, this will fail and you will need to resolve the issues
8) Push your commit to your branch in your fork
   ```
   git push --set-upstream origin {your_branch}
   ```
9) Go back to your fork on Github.com and submit a merge request
    
